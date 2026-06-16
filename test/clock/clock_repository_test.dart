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

    test('stopwatchRunning emits false (03-stopwatch)', () {
      expect(repo.watchStopwatchRunning(), emits(false));
    });
  });
}
