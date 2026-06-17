# Clock

**Module:** `lib/features/clock/` · **Status:** Planned (stub screen) · **Nav label:** Clock

> Renamed from "Timers" (2026-06-15). **Clock** is the module; **Timer** is the
> countdown tool *inside* it (alongside Alarms and a Stopwatch). See
> [`_docs/CONTEXT.md`](../../CONTEXT.md).

## Purpose

Time tools in one place: **alarms**, a **countdown Timer**, and a **stopwatch**.
The tricky module — time-based state must survive the app being backgrounded or
killed, and alarms must fire even when the app's process is dead.

## Behaviour (intended)

- **Alarms** — set one-off / recurring alarms that ring even if Basecamp isn't running.
- **Timer** — countdown(s); survive backgrounding; notify on completion.
- **Stopwatch** — start/stop/lap; survive backgrounding.

## Data model (proposed — hybrid)

Store **timestamps, not ticking state.** A killed process can't keep counting;
recompute from wall-clock on resume.

- Timer: persist `endsAt` (= now + duration). Remaining = `endsAt - now`.
- Stopwatch: persist `startedAt` (+ accumulated, if paused). Elapsed = `now - startedAt`.
- Alarms (v1): `id · time · enabled · repeatDays (7-bit weekday mask) · label? · createdAt`. `time`, `enabled`, and `repeatDays` are real columns (queried: "alarms for today"); `label` is a simple nullable column. One-off = no days set (fires once, then disables itself); recurring = any subset of weekdays ("daily" = all 7). Per-alarm config (chime, snooze interval, dismiss method) is deferred — see Future Enhancements — and lands as additive columns when built.

## Critical implementation notes

- **Do NOT keep "4:32 remaining and counting" in state.** Save the timestamp; derive the rest. This is what makes background/kill survival free.
- **Alarms that must fire while the app is dead need the OS, not Dart.** Schedule via `flutter_local_notifications` (or `android_alarm_manager_plus`); the OS holds the schedule. The app just registers and forgets.
- Recompute timer/stopwatch on `AppLifecycleListener.onResume`; flush any unsaved state on `onPause`.

## Public contract — `ClockApi`

For the Brief, which renders three counts ("2 alarms today · 1 timer running ·
stopwatch running") and opens Clock to a tool by precedence (Stopwatch > Timer >
Alarm) on tap:

- `Stream<int> watchTodaysAlarmCount()` — enabled Alarms scheduled to ring today.
- `Stream<int> watchRunningTimerCount()` — Timers with `endsAt` in the future.
- `Stream<bool> watchStopwatchRunning()` — whether the Stopwatch is counting.

All three are reactive Drift streams (mirrors `ListsApi.watchOpenItemCount()`);
the Brief re-renders for free on any change — no events involved.

## Events — deferred

`TimerFinished` / `AlarmFired` were proposed with Workouts (rest-between-sets) as
a future consumer. **Not built:** there is no consumer yet (Workouts is a stub),
and Clock needs no event internally — a finishing Timer flips to "ringing" via the
in-memory ticker (foreground) or recomputes from `endsAt` on resume (background/
dead), while the Brief updates via the `ClockApi` streams above. Mint the event
(designed with its consumer) only when Workouts lands and needs the trigger.
Events are transient signals (hard rule #3) — don't add subscriber-less ones.

## Screens (planned)

- `clock_screen.dart` — currently a `DefaultTabController` with 3 stub tabs (Alarms / Timer / Stopwatch). Each tab becomes its real pane. Carries the hub navigation drawer.

## Open questions / ideas

- Notification permissions flow (Android 13+ runtime permission).
- Exact-alarm permission on recent Android (`SCHEDULE_EXACT_ALARM`).
- Sound/vibration selection per alarm.

## Future Enhancements

- **Persistent, reusable Timers ("timer library").** A Timer becomes a saved
  thing — `"Tea — 5:00"`, `"Workout rest — 90s"` — that lives in the list whether
  or not it's running, returning to an **idle** state when it finishes so it can be
  re-run. Adds an explicit idle state plus `remainingMs`/`position` columns and lets
  the existing **Pin**/**Rearrange** vocabulary apply to Timers. Deferred: the first
  Timer iteration ships **ephemeral** timers (enter a duration → it runs → dismiss
  removes it; a "recents" shortcut covers quick re-entry). Revisit once ephemeral
  timers are proven.

- **Per-alarm chime.** Each Alarm picks its own ring sound from a set (e.g. loud
  klaxon for wake-up, gentle chime for meds). Adds a `chime` field + a sound
  picker + a bundled chime set (and possibly device-ringtone access). v1 ships a
  single bundled default chime; playback already takes a chime id so this is
  additive.

- **Per-alarm snooze interval + snooze-time pick-list.** Each Alarm carries its
  own default snooze interval; the ringing screen's big Snooze button uses it, but
  the user can also pick a different interval from a list for a one-off snooze.
  Adds a `snoozeMinutes` column + the pick-list UI. v1 uses a fixed global 9-min
  snooze; `snooze(id, minutes)` already takes the interval so this is additive.

- **Dismiss challenges.** Per-alarm dismiss method beyond the immediate big button:
  solve a math problem `(X × Y + Z)` to dismiss (used to force genuine waking),
  with a per-alarm difficulty (operand size + number of problems), and room for
  other challenge types later. Snooze stays the easy button; the challenge gates
  Dismiss only. Adds a `dismissType` (+ difficulty) column and a challenge screen
  the UI inserts before the existing `dismiss(id)` call. v1 dismisses immediately.

## Changelog

- 2026-06-15 — Renamed module **Timers → Clock** (folder, `ClockScreen`, nav label, icon `Icons.schedule`); the Timer tool/tab and `TimerFinished` event keep their names. Still a stub.
- 2026-06-15 — Stub screen (3 empty tabs). Timestamp-based design + OS-notification approach documented here; not built.
