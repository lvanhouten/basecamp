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
- Alarms: `id`, `time`, `repeatRule`, `enabled`. Time/enabled are real columns (queried: "alarms for today"); label/sound/color can ride in a JSON payload (`ModuleData`) or extra columns.

## Critical implementation notes

- **Do NOT keep "4:32 remaining and counting" in state.** Save the timestamp; derive the rest. This is what makes background/kill survival free.
- **Alarms that must fire while the app is dead need the OS, not Dart.** Schedule via `flutter_local_notifications` (or `android_alarm_manager_plus`); the OS holds the schedule. The app just registers and forgets.
- Recompute timer/stopwatch on `AppLifecycleListener.onResume`; flush any unsaved state on `onPause`.

## Public contract — `ClockApi` (proposed)

For the Brief:

- `Stream<int> watchTodaysAlarmCount()` — backs "No alarms set for today".
- `Stream<Duration?> watchActiveCountdown()` — a running Timer surfaced as an
  **In-progress activity** (the Brief's Resume banner; see ADR-0001).

## Events (proposed)

- Publishes `TimerFinished` / `AlarmFired`. (Named for the countdown *tool*, not
  the module.) Consumers: Brief, Workouts (rest-between-sets).
- Consumes: could start a rest Timer on `WorkoutCompleted` or a set-logged event.

## Screens (planned)

- `clock_screen.dart` — currently a `DefaultTabController` with 3 stub tabs (Alarms / Timer / Stopwatch). Each tab becomes its real pane. Carries the hub navigation drawer.

## Open questions / ideas

- Notification permissions flow (Android 13+ runtime permission).
- Exact-alarm permission on recent Android (`SCHEDULE_EXACT_ALARM`).
- Multiple concurrent timers vs one.
- Stopwatch laps storage (likely a small table or JSON list).
- Sound/vibration selection per alarm.

## Changelog

- 2026-06-15 — Renamed module **Timers → Clock** (folder, `ClockScreen`, nav label, icon `Icons.schedule`); the Timer tool/tab and `TimerFinished` event keep their names. Still a stub.
- 2026-06-15 — Stub screen (3 empty tabs). Timestamp-based design + OS-notification approach documented here; not built.
