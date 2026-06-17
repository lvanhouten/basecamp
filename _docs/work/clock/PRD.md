# Clock Module — PRD

The Clock **Module** and its three **Tools** — **Stopwatch**, **Timer**, and
**Alarms**. Design grilled out in conversation; vocabulary follows
[`_docs/CONTEXT.md`](../../CONTEXT.md), behaviour follows
[`_docs/features/clock/README.md`](../../features/clock/README.md), and the
two load-bearing decisions are recorded in
[ADR-0003](../../adr/0003-flutter-local-notifications-clock-foundation.md)
(scheduling/notification foundation) and
[ADR-0004](../../adr/0004-clock-multi-activity-resume.md) (how Clock surfaces on
the Brief).

## Problem Statement

Basecamp has no single home for everyday time tools. To set a countdown while
cooking, time an open-ended activity, or wake up in the morning, the user leaves
their life-tracker hub for separate apps. The Clock module already exists as an
empty stub (three placeholder tabs); none of its tools work.

These tools also carry a hard requirement ordinary screens don't: they must keep
**correct time across backgrounding and process death**, and **Alarms must ring
even when Basecamp's process is dead and survive a device reboot.** A naive
"count down in memory" implementation silently breaks the moment Android freezes
or kills the app — which is exactly when the user is relying on it.

## Solution

A working Clock module, reachable from the hub drawer and summarized on the
Brief, with three Tools:

- **Stopwatch** — one stopwatch: start / pause / resume / lap / reset, counting up
  open-endedly. Keeps correct elapsed time across background and cold start.
- **Timer** — multiple concurrent countdowns. Enter a duration, it runs; it
  notifies when it finishes even if the app is backgrounded; remaining time stays
  correct across background/kill.
- **Alarms** — ring at a wall-clock time, one-off or on chosen weekdays. When an
  alarm fires it opens Basecamp **full-screen** to that alarm so the user can
  **Snooze** or **Dismiss**. Alarms fire even when the app is dead and survive a
  reboot.

