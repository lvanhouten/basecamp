/// The three tools the Clock module presents as tabs. Order matches the tab bar
/// in `clock_screen.dart`; `index` is what the [TabController] and the
/// selected-tab provider exchange.
enum ClockTab { alarms, timer, stopwatch }

/// Pure tab-precedence: which Clock tab to open given live tool state.
///
/// Implements ADR-0004's fixed precedence — a running **Stopwatch** wins, else a
/// running **Timer** (>=1), else **Alarms** (the resting default, including when
/// nothing is live). Alarms are scheduled future state, never an in-progress
/// Resume target, so they only win by default — never by their count.
///
/// Kept pure (no Riverpod, no IO) so it can be unit-tested in isolation and
/// reused wherever an entry tab is derived (the Brief card tap, resume-time
/// recompute).
ClockTab entryTab({
  required bool stopwatchRunning,
  required int runningTimerCount,
  required int todaysAlarmCount,
}) {
  if (stopwatchRunning) return ClockTab.stopwatch;
  if (runningTimerCount > 0) return ClockTab.timer;
  return ClockTab.alarms;
}
