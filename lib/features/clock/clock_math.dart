/// Pure clock arithmetic for the Clock module's time tools (Stopwatch & Timer).
///
/// Every function here derives *displayed* time from **persisted state plus an
/// injected `now`** — none of them read the wall clock themselves. That is the
/// whole point: per the PRD ("store timestamps, not ticking state") and ADR-0004,
/// a killed process can't keep counting, so elapsed/remaining are recomputed from
/// stored timestamps on resume. Because `now` is a parameter, these functions are
/// deterministic and exhaustively unit-testable (running / paused / expired /
/// exact-boundary), and they survive backgrounding & cold start by construction.
///
/// This module is intentionally Flutter-free and Drift-free — it is plain
/// `dart:core` (`Duration`/`DateTime`) so it can be tested in isolation, in the
/// style of `lib/features/lists/data/apply_reorder.dart`. The Stopwatch
/// (`03-stopwatch`) and Timer (`04-timer-data`) tools call these; they never
/// reinvent the pause/resume/clamp math.
library;

/// Stopwatch elapsed time.
///
/// Given the persisted stopwatch state and an injected [now]:
///   - **running** ([startedAt] non-null) → `accumulatedMs + (now − startedAt)`,
///     i.e. the time banked from prior run segments plus the current live segment.
///   - **paused** ([startedAt] null) → `accumulatedMs` alone, independent of [now].
///
/// [accumulatedMs] is the sum of completed run segments, in milliseconds (matches
/// how it is persisted). A freshly reset, not-running stopwatch (`accumulatedMs`
/// 0, [startedAt] null) reports [Duration.zero].
///
/// Callers should only invoke this with `now >= startedAt`; while running this is
/// always true because `startedAt` was stamped in the past. The live segment is
/// not clamped — a stopwatch counts up without bound.
Duration stopwatchElapsed({
  required DateTime? startedAt,
  required int accumulatedMs,
  required DateTime now,
}) {
  final accumulated = Duration(milliseconds: accumulatedMs);
  if (startedAt == null) {
    // Paused: only the banked segments count; `now` is irrelevant.
    return accumulated;
  }
  // Running: banked segments + the current live segment.
  return accumulated + now.difference(startedAt);
}

/// Countdown remaining time, clamped at zero.
///
/// Returns `endsAt − now` while `now < endsAt`, and [Duration.zero] once
/// `now >= endsAt` (the boundary instant and anything past it read as expired —
/// remaining is never negative). This is what the Timer tool renders.
Duration countdownRemaining({
  required DateTime endsAt,
  required DateTime now,
}) {
  final remaining = endsAt.difference(now);
  // Never report a negative countdown: an elapsed/expired timer shows 00:00.
  return remaining.isNegative ? Duration.zero : remaining;
}

/// Remaining duration to persist when a countdown is **paused**.
///
/// Same arithmetic as [countdownRemaining] (`endsAt − now`, clamped at zero): at
/// the moment of the pause transition this captures how much was left, so it can
/// be stored and later turned back into a fresh `endsAt = resumedAt + remaining`
/// on resume (the Timer tool's job). Kept as its own named helper so the pause
/// transition reads intentionally at the call site.
Duration pausedRemaining({
  required DateTime endsAt,
  required DateTime now,
}) {
  return countdownRemaining(endsAt: endsAt, now: now);
}
