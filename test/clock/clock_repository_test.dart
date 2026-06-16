import 'package:basecamp/core/contracts/clock_api.dart';
import 'package:basecamp/features/clock/data/clock_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClockRepository placeholders', () {
    test('implements the ClockApi contract', () {
      expect(const ClockRepository(), isA<ClockApi>());
    });

    test('todaysAlarmCount emits 0 without error', () {
      expect(const ClockRepository().watchTodaysAlarmCount(), emits(0));
    });

    test('runningTimerCount emits 0 without error', () {
      expect(const ClockRepository().watchRunningTimerCount(), emits(0));
    });

    test('stopwatchRunning emits false without error', () {
      expect(const ClockRepository().watchStopwatchRunning(), emits(false));
    });

    test('every count stream completes without emitting an error', () {
      final repo = const ClockRepository();
      expect(repo.watchTodaysAlarmCount(), emitsThrough(0));
      expect(repo.watchRunningTimerCount(), emitsThrough(0));
      expect(repo.watchStopwatchRunning(), emitsThrough(false));
    });
  });
}
