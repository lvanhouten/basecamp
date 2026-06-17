import 'package:basecamp/features/clock/clock_tab.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('entryTab precedence (ADR-0004: Stopwatch > Timer > Alarm)', () {
    test('running stopwatch wins over everything', () {
      expect(
        entryTab(
          stopwatchRunning: true,
          runningTimerCount: 3,
          todaysAlarmCount: 5,
        ),
        ClockTab.stopwatch,
      );
    });

    test('stopwatch wins even when it is the only thing live', () {
      expect(
        entryTab(
          stopwatchRunning: true,
          runningTimerCount: 0,
          todaysAlarmCount: 0,
        ),
        ClockTab.stopwatch,
      );
    });

    test('a running timer wins when the stopwatch is idle', () {
      expect(
        entryTab(
          stopwatchRunning: false,
          runningTimerCount: 1,
          todaysAlarmCount: 5,
        ),
        ClockTab.timer,
      );
    });

    test('multiple running timers still resolve to the Timer tab', () {
      expect(
        entryTab(
          stopwatchRunning: false,
          runningTimerCount: 4,
          todaysAlarmCount: 0,
        ),
        ClockTab.timer,
      );
    });

    test('Alarms when only alarms are due (alarms never win by count)', () {
      expect(
        entryTab(
          stopwatchRunning: false,
          runningTimerCount: 0,
          todaysAlarmCount: 9,
        ),
        ClockTab.alarms,
      );
    });

    test('Alarms is the default when nothing is live', () {
      expect(
        entryTab(
          stopwatchRunning: false,
          runningTimerCount: 0,
          todaysAlarmCount: 0,
        ),
        ClockTab.alarms,
      );
    });
  });
}
