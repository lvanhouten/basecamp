import 'package:basecamp/features/clock/clock_math.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // A fixed anchor; every case derives its timestamps from this so the math is
  // obvious and the functions are exercised across running / paused / expired /
  // exact-boundary inputs. No test reads the real wall clock — `now` is injected.
  final base = DateTime.utc(2026, 6, 16, 12, 0, 0);

  group('stopwatchElapsed', () {
    test('running: elapsed = accumulatedMs + (now - startedAt)', () {
      final startedAt = base;
      final now = base.add(const Duration(seconds: 30));
      // 90s banked + 30s live segment.
      final result = stopwatchElapsed(
        startedAt: startedAt,
        accumulatedMs: const Duration(seconds: 90).inMilliseconds,
        now: now,
      );
      expect(result, const Duration(seconds: 120));
    });

    test('running from zero accumulated: just the live segment', () {
      final result = stopwatchElapsed(
        startedAt: base,
        accumulatedMs: 0,
        now: base.add(const Duration(milliseconds: 4321)),
      );
      expect(result, const Duration(milliseconds: 4321));
    });

    test('running at the exact start instant: elapsed = accumulated', () {
      // now == startedAt → live segment is zero.
      final result = stopwatchElapsed(
        startedAt: base,
        accumulatedMs: const Duration(seconds: 5).inMilliseconds,
        now: base,
      );
      expect(result, const Duration(seconds: 5));
    });

    test('paused: elapsed = accumulatedMs, independent of now', () {
      final accumulatedMs = const Duration(minutes: 7).inMilliseconds;
      final early = stopwatchElapsed(
        startedAt: null,
        accumulatedMs: accumulatedMs,
        now: base,
      );
      final late = stopwatchElapsed(
        startedAt: null,
        accumulatedMs: accumulatedMs,
        now: base.add(const Duration(hours: 99)),
      );
      expect(early, const Duration(minutes: 7));
      // `now` must not affect a paused stopwatch.
      expect(late, equals(early));
    });

    test('just-reset (accumulated 0, not running) reports zero', () {
      final result = stopwatchElapsed(
        startedAt: null,
        accumulatedMs: 0,
        now: base,
      );
      expect(result, Duration.zero);
    });
  });

  group('countdownRemaining', () {
    test('active: remaining = endsAt - now while now < endsAt', () {
      final endsAt = base.add(const Duration(minutes: 5));
      final result = countdownRemaining(
        endsAt: endsAt,
        now: base.add(const Duration(minutes: 2)),
      );
      expect(result, const Duration(minutes: 3));
    });

    test('sub-second precision is preserved', () {
      final endsAt = base.add(const Duration(milliseconds: 1500));
      final result = countdownRemaining(endsAt: endsAt, now: base);
      expect(result, const Duration(milliseconds: 1500));
    });

    test('exact boundary (now == endsAt) clamps to zero', () {
      final result = countdownRemaining(endsAt: base, now: base);
      expect(result, Duration.zero);
    });

    test('expired (now > endsAt) clamps to zero, never negative', () {
      final endsAt = base.add(const Duration(seconds: 10));
      final result = countdownRemaining(
        endsAt: endsAt,
        now: base.add(const Duration(seconds: 40)),
      );
      expect(result, Duration.zero);
      expect(result.isNegative, isFalse);
    });
  });

  group('pausedRemaining', () {
    test('equals endsAt - now while active', () {
      final endsAt = base.add(const Duration(minutes: 10));
      final result = pausedRemaining(
        endsAt: endsAt,
        now: base.add(const Duration(minutes: 4)),
      );
      expect(result, const Duration(minutes: 6));
    });

    test('clamps to zero at the exact boundary', () {
      expect(pausedRemaining(endsAt: base, now: base), Duration.zero);
    });

    test('clamps to zero when already expired (never negative)', () {
      final result = pausedRemaining(
        endsAt: base,
        now: base.add(const Duration(seconds: 5)),
      );
      expect(result, Duration.zero);
      expect(result.isNegative, isFalse);
    });

    test('matches countdownRemaining for the same inputs', () {
      final endsAt = base.add(const Duration(minutes: 3));
      final now = base.add(const Duration(minutes: 1));
      expect(
        pausedRemaining(endsAt: endsAt, now: now),
        countdownRemaining(endsAt: endsAt, now: now),
      );
    });
  });
}
