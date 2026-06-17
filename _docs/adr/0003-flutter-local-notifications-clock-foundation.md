---
status: accepted
date: 2026-06-16
deciders: Development
---

# `flutter_local_notifications` as the Clock scheduling/notification foundation

Clock's **Timer** and **Alarms** must notify or ring at a wall-clock time even
when Basecamp is backgrounded or its process is killed; Alarms must additionally
survive a device reboot and ring over the lock screen. A Dart-side ticker can't
fire when the process is frozen or dead, so completion/ring has to be **scheduled
with the OS ahead of time**. We use **`flutter_local_notifications` (+ `timezone`)**
as the single OS scheduling + notification foundation for both tools, and
deliberately do **not** use `android_alarm_manager_plus`.

## Decision Drivers

- Notifications must fire when the app is backgrounded or process-killed → the OS,
  not Dart, must hold the schedule.
- Alarms must survive device reboot and present full-screen over the lock screen
  with Snooze / Dismiss.
- We only ever need to **display a notification, ring, and route into the app on
  tap** — never to run arbitrary Dart at fire time while the app is dead. The
  Snooze/Dismiss logic runs in the foreground once the full-screen intent opens
  the app (see ADR-0004 / `clock` README).
- Personal, **non-Play-published** app → can declare `USE_EXACT_ALARM` with no
  Play policy review, turning exact-alarm scheduling into a one-line manifest entry.

## Considered Options

- **`flutter_local_notifications` (+ `timezone`) (chosen)** — `zonedSchedule` at an
  absolute time with `exactAllowWhileIdle`; full-screen intent for alarms;
  repeating schedules per weekday; reschedules across reboot via a manifest boot
  receiver.
- **`android_alarm_manager_plus`** — schedules a Dart callback in a background
  isolate at the fire time; you then build and show the notification yourself.
- **Both together** — alarm-manager to wake the isolate, local-notifications to
  display.

## Pros and Cons

### `flutter_local_notifications` (chosen)

- ✓ The OS holds the schedule and fires it while the app is dead — no background
  isolate needed.
- ✓ First-class full-screen intent, custom sound/channels, per-weekday repeat,
  boot rescheduling.
- ✗ Continuous ringing isn't the notification's job — the launched alarm screen
  must play looping audio itself.
- ✗ Can't run logic at fire time while the app stays dead (we don't need to).

### `android_alarm_manager_plus`

- ✓ Runs real Dart in a background isolate at the fire time.
- ✗ More moving parts (isolate entrypoint, plugin re-registration) and a more
  failure-prone path, for a capability we don't use — we notify and ring, we don't
  compute while dead.

### Both

- ✗ Strictly more complexity than the chosen option, with no added capability for
  our use cases.

## Consequences

- The Android manifest carries `USE_EXACT_ALARM` (+ `SCHEDULE_EXACT_ALARM`
  `maxSdkVersion="32"`), `USE_FULL_SCREEN_INTENT`, `RECEIVE_BOOT_COMPLETED`, and the
  plugin's scheduled-notification boot receiver.
- `timezone` is initialized at startup; schedules are computed in the local zone.
- A finishing **Timer** is a high-priority **heads-up** notification (Dismiss / +1
  min) — *not* a lock-screen takeover. Only **Alarms** use the full-screen intent.
- `POST_NOTIFICATIONS` (Android 13+) is requested contextually on first Timer/Alarm
  creation; denial means a silent alarm, surfaced as an in-app warning.
- Continuous alarm audio is played by the launched full-screen screen (an audio
  package) on a loop until Snooze/Dismiss, not by the notification (a one-shot
  notification sound isn't a real alarm). v1 loops the **single bundled default
  chime**; only the per-alarm chime *picker* is deferred.
- If we ever need to execute Dart at fire time while the app stays dead, revisit
  `android_alarm_manager_plus`.

## Links

- Related: ADR-0004 (how the resulting live activities surface on the Brief)
