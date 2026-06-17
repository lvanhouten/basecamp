## Agent Brief

**Category:** enhancement
**Summary:** A pure, Flutter-free clock-math module: `elapsed` (stopwatch) and `remaining` (countdown) derived from persisted timestamps and an injected `now`.

**Current behavior:**
No shared time arithmetic exists anywhere. The Clock module is a stub and nothing computes elapsed or remaining time. The PRD's "persist timestamps, not ticking state" principle has no home, so the Stopwatch and Timer tools (later briefs) would each reinvent the same pause/resume/clamp arithmetic.

**Desired behavior:**
A pure module exposes deterministic functions that derive displayed time from persisted state plus an injected `now` (no internal wall-clock read), so they survive backgrounding/cold start by construction and are exhaustively unit-testable:

- **Stopwatch elapsed** — given `startedAt` (null while paused), `accumulatedMs` (sum of prior run segments), and `now`: while running (`startedAt` non-null) → `accumulatedMs + (now − startedAt)`; while paused → `accumulatedMs`.
- **Countdown remaining** — given `endsAt` and `now` → the remaining duration, clamped at zero (never negative) once `now ≥ endsAt`.
- **Paused-remaining helper** — `endsAt − now` clamped at zero, used to populate a countdown's stored remaining when it is paused.

**Key interfaces:**

- A pure function computing stopwatch elapsed from (`startedAt`, `accumulatedMs`, `now`) — returns a `Duration`.
- A pure function computing countdown remaining from (`endsAt`, `now`) — returns a non-negative `Duration`.
- A paused-remaining helper for the pause transition.
- The module lives on its own and imports neither Flutter nor Drift; it is unit-tested in isolation (style of the existing pure-helper tests in the lists feature).

**Acceptance criteria:**

- [ ] Running-stopwatch elapsed equals `accumulatedMs + (now − startedAt)` for `now ≥ startedAt`.
- [ ] Paused-stopwatch elapsed equals `accumulatedMs` and is independent of `now`.
- [ ] A just-reset stopwatch (`accumulatedMs` 0, not running) reports zero elapsed.
- [ ] Countdown remaining equals `endsAt − now` while `now < endsAt`.
- [ ] Countdown remaining clamps to zero (never negative) when `now ≥ endsAt`.
- [ ] The paused-remaining helper equals `endsAt − now` clamped at zero.
- [ ] Every function is pure (takes `now`, reads no wall clock) and is covered by unit tests across running / paused / expired / exact-boundary inputs.
- [ ] The module imports neither Flutter nor Drift.

**Out of scope:**

- Persistence, providers, and UI — see `02-clock-shell.md`, `03-stopwatch.md`, `04-timer-data.md`, `05-timer-ui.md`.
- Alarm next-occurrence / rings-today math — see `06-alarm-recurrence.md`.

**Depends on:** none

**Runtime:** parallel-safe
