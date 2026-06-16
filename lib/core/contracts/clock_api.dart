/// The Clock module's public, module-agnostic API. This is ALL another module
/// (e.g. the daily Brief) is allowed to know about Clock — never its tables,
/// DAOs, or widgets. Implemented internally by the Clock repository.
///
/// Clock breaks ADR-0001's single-in-progress-activity assumption: a Stopwatch
/// and several Timers can run at once, so the contract exposes three independent
/// reactive COUNTS rather than one active activity (ADR-0004). The Brief renders
/// them as a summary phrase and derives the entry tab from them.
abstract interface class ClockApi {
  /// Count of Alarms due today that are also **Enabled** (the alarm term — not
  /// "active"). Alarms are scheduled future state, a summary line only.
  Stream<int> watchTodaysAlarmCount();

  /// Count of Timers currently counting down.
  Stream<int> watchRunningTimerCount();

  /// Whether the single Stopwatch is currently running.
  Stream<bool> watchStopwatchRunning();
}
