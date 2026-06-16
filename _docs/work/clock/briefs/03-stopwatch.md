## Agent Brief

**Category:** enhancement
**Summary:** The single Stopwatch — `ModuleData` JSON persistence and a `StopwatchPane` (start / pause / lap / reset) whose displayed time survives backgrounding and cold start.

**Current behavior:**
After `02-clock-shell`, the Clock module has a tab host, a `ClockApi` whose `watchStopwatchRunning` returns a placeholder `false`, a `ClockRepository` skeleton, and a placeholder Stopwatch pane. No stopwatch state is persisted; nothing counts.

**Desired behavior:**
- A **single** stopwatch (no naming, no multiples) persists to the generic `ModuleData` JSON lane, keyed by the clock module id and a stopwatch entry key, as a record holding `startedAt` (wall-clock of the current run segment, null while paused), `accumulatedMs` (elapsed from prior segments), `isRunning`, and an ordered list of `laps`.
- **Start** (from idle/paused): set `startedAt = now`, `isRunning = true`, preserving `accumulatedMs`. **Pause**: `accumulatedMs += now − startedAt` (via clock-math), clear `startedAt`, `isRunning = false`. **Reset**: `accumulatedMs = 0`, `startedAt = null`, `isRunning = false`, `laps` cleared. **Lap**: append the current elapsed (via clock-math) to `laps`.
- The `StopwatchPane` shows elapsed time counting up via an **in-memory display ticker** (display only — the persisted truth is the timestamp record), the laps list, and start/pause/lap/reset controls. The displayed value is always derived by clock-math from the persisted record + `now`, so it is correct after backgrounding and after a cold start; the module's lifecycle hook re-syncs the ticker on resume.
- `watchStopwatchRunning` returns the real `isRunning` from the persisted record.
- The record is written only on transitions (start/pause/lap/reset), never per display frame.

**Key interfaces:**

- The clock persistence accessor — methods to stream and update the single stopwatch record in the `ModuleData` lane; payload shape `{ startedAt, accumulatedMs, isRunning, laps[] }`.
- `ClockRepository` — stopwatch methods (start / pause / lap / reset, watch the stopwatch state) and a real `watchStopwatchRunning()` derived from the record.
- `StopwatchPane` — replaces the placeholder; a `ConsumerWidget` reading the stopwatch-state provider plus an in-memory display ticker, firing actions through the repository.
- Consumes clock-math's `elapsed` for display, for `accumulatedMs` on pause, and for lap values.

**Acceptance criteria:**

- [ ] Starting persists `startedAt` and `isRunning = true`; the pane shows elapsed counting up.
- [ ] Pausing accumulates elapsed into `accumulatedMs` and stops counting; resuming continues from the accumulated value.
- [ ] Lap appends the current elapsed to `laps`; laps render in order.
- [ ] Reset zeroes elapsed and clears all laps.
- [ ] Displayed elapsed equals clock-math's `elapsed` for the persisted record at a given `now` (no independent record of truth).
- [ ] After a simulated cold start (re-reading the persisted record), a running stopwatch shows `accumulatedMs + (now − startedAt)` and a paused one shows `accumulatedMs`.
- [ ] `watchStopwatchRunning` reflects the persisted `isRunning`, updating the Brief card's stopwatch segment.
- [ ] The stopwatch is stored via the `ModuleData` lane — no new table, schema version unchanged.
- [ ] The persistence/repository is covered by in-memory-DB tests; the pane by a widget test with a fake repository (per the project's test patterns).

**Out of scope:**

- Multiple / named stopwatches — single only (PRD out of scope).
- Timers and Alarms — see `04`, `05`, `07`, `08`.
- `ClockApi` interface definition and Brief card wiring — done in `02-clock-shell.md`.

**Depends on:** 01-clock-math (consumes `elapsed`), 02-clock-shell (extends `ClockApi`/`ClockRepository`, replaces the placeholder pane)

**Runtime:** parallel-safe
