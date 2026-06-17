## Agent Brief

**Category:** enhancement
**Summary:** The Alarm data layer — an `Alarms` table + additive migration, DAO/repository methods with snooze/dismiss/enable semantics, full-screen-intent + reboot scheduling, manifest permissions, and a looping default chime.

**Current behavior:**
After `02-clock-shell`, `watchTodaysAlarmCount` returns a placeholder zero and no `Alarms` persistence exists. After `04-timer-data`, a `NotificationScheduler` exists for one-shot heads-up timer notifications but has no full-screen-intent, repeating, or reboot capability. The alarm-recurrence math (`06`) exists but nothing uses it.

**Desired behavior:**
- An `Alarms` table stores: `time` (minutes since midnight), `enabled`, a 7-bit weekday `repeatDays` mask, optional `label`, and a creation timestamp. one-off = mask 0; recurring = any weekday subset. The schema version increments by one via an **additive** migration creating the table.
- Repository alarm methods:
  - **create/update** an alarm (time, weekday mask, label) — when enabled, schedule its OS notification(s) using `06`'s next-occurrence / per-weekday schedule (recurring → one notification per selected weekday; one-off → a single scheduled notification).
  - **setEnabled(id, bool)** — enabling schedules; disabling cancels the alarm's scheduled notification(s). This is the true on/off.
  - **snooze(id, minutes)** — schedule the alarm to re-fire `minutes` from now (v1 callers pass a fixed 9). The signature carries the interval so per-alarm / pick-list snooze is a later caller-only change.
  - **dismiss(id)** — end the current occurrence: cancel the current ring; a **one-off becomes disabled** (`enabled = false`); a **recurring stays enabled** with its next occurrence still scheduled.
- `watchTodaysAlarmCount` returns the count of enabled alarms due to ring today (via `06`'s rings-today / weekday-today test, including one-offs still ahead).
- The `NotificationScheduler` gains a **full-screen-intent** scheduling variant for alarms (launches the app over the lock screen; payload carries the alarm id) and **reboot rescheduling** for alarms (boot receiver re-registers enabled alarms). The Android manifest gains `USE_EXACT_ALARM` (+ `SCHEDULE_EXACT_ALARM` `maxSdkVersion="32"`), `USE_FULL_SCREEN_INTENT`, and `RECEIVE_BOOT_COMPLETED`. A single bundled default **chime** asset is added with a looping-playback capability the ringing screen (`08`) drives until Snooze/Dismiss.
- All scheduling goes through the `NotificationScheduler` seam so the repository's behavior (what is scheduled/cancelled on create / enable / disable / snooze / dismiss) is testable with a fake.

**Key interfaces:**

- `Alarms` table — `timeOfDayMinutes`, `enabled`, `repeatDays` (7-bit mask), `label?`, `createdAt`. Schema version + 1 via an additive migration creating the table.
- The clock DAO — alarm queries: watch all alarms (for the list), insert/update, `setEnabled`, delete; the today-due count built on `06`.
- `NotificationScheduler` — extended with a full-screen scheduling variant and alarm reboot rescheduling (in addition to `04`'s one-shot `schedule`/`cancel`).
- `ClockRepository` — create/update alarm, `setEnabled`, `snooze(id, minutes)`, `dismiss(id)` with one-off-disable / recurring-stay-armed semantics; real `watchTodaysAlarmCount`; coordinates the DAO + scheduler + `06`'s recurrence.
- A bundled default chime asset + a looping-playback capability; the manifest permission entries above.

**Acceptance criteria:**

- [ ] Creating an enabled recurring alarm schedules one notification per selected weekday at its time-of-day; a one-off schedules a single notification at its next occurrence (asserted via a fake scheduler using `06`'s schedule).
- [ ] Disabling an alarm cancels its scheduled notification(s); re-enabling reschedules them.
- [ ] `snooze(id, minutes)` schedules the alarm to re-fire `minutes` from now.
- [ ] `dismiss(id)` on a one-off sets `enabled = false` and cancels its ring; `dismiss(id)` on a recurring leaves it enabled with its next occurrence still scheduled.
- [ ] `watchTodaysAlarmCount` counts enabled alarms due today (recurring with today's bit set, or one-off still ahead) and updates the Brief card's alarm segment.
- [ ] The migration is additive (creates the `Alarms` table), bumps the version by one, and preserves existing data (migration test).
- [ ] Alarm scheduling uses the full-screen-intent variant with the alarm id in the payload; the manifest declares `USE_EXACT_ALARM` (+ `SCHEDULE_EXACT_ALARM` `maxSdkVersion="32"`), `USE_FULL_SCREEN_INTENT`, and `RECEIVE_BOOT_COMPLETED`.
- [ ] The DAO is covered by in-memory-DB tests; the repository's scheduling / snooze / dismiss / enable coordination is covered with a fake `NotificationScheduler`.
- [ ] A bundled default chime exists and the looping-playback capability is wired for the ringing screen to use.

**Out of scope:**

- The `AlarmsPane` list/editor and the `AlarmRingingScreen` UI + launch-from-notification routing — see `08-alarm-ui.md`.
- Per-alarm chime selection/picker, per-alarm snooze interval + pick-list, dismiss challenges — PRD out of scope (the snooze/dismiss signatures here are pre-shaped for them).
- Real OS firing while dead / ring-over-lockscreen / survives-reboot — verified manually on the emulator, not by automated criteria here.

**Depends on:** 02-clock-shell (extends `ClockApi`/`ClockRepository`), 04-timer-data (consumes and extends the `NotificationScheduler` seam), 06-alarm-recurrence (consumes next-occurrence / rings-today)

**Runtime:** parallel-safe
