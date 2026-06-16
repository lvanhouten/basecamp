import 'package:drift/drift.dart';

import '../../../core/db/app_db.dart';
import '../../../core/db/tables.dart';

part 'clock_dao.g.dart';

/// All persistence for the Clock module's tools lives here — the single DAO
/// shared by Timer (this brief), Stopwatch (03), and Alarms (07). Each tool's
/// queries are grouped under a banner comment so additive briefs union cleanly:
/// 03 adds the `ModuleData`-backed stopwatch methods, 07 adds an `Alarms` table
/// + its methods. When a tool adds its own table, append it to the
/// `@DriftAccessor(tables: [...])` list below (and register the table in
/// `app_db.dart`).
///
/// Other modules never touch these tables — they go through the [ClockApi]
/// facade (`clock_api.dart`) instead.
@DriftAccessor(tables: [Timers, ModuleData])
class ClockDao extends DatabaseAccessor<AppDb> with _$ClockDaoMixin {
  ClockDao(super.db);

  // ========================================================================
  // Timer (04-timer-data)
  // ========================================================================

  /// Currently-running timers, soonest [Timers.endsAt] first, then creation
  /// order (`createdAt`, with `id` as a stable final tiebreaker). "Running"
  /// means `endsAt` is set — this INCLUDES a just-finished timer whose `endsAt`
  /// is now in the past (it stays visible/ringing until dismissed). The UI uses
  /// clock-math against `now` to tell running from finished; the DAO only knows
  /// the persisted shape.
  Stream<List<TimerRow>> watchRunningTimers() {
    return (select(timers)
          ..where((t) => t.endsAt.isNotNull())
          ..orderBy([
            (t) => OrderingTerm(expression: t.endsAt),
            (t) => OrderingTerm(expression: t.createdAt),
            (t) => OrderingTerm(expression: t.id),
          ]))
        .watch();
  }

  /// Every timer regardless of state (running, paused, finished). Paused timers
  /// have no `endsAt`, so they sort last; within each group, creation order.
  Stream<List<TimerRow>> watchAllTimers() {
    return (select(timers)
          ..orderBy([
            (t) => OrderingTerm(expression: t.endsAt),
            (t) => OrderingTerm(expression: t.createdAt),
            (t) => OrderingTerm(expression: t.id),
          ]))
        .watch();
  }

  /// Count of timers with `endsAt` strictly in the future, relative to [now].
  /// A finished timer (`endsAt <= now`) is excluded — it is no longer counting
  /// down even though its row persists until dismissed. Backs
  /// `ClockApi.watchRunningTimerCount` and the Brief's timer segment.
  ///
  /// [now] is injected (not `DateTime.now()` inside the query) so the count is
  /// deterministic in tests; the repository passes the wall clock at call time.
  /// Re-emits whenever the `timers` table changes — it does NOT tick down on
  /// its own, so a timer crossing `endsAt` with no write won't drop the count
  /// until the next table mutation. That's acceptable: the running LIST (and
  /// its UI ticker) is the live surface; the count is a Brief summary that
  /// settles on the next create/pause/resume/dismiss.
  Stream<int> watchRunningTimerCount(DateTime now) {
    final total = timers.id.count();
    return (selectOnly(timers)
          ..addColumns([total])
          ..where(timers.endsAt.isBiggerThanValue(now)))
        .map((row) => row.read(total) ?? 0)
        .watchSingle();
  }

  /// One timer by id (null if it was dismissed). Used by the repository to read
  /// the current `endsAt` before a pause computes remaining.
  Future<TimerRow?> findTimer(int id) =>
      (select(timers)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Inserts a running timer: `endsAt` set, `remainingMs` null. Returns the new
  /// id (used as the notification id).
  Future<int> insertRunningTimer({
    String? label,
    required int durationMs,
    required DateTime endsAt,
  }) {
    return into(timers).insert(
      TimersCompanion.insert(
        label: Value(label),
        durationMs: durationMs,
        endsAt: Value(endsAt),
      ),
    );
  }

  /// Pause transition: clear `endsAt`, store the captured `remainingMs`. The
  /// `Value.absent()`-free explicit nulls are intentional — pausing must blank
  /// `endsAt`, so we pass an explicit `Value(null)`.
  Future<void> setPaused(int id, int remainingMs) =>
      (update(timers)..where((t) => t.id.equals(id))).write(
        TimersCompanion(
          endsAt: const Value(null),
          remainingMs: Value(remainingMs),
        ),
      );

  /// Resume transition: set a fresh `endsAt`, clear `remainingMs`.
  Future<void> setRunning(int id, DateTime endsAt) =>
      (update(timers)..where((t) => t.id.equals(id))).write(
        TimersCompanion(
          endsAt: Value(endsAt),
          remainingMs: const Value(null),
        ),
      );

  /// Removes a timer (cancel / dismiss-finished).
  Future<void> deleteTimer(int id) =>
      (delete(timers)..where((t) => t.id.equals(id))).go();

  // ========================================================================
  // Stopwatch (03-stopwatch)
  //
  // The single Stopwatch lives in the generic `ModuleData` JSON lane — no table
  // of its own, no migration. It is ONE record, addressed by a fixed
  // (moduleId, entryKey): [clockModuleId] / [stopwatchEntryKey]. The `payload`
  // map is the persisted truth ({ startedAt, accumulatedMs, isRunning, laps }):
  // the pane derives its displayed value from this record + `now` via
  // `clock_math.stopwatchElapsed`, never from a live tick (ADR-0004 — store
  // timestamps, not ticking state, so the value is correct after backgrounding
  // and cold start). The repository owns the payload shape; the DAO just
  // streams/upserts the raw map.
  // ========================================================================

  /// The clock module's id in the generic [ModuleData] lane.
  static const clockModuleId = 'clock';

  /// The single stopwatch's entry key within [clockModuleId].
  static const stopwatchEntryKey = 'stopwatch';

  /// Streams the raw stopwatch payload map, or null until the record is first
  /// written. Reactive: re-emits on every transition write (start/pause/lap/
  /// reset). `watchSingleOrNull` (not `watchSingle`) because no record exists
  /// before the first interaction — a fresh install reads null = idle/zero.
  Stream<Map<String, dynamic>?> watchStopwatch() {
    return (select(moduleData)
          ..where((r) =>
              r.moduleId.equals(clockModuleId) &
              r.entryKey.equals(stopwatchEntryKey)))
        .map((row) => row.payload)
        .watchSingleOrNull();
  }

  /// Upserts the single stopwatch record with [payload]. Called only on
  /// transitions, never per display frame. The (moduleId, entryKey) primary key
  /// makes this idempotent — there is always exactly one stopwatch row.
  Future<void> writeStopwatch(Map<String, dynamic> payload) {
    return into(moduleData).insertOnConflictUpdate(
      ModuleDataCompanion.insert(
        moduleId: clockModuleId,
        entryKey: stopwatchEntryKey,
        payload: payload,
      ),
    );
  }
}
