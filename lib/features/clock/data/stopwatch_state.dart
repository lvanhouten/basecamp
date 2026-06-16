import '../clock_math.dart' as clock_math;

/// The persisted shape of the single Stopwatch, as it lives in the generic
/// `ModuleData` JSON lane (see [ClockDao.writeStopwatch]). This is the SOURCE OF
/// TRUTH — the displayed time is always re-derived from it plus an injected
/// `now` via [elapsedAt] (ADR-0004: store timestamps, not ticking state). A
/// killed process can't keep counting, so cold start recomputes from the stored
/// values for free.
///
/// State is encoded by the two fields, mirroring the Timer's two-nullable-field
/// design (no separate status that could drift):
///   - **running** → [startedAt] non-null (the wall-clock start of the current
///     run segment), [isRunning] true.
///   - **paused / idle** → [startedAt] null; [accumulatedMs] holds the banked
///     elapsed from prior segments (0 when reset/never started).
///
/// JSON wire shape (`payload`):
/// ```json
/// { "startedAt": <epochMs|null>, "accumulatedMs": <int>,
///   "isRunning": <bool>, "laps": [<int millis>, ...] }
/// ```
/// `startedAt` persists as epoch milliseconds (UTC-agnostic instant) so JSON
/// round-trips losslessly regardless of zone; [elapsedAt] only ever takes the
/// difference of two instants, so the absolute zone is irrelevant.
class StopwatchState {
  const StopwatchState({
    required this.startedAt,
    required this.accumulatedMs,
    required this.isRunning,
    required this.laps,
  });

  /// Wall-clock start of the current live run segment; null while paused/idle.
  final DateTime? startedAt;

  /// Elapsed milliseconds banked from completed (paused) run segments.
  final int accumulatedMs;

  /// Whether the stopwatch is currently counting. Derivable from
  /// `startedAt != null`, but persisted explicitly to back
  /// `ClockApi.watchStopwatchRunning` with a direct read.
  final bool isRunning;

  /// Lap elapsed values (each the total elapsed at the moment Lap was tapped),
  /// in tap order.
  final List<Duration> laps;

  /// The resting state of a never-started / freshly-reset stopwatch.
  static const idle = StopwatchState(
    startedAt: null,
    accumulatedMs: 0,
    isRunning: false,
    laps: [],
  );

  /// Total elapsed at [now], via the pure clock-math helper. Running adds the
  /// live segment; paused/idle returns the banked total independent of [now].
  Duration elapsedAt(DateTime now) => clock_math.stopwatchElapsed(
        startedAt: startedAt,
        accumulatedMs: accumulatedMs,
        now: now,
      );

  /// Parse a persisted payload map. A missing/null record reads as [idle], so a
  /// fresh install and an explicit reset look the same.
  factory StopwatchState.fromPayload(Map<String, dynamic>? payload) {
    if (payload == null) return idle;
    final startedAtMs = payload['startedAt'] as int?;
    return StopwatchState(
      startedAt: startedAtMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(startedAtMs),
      accumulatedMs: (payload['accumulatedMs'] as num?)?.toInt() ?? 0,
      isRunning: payload['isRunning'] as bool? ?? false,
      laps: ((payload['laps'] as List?) ?? const [])
          .map((ms) => Duration(milliseconds: (ms as num).toInt()))
          .toList(growable: false),
    );
  }

  /// Serialize for [ClockDao.writeStopwatch].
  Map<String, dynamic> toPayload() => {
        'startedAt': startedAt?.millisecondsSinceEpoch,
        'accumulatedMs': accumulatedMs,
        'isRunning': isRunning,
        'laps': laps.map((d) => d.inMilliseconds).toList(),
      };
}
