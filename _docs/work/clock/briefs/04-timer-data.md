## Agent Brief

**Category:** enhancement
**Summary:** The Timer data layer — a `Timers` table + additive migration, DAO/repository timer methods, and a `NotificationScheduler` seam over `flutter_local_notifications` for OS-scheduled completion notifications.

**Current behavior:**
After `02-clock-shell`, `watchRunningTimerCount` returns a placeholder zero, there is no `Timers` persistence, and nothing anywhere in the app schedules an OS notification. The Clock module has never registered a notification.

**Desired behavior:**
- A `Timers` table stores multiple concurrent, **ephemeral** countdowns: optional `label`, the configured `durationMs`, `endsAt` (set only while running), `remainingMs` (set only while paused), and a creation timestamp. running = `endsAt` set; paused = `endsAt` null and `remainingMs` set; finished = `endsAt` in the past. The schema version increments by one via an **additive** migration that creates the table and leaves existing data untouched.
- Repository timer methods: **create-and-start** from a duration (compute `endsAt = now + duration`, insert, schedule an OS completion notification at `endsAt`); **pause** (compute `remainingMs` from `endsAt` via clock-math, clear `endsAt`, cancel the scheduled notification); **resume** (`endsAt = now + remainingMs`, clear `remainingMs`, reschedule); **cancel/dismiss** (delete the row, cancel the notification). A finished timer (`endsAt` past) remains until dismissed, then its row is deleted.
- `watchRunningTimerCount` returns the count of timers with `endsAt` in the future. The running list streams ordered by soonest `endsAt`, then creation time.
- A `NotificationScheduler` interface abstracts OS scheduling: schedule a one-shot notification at an absolute time with a payload, and cancel by id. The real implementation uses `flutter_local_notifications` (+ `timezone`) scheduled exact-while-idle so it fires when the app is backgrounded or dead. A timer completion is a **high-priority heads-up notification** (with Dismiss / +1 min actions) — **not** a full-screen takeover. `POST_NOTIFICATIONS` is requested **contextually on first timer creation**; if denied, the timer still runs and an in-app warning surfaces. A boot receiver re-registers pending timer completions after device restart.
- The scheduler interface is the seam the repository depends on, provided behind a provider so the repository's scheduling behavior is testable with a **fake scheduler**.

**Key interfaces:**

- `Timers` table — `label?`, `durationMs`, `endsAt` (nullable), `remainingMs` (nullable), `createdAt`. Schema version + 1 via an additive migration creating the table.
- The clock DAO — timer queries: watch running/all timers (ordered), insert, set `endsAt`/`remainingMs`, delete; the running-timer count.
- `NotificationScheduler` — `schedule(id, at, payload)` / `cancel(id)`; real `flutter_local_notifications` + `timezone` implementation (heads-up, exact-while-idle, boot reschedule, contextual permission). Behind a provider so it can be overridden with a fake.
- `ClockRepository` — create/start, pause, resume, cancel timer; real `watchRunningTimerCount`; coordinates the DAO + `NotificationScheduler` + clock-math.
- `pubspec` gains `flutter_local_notifications` + `timezone`; the Android manifest gains the notification + boot-receiver entries timers need.

**Acceptance criteria:**

- [ ] Creating a timer inserts a row with `endsAt = now + duration` and schedules a notification at `endsAt` (asserted via a fake `NotificationScheduler`).
- [ ] Pausing sets `remainingMs` (= remaining via clock-math), clears `endsAt`, and cancels the scheduled notification; resuming sets `endsAt = now + remainingMs` and reschedules.
- [ ] Cancelling a timer deletes the row and cancels its notification.
- [ ] Multiple timers run concurrently; the running list is ordered by soonest `endsAt`.
- [ ] `watchRunningTimerCount` counts only timers with `endsAt` in the future and updates the Brief card's timer segment.
- [ ] The migration is additive (creates the `Timers` table), bumps the version by one, and preserves existing data (migration test in the style of the existing one).
- [ ] The DAO is covered by in-memory-DB tests; the repository's scheduling coordination is covered with a fake `NotificationScheduler`.
- [ ] A finished timer (`endsAt` in the past) is excluded from the running count and persists until dismissed.

**Out of scope:**

- The `TimerPane` UI (duration entry, running list, ringing state) — see `05-timer-ui.md`.
- Full-screen-intent scheduling and alarm reboot behavior — `07-alarm-data.md` extends the scheduler for that.
- Persistent/reusable timers (idle state, pin/rearrange) — PRD out of scope.
- Real OS firing while the app is dead / heads-up appearance — verified manually on the emulator, not by automated criteria here.

**Depends on:** 01-clock-math (remaining, for pause/resume), 02-clock-shell (extends the `ClockApi`/`ClockRepository` introduced there)

**Runtime:** parallel-safe
