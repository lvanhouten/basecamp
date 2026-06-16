import 'package:basecamp/core/db/app_db.dart';
import 'package:basecamp/features/clock/data/clock_dao.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDb db;
  late ClockDao dao;

  setUp(() {
    db = AppDb.forTesting(NativeDatabase.memory());
    dao = db.clockDao;
  });

  tearDown(() async {
    await db.close();
  });

  // A fixed reference instant so "future"/"past" are deterministic. LOCAL (not
  // UTC) because Drift persists DateTime as Unix epoch and reads it back in the
  // local zone — a UTC literal would round-trip to a local-zone DateTime and
  // fail `==`. Real callers pass `DateTime.now()`, which is local too.
  final t0 = DateTime(2026, 6, 16, 12, 0, 0);

  group('insertRunningTimer', () {
    test('persists label, durationMs, endsAt; remainingMs null (running)',
        () async {
      final id = await dao.insertRunningTimer(
        label: 'Tea',
        durationMs: 300000,
        endsAt: t0.add(const Duration(minutes: 5)),
      );

      final row = await dao.findTimer(id);
      expect(row, isNotNull);
      expect(row!.label, 'Tea');
      expect(row.durationMs, 300000);
      expect(row.endsAt, t0.add(const Duration(minutes: 5)));
      expect(row.remainingMs, isNull);
    });

    test('label is optional', () async {
      final id = await dao.insertRunningTimer(
        durationMs: 60000,
        endsAt: t0.add(const Duration(minutes: 1)),
      );
      expect((await dao.findTimer(id))!.label, isNull);
    });
  });

  group('setPaused / setRunning transitions', () {
    test('setPaused clears endsAt and stores remainingMs', () async {
      final id = await dao.insertRunningTimer(
        durationMs: 300000,
        endsAt: t0.add(const Duration(minutes: 5)),
      );

      await dao.setPaused(id, 120000);

      final row = await dao.findTimer(id);
      expect(row!.endsAt, isNull, reason: 'paused has no endsAt');
      expect(row.remainingMs, 120000);
    });

    test('setRunning sets a fresh endsAt and clears remainingMs', () async {
      final id = await dao.insertRunningTimer(
        durationMs: 300000,
        endsAt: t0.add(const Duration(minutes: 5)),
      );
      await dao.setPaused(id, 120000);

      final resumeEnds = t0.add(const Duration(minutes: 10));
      await dao.setRunning(id, resumeEnds);

      final row = await dao.findTimer(id);
      expect(row!.endsAt, resumeEnds);
      expect(row.remainingMs, isNull, reason: 'running has no remainingMs');
    });
  });

  group('deleteTimer', () {
    test('removes the row', () async {
      final id = await dao.insertRunningTimer(
        durationMs: 60000,
        endsAt: t0.add(const Duration(minutes: 1)),
      );
      await dao.deleteTimer(id);
      expect(await dao.findTimer(id), isNull);
    });
  });

  group('watchRunningTimers ordering', () {
    test('only timers with endsAt set, soonest endsAt then creation order',
        () async {
      // Inserted out of endsAt order to prove the query sorts, not insertion.
      final later = await dao.insertRunningTimer(
        durationMs: 1,
        endsAt: t0.add(const Duration(minutes: 10)),
      );
      final sooner = await dao.insertRunningTimer(
        durationMs: 1,
        endsAt: t0.add(const Duration(minutes: 2)),
      );
      // A paused timer (no endsAt) must be excluded from the running list.
      final paused = await dao.insertRunningTimer(
        durationMs: 1,
        endsAt: t0.add(const Duration(minutes: 5)),
      );
      await dao.setPaused(paused, 30000);

      final running = await dao.watchRunningTimers().first;
      expect(running.map((t) => t.id).toList(), [sooner, later]);
    });

    test('equal endsAt falls back to creation order (id tiebreak)', () async {
      final ends = t0.add(const Duration(minutes: 3));
      final a = await dao.insertRunningTimer(durationMs: 1, endsAt: ends);
      final b = await dao.insertRunningTimer(durationMs: 1, endsAt: ends);

      final running = await dao.watchRunningTimers().first;
      expect(running.map((t) => t.id).toList(), [a, b]);
    });

    test('a finished timer (endsAt in the past) still appears (until dismissed)',
        () async {
      final finished = await dao.insertRunningTimer(
        durationMs: 1,
        endsAt: t0.subtract(const Duration(minutes: 1)),
      );
      final running = await dao.watchRunningTimers().first;
      expect(running.map((t) => t.id), contains(finished));
    });
  });

  group('watchAllTimers', () {
    test('includes running, finished, and paused timers', () async {
      final running = await dao.insertRunningTimer(
        durationMs: 1,
        endsAt: t0.add(const Duration(minutes: 5)),
      );
      final paused = await dao.insertRunningTimer(
        durationMs: 1,
        endsAt: t0.add(const Duration(minutes: 5)),
      );
      await dao.setPaused(paused, 1000);

      final all = await dao.watchAllTimers().first;
      expect(all.map((t) => t.id).toSet(), {running, paused});
    });
  });

  group('watchRunningTimerCount', () {
    test('counts only timers with endsAt strictly in the future', () async {
      // future
      await dao.insertRunningTimer(
        durationMs: 1,
        endsAt: t0.add(const Duration(minutes: 5)),
      );
      // also future
      await dao.insertRunningTimer(
        durationMs: 1,
        endsAt: t0.add(const Duration(seconds: 1)),
      );
      // finished (past) -> excluded
      await dao.insertRunningTimer(
        durationMs: 1,
        endsAt: t0.subtract(const Duration(minutes: 1)),
      );
      // paused (no endsAt) -> excluded
      final paused = await dao.insertRunningTimer(
        durationMs: 1,
        endsAt: t0.add(const Duration(minutes: 5)),
      );
      await dao.setPaused(paused, 1000);

      expect(await dao.watchRunningTimerCount(t0).first, 2);
    });

    test('a timer exactly at now is NOT counted (boundary = finished)',
        () async {
      await dao.insertRunningTimer(durationMs: 1, endsAt: t0);
      expect(await dao.watchRunningTimerCount(t0).first, 0);
    });

    test('re-emits when the table changes', () async {
      final stream = dao.watchRunningTimerCount(t0);
      expect(await stream.first, 0);
      await dao.insertRunningTimer(
        durationMs: 1,
        endsAt: t0.add(const Duration(minutes: 5)),
      );
      // A fresh listen reflects the new row (same query, reactive table).
      expect(await dao.watchRunningTimerCount(t0).first, 1);
    });
  });
}
