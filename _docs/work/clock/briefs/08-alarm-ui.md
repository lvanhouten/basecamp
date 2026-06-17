## Agent Brief

**Category:** enhancement
**Summary:** The `AlarmsPane` (list + editor) and the full-screen `AlarmRingingScreen` with Snooze / Dismiss.

**Current behavior:**
After `07-alarm-data`, alarms persist, schedule full-screen notifications, reschedule across reboot, and expose create / update / `setEnabled` / `snooze` / `dismiss` on the repository (with a looping default chime capability), but the Alarms tab is still the placeholder pane from `02-clock-shell` and there is no ringing screen.

**Desired behavior:**
- The `AlarmsPane` replaces the placeholder: a list of alarms each showing time, label (if any), a repeat summary ("Once" / "Daily" / "Weekdays" / "Weekends" / specific days), and an enable/disable **toggle** (the true on/off). The user can add an alarm and edit an existing one via an editor offering a time picker, a day-of-week selector with **Daily / Weekdays / Weekends presets** over the weekday mask, and an optional label. Deleting an alarm removes it.
- An `AlarmRingingScreen` presents a single ringing alarm full-screen with a large **Snooze** button (fixed 9-min) and a **Dismiss** button. It is reached when an alarm fires: the full-screen intent launches the app, and on (cold or warm) launch the app reads the firing notification's payload (the alarm id) and routes to the ringing screen for that alarm. The screen plays the looping default chime (capability from `07`) until the user acts; Snooze calls `snooze(id, 9)`, Dismiss calls `dismiss(id)`.
- If notification permission is denied, the `AlarmsPane` surfaces the in-app warning that alarms will be silent.

**Key interfaces:**

- `AlarmsPane` — a `ConsumerWidget` reading the alarms stream provider; the toggle calls `setEnabled`; add/edit via an editor; delete through the repository.
- An alarm editor — time picker, weekday selector + Daily/Weekdays/Weekends presets (writing the 7-bit mask), optional label.
- `AlarmRingingScreen` — shows one alarm; Snooze (→ `snooze(id, 9)`) and Dismiss (→ `dismiss(id)`); plays the looping chime.
- Launch-from-notification routing — reads the firing notification payload (alarm id) and opens the ringing screen for that alarm.

**Acceptance criteria:**

- [ ] The `AlarmsPane` lists alarms with time, label, repeat summary, and an enable toggle; toggling calls `setEnabled`.
- [ ] Adding an alarm via the editor (time + weekday mask via picker/presets + optional label) persists it; editing updates it; deleting removes it.
- [ ] Daily / Weekdays / Weekends presets set the correct weekday bits; "Once" (no days) yields a one-off.
- [ ] The `AlarmRingingScreen` shows a ringing alarm with large Snooze and Dismiss buttons; Snooze invokes `snooze(id, 9)`, Dismiss invokes `dismiss(id)`.
- [ ] Routing from a firing notification opens the ringing screen for the alarm identified by the payload.
- [ ] If notification permission is denied, the pane surfaces the in-app warning.
- [ ] The panes/screens are covered by widget tests with a fake `ClockRepository` (emits an alarms stream, records `setEnabled`/create/`snooze`/`dismiss` calls), in the style of the existing screen tests.

**Out of scope:**

- Alarm persistence, scheduling, the scheduler full-screen/reboot capability, the looping-chime capability, and manifest permissions — see `07-alarm-data.md`.
- Recurrence math — see `06-alarm-recurrence.md`.
- Dismiss challenges (math), per-alarm chime/snooze config — PRD out of scope.
- Real OS full-screen launch while the device is locked / from a dead process — verified manually on the emulator.

**Depends on:** 07-alarm-data (consumes the alarm repository/providers, scheduler routing, and looping-chime capability)

**Runtime:** parallel-safe
