import '../../../core/contracts/clock_api.dart';

/// The Clock module's own data access. It IMPLEMENTS [ClockApi] (the narrow
/// cross-module contract) and will, in later briefs, also expose richer methods
/// used only by the Clock UI (mirroring `ListsRepository`'s repository/api split).
///
/// SHELL SCAFFOLD: every count here is a safe placeholder that emits ONCE and
/// without error (`0` / `0` / `false`). It is deliberately NOT yet wired to any
/// Drift table — counts return placeholders in this brief. Later briefs replace
/// each stream with a real reactive query against its persistence:
///   - [watchStopwatchRunning]  → 03-stopwatch
///   - [watchRunningTimerCount] → 04-timer-data
///   - [watchTodaysAlarmCount]  → 07-alarm-data
///
/// When a tool's DAO lands, inject it through the constructor (as Lists does
/// with `ListsDao`/`EventBus`) and swap the placeholder for `_dao.watchX()`.
class ClockRepository implements ClockApi {
  const ClockRepository();

  // --- ClockApi (visible to other modules via clockApiProvider) ---

  @override
  Stream<int> watchTodaysAlarmCount() => Stream.value(0);

  @override
  Stream<int> watchRunningTimerCount() => Stream.value(0);

  @override
  Stream<bool> watchStopwatchRunning() => Stream.value(false);
}