The Brief's Clock card shows what's live ("2 alarms today · 1 timer running ·
stopwatch running") and tapping it opens Clock to the most relevant Tool. Because
the source of truth is timestamps persisted in Drift (never ticking state),
correctness across cold start falls out for free.

The build is **phased** (each phase reuses the previous one's foundation):
**Phase 1 Stopwatch → Phase 2 Timer → Phase 3 Alarms.**

## User Stories

**Stopwatch**

1. As a Basecamp user, I want to start a stopwatch, so that I can time an activity as it happens.
2. As a user, I want to pause and resume the stopwatch, so that I can stop timing during interruptions without losing accumulated time.
3. As a user, I want to record laps, so that I can mark split times within one timing session.
4. As a user, I want to reset the stopwatch (clearing laps), so that I can start a fresh timing session.
5. As a user, I want the stopwatch to keep counting correctly while Basecamp is backgrounded, so that switching apps doesn't distort the time.
6. As a user, I want the stopwatch to still show the correct elapsed time after the app has been killed and reopened, so that I can trust it for long sessions.

**Timer**

7. As a user, I want to start a countdown by entering a duration, so that I'm reminded when a set amount of time has passed.
8. As a user, I want to run several countdowns at the same time, so that I can track multiple things at once (e.g. laundry and tea).
9. As a user, I want to optionally label a timer, so that I can tell concurrent countdowns apart.
10. As a user, I want to see the remaining time on each running timer, so that I know how long is left.
11. As a user, I want to pause and resume a timer, so that I can hold a countdown without losing my place.
12. As a user, I want to cancel a timer, so that I can remove a countdown I no longer need.
13. As a user, I want to be notified when a timer finishes even if the app is backgrounded or closed, so that I don't miss it.
14. As a user, I want a finished timer to show as a heads-up notification (with Dismiss / +1 min) rather than seizing my locked screen, so that a kitchen timer doesn't behave like an alarm.
15. As a user, I want a timer's remaining time to stay correct across backgrounding and cold start, so that the countdown is trustworthy.
16. As a user, I want a running timer's completion to still fire after a device reboot, so that a restart doesn't silently drop it.

**Alarms**

17. As a user, I want to set a one-off alarm at a specific time, so that I'm woken or reminded once.
18. As a user, I want to set a recurring alarm on chosen days of the week, so that it rings every weekday morning (etc.) without re-creating it.
19. As a user, I want daily / weekdays / weekends presets over the weekday picker, so that common schedules are one tap.
20. As a user, I want to enable or disable an alarm from the Alarms screen, so that I can turn an alarm off without deleting it.
21. As a user, I want to label an alarm, so that I know what it's for ("Wake up", "Meds").
22. As a user, I want a ringing alarm to open Basecamp full-screen to that alarm, so that I can act on it immediately even from the lock screen.
23. As a user, I want to Snooze a ringing alarm, so that it stops now and re-rings after a short interval.
24. As a user, I want to Dismiss a ringing alarm, so that I end its current occurrence.
25. As a user, I want Dismissing a one-off alarm to spend it (it disables itself), while Dismissing a recurring alarm leaves it armed for its next occurrence, so that I don't accidentally kill a recurring schedule by turning off today's ring.
26. As a user, I want alarms to ring even when Basecamp's process is dead, so that I can rely on them to wake me.
27. As a user, I want alarms to survive a device reboot, so that a restart overnight doesn't make me oversleep.
28. As a user, I want to see how many alarms are set for today, so that I know what's coming.
29. As a user, I want an alarm to ring over the lock screen, so that a locked phone still wakes me.

**Brief & navigation (cross-cutting)**

30. As a user, I want the Brief's Clock card to show how many alarms are set today, how many timers are running, and whether the stopwatch is running, so that I see Clock's live state at a glance.
31. As a user, I want tapping the Clock card to open the Tool I'm most likely to need to act on (Stopwatch, then Timer, then Alarms), so that the open-ended stopwatch I forgot about is one tap away.
32. As a user, I want Clock to open to Alarms when nothing is live, so that cold-opening Clock lands on the most common reason to be there.
33. As a user, I want to switch between Stopwatch, Timer, and Alarms via tabs, so that all three Tools are in one place.
34. As a user, I want all Clock data to survive a cold start, so that running timers, a running stopwatch, and my alarms are all intact after the app restarts.

**Permissions**

35. As a user, I want to be asked for notification permission the first time I create a timer or alarm, so that the request has context rather than appearing on first launch.
36. As a user, I want to be warned in-app if I've denied notifications, so that I understand why an alarm might be silent.

## Implementation Decisions

### Architecture & phasing

- Follows the established module pattern (ADR-0001): Drift tables → `@DriftAccessor`
  DAO → repository implementing a narrow `XApi` → Riverpod providers → a
  `ConsumerWidget` screen carrying the hub drawer. Clock is **one** `AppModule`
  (already present); its three Tools are tabs within one screen — they are not
  Modules and never reach each other except through `core/`.
- **Phased build**, each reusing the prior foundation: **Stopwatch** (timestamp +
  resume, no OS deps) → **Timer** (adds OS-scheduled notifications) → **Alarms**
  (adds repeat, full-screen ring, reboot survival).
- **Source of truth is persisted timestamps, never ticking state** (clock README).
  Display ticking is an in-memory `Timer.periodic` for the visible counter only;
  the database holds `startedAt` / `endsAt` and the UI recomputes from wall-clock.
  This is what makes background/kill survival free.

### Deep modules (pure, OS-free, the primary test targets)

- **Clock math** — pure functions over injected `now`:
  `elapsed(startedAt, accumulatedMs, isRunning, now)` and
  `remaining(endsAt, now)` (and paused-remaining). Encapsulates all
  pause/resume/accumulate arithmetic behind a tiny, stable, deterministic interface.
- **Alarm recurrence** — pure functions:
  `nextOccurrence(timeOfDay, repeatDays, from) → DateTime` and
  `ringsToday(alarm, date) → bool`. The trickiest logic in the feature
  (weekday-mask evaluation, one-off-then-disable, midnight/DST edges); kept pure so
  it can be exhaustively tested without a device.
- **`NotificationScheduler`** — a thin interface over `flutter_local_notifications`
  (`schedule(id, at, payload)`, `scheduleFullScreen(id, at, payload)`,
  `cancel(id)`). Isolates the ADR-0003 plugin behind a seam so the repository is
  testable with a fake, and the volatile OS dependency lives in one swappable place.

### Persistence (per [CLAUDE.md](../../../CLAUDE.md) hard rule #4)

- **Stopwatch** — single instance, only ever loaded whole → the generic `ModuleData`
  JSON lane (no migration; `ModuleData` already exists, so the Stopwatch phase ships
  with **schemaVersion unchanged at 2**). One row keyed `moduleId='clock'`,
  `entryKey='stopwatch'`, payload `{ startedAt, accumulatedMs, isRunning, laps[] }`.
  Laps inline; reset clears them. Written only on transitions (start/stop/lap/reset),
  not per display frame. This is the app's first use of the `ModuleData` lane.
- **Timer** — multiple, queried by `endsAt` → a real table (additive migration to
  **schemaVersion 3**):

  ```
  Timers: id · label? · durationMs · endsAt (DateTime?, set only while running)
        · remainingMs (int?, set only while paused) · createdAt
  running = endsAt != null ; paused = endsAt == null && remainingMs != null
  finished = endsAt in the past (ringing until dismissed, then the row is deleted)
  ```

  Ordering: running timers by soonest `endsAt`, others by `createdAt`. Ephemeral:
  there is no idle/persistent state — dismissing removes the row.
- **Alarms** — queried by time/weekday/enabled → a real table (additive migration to
  **schemaVersion 4**):

  ```
  Alarms: id · time (minutes-since-midnight) · enabled · repeatDays (7-bit weekday mask)
        · label? · createdAt
  one-off = repeatDays == 0 (fires at the next occurrence of `time`, then disables)
  recurring = any subset of weekday bits ("daily" = all 7)
  ```

  Per-alarm config (chime / snooze interval / dismiss method) is **deferred** and
  lands as additive columns when built.

### Public contract — `ClockApi` (pull side)

Three reactive Drift streams, mirroring `ListsApi`:

```dart
abstract interface class ClockApi {
  Stream<int>  watchTodaysAlarmCount();   // enabled alarms scheduled to ring today
  Stream<int>  watchRunningTimerCount();  // timers with endsAt in the future
  Stream<bool> watchStopwatchRunning();   // is the stopwatch counting
}
```

`watchTodaysAlarmCount` = enabled alarms whose weekday-mask includes today
(recurring) or whose time-of-day is still ahead today (one-off). The Brief reads
all three and re-renders for free.

### Brief & navigation (ADR-0004)

- Clock card renders the three counts as a phrase (e.g. "2 alarms today · 1 timer
  running · stopwatch running"); each count phrased precisely (no uniform "Active
  N" label — `Enabled` is the glossary term and "active" is avoided).
- Tapping opens Clock to a Tool tab by fixed precedence among what's **live**:
  **Stopwatch > Timer > Alarm**; **Alarms** is the default when nothing is live.
- The active tab is derived from live domain state on entry-via-card; a manual tab
  choice still persists within a session via the kept-alive `IndexedStack`.
- A module may own **several** In-progress activities (glossary relaxed); Alarms are
  scheduled future state and are **never** a Resume target.

### Push side — events

`TimerFinished` / `AlarmFired` are **not built** (no consumer; Workouts is a stub).
Clock needs no event internally — a finishing timer flips to "ringing" via the
in-memory ticker (foreground) or recomputes from `endsAt` on resume
(background/dead), and the Brief updates via the `ClockApi` streams. Mint the event
with its consumer when Workouts lands.

### OS scheduling, notifications & permissions (ADR-0003)

- Foundation is **`flutter_local_notifications` + `timezone`** — *not*
  `android_alarm_manager_plus`. Notifications are scheduled with the OS at the moment
  a timer starts / an alarm is set (`zonedSchedule`, `exactAllowWhileIdle`) so they
  fire while the app is dead.
- **Timer completion** = high-priority **heads-up** notification (Dismiss / +1 min),
  using the timer notification channel's sound. Not full-screen.
- **Alarm firing** = **full-screen intent**: launches the app to the alarm's ringing
  screen (over the lock screen) carrying the alarm `id` in the payload; on cold launch
  the app reads `getNotificationAppLaunchDetails()` and routes to that alarm. The
  ringing screen plays the **single bundled default chime on a loop** via an audio
  package until Snooze/Dismiss (a one-shot notification sound is not a real alarm).
  Snooze/Dismiss logic runs in the foreground once the app is open — hence no need for
  background-Dart.
- **Snooze** = fixed global 9 min (re-schedules the same alarm 9 min out). **Dismiss**
  = end this occurrence (one-off → set `enabled = false`; recurring → leave armed).
  Repository actions are pre-shaped as `snooze(id, minutes)` and `dismiss(id)` so
  per-alarm snooze and a dismiss challenge become caller/UI additions, not data rewrites.
- Toggling an alarm's **Enabled** off **cancels** its scheduled OS notification(s); on
  reschedules them. The switch drives `flutter_local_notifications` registration.
- **Reboot**: register the plugin's boot receiver (`RECEIVE_BOOT_COMPLETED`) so
  scheduled alarms — and running timers' completion notifications — are re-registered
  after a restart (Android drops scheduled alarms on reboot otherwise).
- **Manifest**: `USE_EXACT_ALARM` (auto-granted; appropriate because Clock genuinely
  is an alarm app and Basecamp is not Play-published), plus `SCHEDULE_EXACT_ALARM`
  `maxSdkVersion="32"` for Android 12, `USE_FULL_SCREEN_INTENT`, and
  `RECEIVE_BOOT_COMPLETED`.
- **`POST_NOTIFICATIONS`** (Android 13+) is requested **contextually on first
  Timer/Alarm creation**, not on launch; if denied, scheduling still proceeds and the
  app surfaces an in-app warning (an alarm with no notification is silent).

### Lifecycle

- An `AppLifecycleListener` re-syncs the in-memory display tickers on resume by
  recomputing from persisted timestamps; because state is written on transitions,
  there is little to flush on pause. Resume correctness is otherwise automatic via the
  Drift streams.

## Testing Decisions

A good test asserts **external behaviour, not implementation details** — the value a
caller observes (computed elapsed/remaining, the next fire time, what the DAO emits,
what the repository told the scheduler to do, what the UI shows), never private fields
or call internals. Tests inject `now` rather than reading the wall clock so they're
deterministic. Testing mirrors the **four levels already used by Lists**, plus one new
seam (the scheduler fake), and is delivered **per phase** alongside the tool it covers.

- **Pure-logic unit tests** (prior art: `test/lists/apply_reorder_test.dart`):
  - **Clock math** — `elapsed`/`remaining` across running, paused, post-reset, and
    boundary inputs.
  - **Alarm recurrence** — `nextOccurrence`/`ringsToday` across one-off, each weekday
    subset, "today but already past", week-wraparound, and midnight edges. Highest value.
- **DAO tests** (prior art: `test/lists/lists_dao_test.dart`, in-memory
  `AppDb.forTesting(NativeDatabase.memory())`):
  - `ClockDao` — timer insert/pause/resume/delete and ordering; alarm
    insert/enable/disable/delete; stopwatch save/load round-trip; and the three
    `ClockApi` count queries (`watchTodaysAlarmCount`, `watchRunningTimerCount`,
    `watchStopwatchRunning`) under representative data.
- **Repository + fake `NotificationScheduler`** (new seam; in-memory Drift + a recording
  fake): starting a timer schedules a notification at `endsAt`; cancelling cancels it;
  dismissing a one-off alarm cancels its notification **and** sets `enabled = false`;
  dismissing a recurring alarm cancels this occurrence but leaves it enabled; toggling
  `enabled` cancels/reschedules; snooze reschedules 9 min out. This is the
  highest-risk coordination logic.
- **Pane widget tests** (prior art: `test/lists/lists_screen_test.dart`, `ProviderScope`
  with a **fake `ClockRepository`** that emits via a `StreamController` and records
  calls): stopwatch start/pause/lap/reset wiring; adding and cancelling a timer; the
  alarm list enable toggle; and the ringing screen's **Snooze** and **Dismiss** invoking
  the right repository calls.
- **Migration tests** (prior art: `test/lists/migration_v1_to_v2_test.dart`): v2→v3
  (Timers table added) and v3→v4 (Alarms table added) are additive and preserve existing
  data.

## Out of Scope

- **Persistent / reusable Timers** ("timer library", idle state, pin/rearrange) — Phase
  2 ships ephemeral timers only. Future enhancement.
- **Per-alarm chime selection** and a chime picker / multiple bundled chimes / device
  ringtones — v1 ships a single bundled default chime (played looping). Future enhancement.
- **Per-alarm snooze interval + snooze-time pick-list** — v1 uses a fixed global 9 min.
  Future enhancement.
- **Dismiss challenges** (solve `X × Y + Z` to Dismiss, per-alarm difficulty, other
  challenge types) — v1 Dismiss is the immediate big button. Future enhancement.
- **`TimerFinished` / `AlarmFired` events** — deferred until a real consumer (Workouts)
  exists.
- **Multiple concurrent stopwatches** — a single stopwatch only.
- **iOS** — code is cross-platform, but the Android alarm/permission/manifest plumbing
  and any iOS-specific reliability work are out of scope here (no Mac to build).
- **Sync across devices** — Drift stays local-first.

## Further Notes

- The phasing is a genuine dependency chain, not just easy-to-hard: Stopwatch proves
  timestamp+resume with zero OS deps; Timer reuses that and introduces the OS scheduler;
  Alarms reuse the scheduler and add repeat + full-screen ring + reboot survival. Each
  phase is independently shippable.
- ADR-0003 originally implied continuous alarm audio was deferred entirely; this PRD
  clarifies that **looping playback of the single default chime is in v1 scope** (an
  alarm must actually ring) — only the *per-alarm chime picker* is deferred. ADR-0003's
  wording is updated to match.
- The clock README's "Critical implementation notes" (save timestamps, derive the rest;
  recompute on resume) remain the canonical implementation guidance.
