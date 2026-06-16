import 'package:basecamp/core/contracts/clock_api.dart';
import 'package:basecamp/core/db/app_db.dart';
import 'package:basecamp/features/clock/data/clock_dao.dart';
import 'package:basecamp/features/clock/data/clock_repository.dart';
import 'package:basecamp/features/clock/data/notification_scheduler.dart';
import 'package:basecamp/features/clock/clock_math.dart' as clock_math;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records every scheduler call so the repository's scheduling coordination is
/// asserted without the real `flutter_local_notifications` plugin.
class _FakeScheduler implements NotificationScheduler {
  final scheduled = <({int id, DateTime at, String? payload})>[];
  final cancelled = <int>[];
  int permissionRequests = 0;

  /// Flip to false to simulate the user denying POST_NOTIFICATIONS.
  bool permission = true;

  @override
  Future<bool> ensurePermission() async {
    permissionRequests++;
    return permission;
  }

  @override
  Future<void> schedule({
    required int id,
    required DateTime at,
    String? payload,
  }) async {
    scheduled.add((id: id, at: at, payload: payload));
  }

  @override
  Future<void> cancel(int id) async => cancelled.add(id);
}

void main() {
  late AppDb db;
  late ClockDao dao;
  late _FakeScheduler scheduler;
  late ClockRepository repo;

  // Injected wall clock so endsAt math is deterministic. LOCAL (not UTC): Drift
  // persists DateTime as Unix epoch and reads it back in the local zone, so a
  // UTC literal would round-trip to local and fail `==`. Real callers pass
  // `DateTime.now()` (local) anyway.
  final now = DateTime(2026, 6, 16, 12, 0, 0);

  setUp(() {
    db = AppDb.forTesting(NativeDatabase.memory());
    dao = db.clockDao;
    scheduler = _FakeScheduler();
    repo = ClockRepository(dao, scheduler);
  });

  tearDown(() async {
    await db.close();
  });

  test('still implements the ClockApi contract', () {
    expect(repo, isA<ClockApi>());
  });

  group('createTimer', () {
    test('inserts endsAt = now + duration and schedules at endsAt', () async {
      const duration = Duration(minutes: 5);
      final id = await repo.createTimer(duration, label: 'Tea', now: now);

      final row = await dao.findTimer(id);
      expect(row!.endsAt, now.add(duration));
      expect(row.durationMs, duration.inMilliseconds);
      expect(row.label, 'Tea');
      expect(row.remainingMs, isNull);

      expect(scheduler.scheduled.single.id, id);
      expect(scheduler.scheduled.single.at, now.add(duration));
      expect(scheduler.scheduled.single.payload, 'timer:$id');
    });

    test('requests permission contextually; denial still runs the timer',
        () async {
      scheduler.permission = false;
      final id =
          await repo.createTimer(const Duration(minutes: 1), now: now);

      expect(scheduler.permissionRequests, 1);
      expect(repo.notificationsAllowed, isFalse,
          reason: 'a denial is surfaced for an in-app warning');
      expect(await dao.findTimer(id), isNotNull,
          reason: 'the timer runs regardless of permission');
      // It still schedules — the OS drops it silently if truly denied.
      expect(scheduler.scheduled, hasLength(1));
    });
  });

  group('pauseTimer', () {
    test('stores remaining (clock-math), clears endsAt, cancels notification',
        () async {
      final id = await repo.createTimer(const Duration(minutes: 5), now: now);

      // Pause 2 minutes in: 3 minutes should remain.
      final pauseAt = now.add(const Duration(minutes: 2));
      await repo.pauseTimer(id, now: pauseAt);

      final row = await dao.findTimer(id);
      expect(row!.endsAt, isNull);
      final expected = clock_math.pausedRemaining(
        endsAt: now.add(const Duration(minutes: 5)),
        now: pauseAt,
      );
      expect(row.remainingMs, expected.inMilliseconds);
      expect(row.remainingMs, const Duration(minutes: 3).inMilliseconds);

      expect(scheduler.cancelled, contains(id));
    });

    test('is a no-op on an already-paused timer', () async {
      final id = await repo.createTimer(const Duration(minutes: 5), now: now);
      await repo.pauseTimer(id, now: now.add(const Duration(minutes: 1)));
      scheduler.cancelled.clear();

      await repo.pauseTimer(id, now: now.add(const Duration(minutes: 2)));
      expect(scheduler.cancelled, isEmpty);
    });
  });

  group('resumeTimer', () {
    test('sets endsAt = now + remainingMs, clears remainingMs, reschedules',
        () async {
      final id = await repo.createTimer(const Duration(minutes: 5), now: now);
      await repo.pauseTimer(id, now: now.add(const Duration(minutes: 2)));
      scheduler.scheduled.clear();

      final resumeAt = now.add(const Duration(minutes: 10));
      await repo.resumeTimer(id, now: resumeAt);

      final row = await dao.findTimer(id);
      // 3 minutes remained at pause -> new endsAt = resumeAt + 3m.
      expect(row!.endsAt, resumeAt.add(const Duration(minutes: 3)));
      expect(row.remainingMs, isNull);

      expect(scheduler.scheduled.single.id, id);
      expect(
        scheduler.scheduled.single.at,
        resumeAt.add(const Duration(minutes: 3)),
      );
    });

    test('is a no-op on an already-running timer', () async {
      final id = await repo.createTimer(const Duration(minutes: 5), now: now);
      scheduler.scheduled.clear();

      await repo.resumeTimer(id, now: now);
      expect(scheduler.scheduled, isEmpty);
    });
  });

  group('cancelTimer', () {
    test('deletes the row and cancels the notification', () async {
      final id = await repo.createTimer(const Duration(minutes: 5), now: now);

      await repo.cancelTimer(id);

      expect(await dao.findTimer(id), isNull);
      expect(scheduler.cancelled, contains(id));
    });
  });

  group('watchRunningTimerCount (real, via DAO)', () {
    test('counts only future timers; finished/paused excluded', () async {
      // Two running (future, given the real wall clock used by the count).
      await repo.createTimer(const Duration(hours: 1));
      await repo.createTimer(const Duration(hours: 2));
      // One paused.
      final paused = await repo.createTimer(const Duration(hours: 1));
      await repo.pauseTimer(paused);

      expect(await repo.watchRunningTimerCount().first, 2);
    });
  });

  group('concurrent running timers stream ordering', () {
    test('watchRunningTimers is ordered by soonest endsAt', () async {
      await repo.createTimer(const Duration(minutes: 30), now: now);
      await repo.createTimer(const Duration(minutes: 5), now: now);
      await repo.createTimer(const Duration(minutes: 15), now: now);

      final running = await repo.watchRunningTimers().first;
      expect(
        running.map((t) => t.endsAt).toList(),
        [
          now.add(const Duration(minutes: 5)),
          now.add(const Duration(minutes: 15)),
          now.add(const Duration(minutes: 30)),
        ],
      );
    });
  });

  group('other ClockApi counts remain placeholders for sibling briefs', () {
    test('todaysAlarmCount emits 0 (07-alarm-data)', () {
      expect(repo.watchTodaysAlarmCount(), emits(0));
    });
  });

  group('stopwatch', () {
    test('idle before any interaction (no record): not running, zero elapsed',
        () async {
      final s = await repo.readStopwatch();
      expect(s.isRunning, isFalse);
      expect(s.accumulatedMs, 0);
      expect(s.laps, isEmpty);
      expect(s.elapsedAt(now), Duration.zero);
      // watchStopwatchRunning derives from the same record.
      expect(await repo.watchStopwatchRunning().first, isFalse);
    });

    test('start persists startedAt + isRunning, preserving accumulated',
        () async {
      await repo.startStopwatch(now: now);

      final s = await repo.readStopwatch();
      expect(s.isRunning, isTrue);
      expect(s.startedAt, now);
      expect(s.accumulatedMs, 0);
      expect(await repo.watchStopwatchRunning().first, isTrue);
    });

    test('running elapsed = accumulated + (now − startedAt)', () async {
      await repo.startStopwatch(now: now);
      final s = await repo.readStopwatch();
      // 90s after start, still running.
      final at = now.add(const Duration(seconds: 90));
      expect(s.elapsedAt(at), const Duration(seconds: 90));
    });

    test('pause banks the live segment into accumulatedMs and stops counting',
        () async {
      await repo.startStopwatch(now: now);
      final pauseAt = now.add(const Duration(seconds: 30));
      await repo.pauseStopwatch(now: pauseAt);

      final s = await repo.readStopwatch();
      expect(s.isRunning, isFalse);
      expect(s.startedAt, isNull);
      expect(s.accumulatedMs, const Duration(seconds: 30).inMilliseconds);
      // Paused: elapsed is independent of `now`.
      expect(s.elapsedAt(pauseAt.add(const Duration(hours: 1))),
          const Duration(seconds: 30));
      expect(await repo.watchStopwatchRunning().first, isFalse);
    });

    test('resume continues from the accumulated value', () async {
      await repo.startStopwatch(now: now);
      await repo.pauseStopwatch(now: now.add(const Duration(seconds: 30)));

      // Resume an hour later; run another 10s.
      final resumeAt = now.add(const Duration(hours: 1));
      await repo.startStopwatch(now: resumeAt);
      final s = await repo.readStopwatch();
      expect(s.startedAt, resumeAt);
      expect(s.accumulatedMs, const Duration(seconds: 30).inMilliseconds);
      // 30s banked + 10s live = 40s.
      expect(s.elapsedAt(resumeAt.add(const Duration(seconds: 10))),
          const Duration(seconds: 40));
    });

    test('start is a no-op while already running (keeps the live segment)',
        () async {
      await repo.startStopwatch(now: now);
      // A second start 5s later must NOT re-stamp startedAt.
      await repo.startStopwatch(now: now.add(const Duration(seconds: 5)));
      expect((await repo.readStopwatch()).startedAt, now);
    });

    test('pause is a no-op while already paused', () async {
      await repo.startStopwatch(now: now);
      await repo.pauseStopwatch(now: now.add(const Duration(seconds: 30)));
      final accumulated = (await repo.readStopwatch()).accumulatedMs;

      await repo.pauseStopwatch(now: now.add(const Duration(minutes: 5)));
      expect((await repo.readStopwatch()).accumulatedMs, accumulated);
    });

    test('lap appends the current elapsed, in order, leaving run state intact',
        () async {
      await repo.startStopwatch(now: now);
      await repo.lapStopwatch(now: now.add(const Duration(seconds: 10)));
      await repo.lapStopwatch(now: now.add(const Duration(seconds: 25)));

      final s = await repo.readStopwatch();
      expect(s.laps.map((d) => d.inSeconds).toList(), [10, 25]);
      expect(s.isRunning, isTrue, reason: 'lap does not stop the stopwatch');
      expect(s.startedAt, now);
    });

    test('reset zeroes elapsed and clears all laps', () async {
      await repo.startStopwatch(now: now);
      await repo.lapStopwatch(now: now.add(const Duration(seconds: 10)));
      await repo.pauseStopwatch(now: now.add(const Duration(seconds: 30)));

      await repo.resetStopwatch();
      final s = await repo.readStopwatch();
      expect(s.accumulatedMs, 0);
      expect(s.startedAt, isNull);
      expect(s.isRunning, isFalse);
      expect(s.laps, isEmpty);
      expect(s.elapsedAt(now), Duration.zero);
    });

    test(
        'cold start: re-reading the persisted record reproduces running elapsed',
        () async {
      // Simulate a write, then a fresh repo/DAO over the SAME db (process death
      // keeps the on-disk record; here the in-memory db stands in for that).
      await repo.startStopwatch(now: now);

      final freshRepo = ClockRepository(dao, _FakeScheduler());
      final s = await freshRepo.readStopwatch();
      // Running stopwatch shows accumulated + (now − startedAt) at any later now.
      final coldNow = now.add(const Duration(minutes: 2));
      expect(s.isRunning, isTrue);
      expect(s.elapsedAt(coldNow), const Duration(minutes: 2));
    });

    test('cold start: a paused stopwatch shows only accumulatedMs', () async {
      await repo.startStopwatch(now: now);
      await repo.pauseStopwatch(now: now.add(const Duration(seconds: 45)));

      final freshRepo = ClockRepository(dao, _FakeScheduler());
      final s = await freshRepo.readStopwatch();
      expect(s.isRunning, isFalse);
      expect(s.elapsedAt(now.add(const Duration(hours: 3))),
          const Duration(seconds: 45));
    });

    test('watchStopwatch re-emits on each transition', () async {
      final emissions = <bool>[];
      final sub =
          repo.watchStopwatch().listen((s) => emissions.add(s.isRunning));
      await pumpEventQueue();

      await repo.startStopwatch(now: now);
      await pumpEventQueue();
      await repo.pauseStopwatch(now: now.add(const Duration(seconds: 5)));
      await pumpEventQueue();

      await sub.cancel();
      // null record (false) → start (true) → pause (false).
      expect(emissions, containsAllInOrder([false, true, false]));
    });
  });
}
