## Agent Brief

**Category:** enhancement
**Summary:** The `TimerPane` — create timers, see concurrent live countdowns, pause/resume/cancel, and a finished/ringing state.

**Current behavior:**
After `04-timer-data`, timers persist, schedule OS completion notifications, and stream as a running list ordered soonest-first, but the Timer tab is still the placeholder pane from `02-clock-shell`.

**Desired behavior:**
- The `TimerPane` replaces the placeholder. The user enters a duration (a duration picker / numeric entry) and an optional label to create-and-start a timer. Multiple running timers display as a list, each showing its label (if any) and live remaining time counting down (an in-memory display ticker derived from `endsAt` via clock-math). Each running timer offers pause, resume (when paused), and cancel.
- A finished timer (reached zero) shows a "time's up" / ringing state in the list with a Dismiss affordance; dismissing removes it.
- All displayed remaining values derive from the persisted `endsAt` + `now` (correct across backgrounding and cold start); the pane re-syncs on resume via the module lifecycle hook.
- Creating the first timer triggers the contextual notification-permission request (behavior owned by the repository/scheduler from `04`); if permission is denied, the pane surfaces the in-app warning.

**Key interfaces:**

- `TimerPane` — a `ConsumerWidget` reading the running-timers stream provider; fires create / pause / resume / cancel / dismiss through `ClockRepository` (from `04`).
- A duration-entry affordance and an optional label input for creating a timer.
- An in-memory display ticker per running timer (display only; truth is `endsAt`).

**Acceptance criteria:**

- [ ] Entering a duration creates and starts a timer that appears in the running list counting down.
- [ ] An optional label is shown on the timer when provided.
- [ ] Multiple timers run and display concurrently, ordered soonest-first.
- [ ] Pause halts the displayed countdown; resume continues it; cancel removes the timer.
- [ ] A timer that reaches zero shows a finished/ringing state with a Dismiss action that removes it.
- [ ] Displayed remaining equals clock-math's `remaining` for the timer's `endsAt` at a given `now`.
- [ ] The pane is covered by a widget test with a fake `ClockRepository` (emits a running-timers stream, records create/pause/resume/cancel calls), in the style of the existing screen tests.

**Out of scope:**

- Timer persistence, scheduling, the migration, and the scheduler seam — see `04-timer-data.md`.
- Heads-up notification appearance / firing while dead — owned by `04`; verified manually on the emulator.
- Alarms — see `07`, `08`.

**Depends on:** 04-timer-data (consumes the timer repository/providers and scheduling behavior)

**Runtime:** parallel-safe
