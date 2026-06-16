# Execution status — clock

| Brief | Status | Wave | Merged SHA | Criteria | Note |
|---|---|---|---|---|---|
| 01-clock-math      | integrated | 1 | 40ce4a5 | 8/8 | pure module |
| 02-clock-shell     | integrated | 1 | e399524 | 7/7 | shell + ClockApi + repo skeleton + providers |
| 06-alarm-recurrence | integrated | 1 | 6725369 | 8/8 | pure module |
| 04-timer-data      | integrated | 2 | 3d78121 | 8/8 | Timers table (v3), ClockDao, NotificationScheduler, providers |
| 03-stopwatch       | pending | 3 | — | — | extends ClockDao (ModuleData) + repo + providers |
| 05-timer-ui        | pending | 3 | — | — | consumes 04's runningTimersProvider; TimerRow |
| 07-alarm-data      | pending | 4 | — | — | codegen: Alarms table (v4), extends scheduler full-screen |
| 08-alarm-ui        | pending | 5 | — | — | depends on 07 |

## Dependency graph

- 01 → none · 02 → none · 06 → none
- 03 → 01, 02 · 04 → 01, 02 · 05 → 04 · 07 → 02, 04, 06 · 08 → 07

## Run model (REVISED after wave 2)

- **Worktree isolation ABANDONED:** `isolation:"worktree"` provisions worktrees off `main` (`11f6803`), NOT the current `clock` HEAD — so any brief depending on prior clock work finds its deps missing and reports blocked (confirmed: 04's first attempt). Wave 1 only survived because those briefs were dependency-free + purely additive (merged as 3-way, not fast-forward).
- **Remaining briefs run NON-ISOLATED, SEQUENTIAL, foreground** in the main checkout on `clock`; the worker commits its hand-written source directly to `clock`. Order: 03 → 05 → 07 → 08 (respects deps; serializes the shared clock data layer 04→03→07 to avoid conflicts).
- **Orchestrator owns codegen + `*.g.dart`:** worker self-verifies in place (build_runner + analyze + test) but stages by explicit path, never commits `*.g.dart`. After the worker returns I regenerate centrally, run analyze + test, and fold the generated files into the brief's commit (`git commit --amend`). Tree kept clean between briefs.
- While a non-isolated worker runs, the orchestrator does NOT touch the working tree (no concurrent git/file ops).
- Push straight through; stop only on blocked/partial, semantic conflict, or a deviation invalidating a downstream brief.

## Handoff notes

- **01-clock-math → [03]:** `lib/features/clock/clock_math.dart`. `stopwatchElapsed({DateTime? startedAt, int accumulatedMs, DateTime now})` (startedAt null ⇒ paused ⇒ accumulatedMs; else accumulated + now−startedAt); plus `countdownRemaining`/`pausedRemaining` (clamped ≥0). DateTime timestamps, int ms.
- **06-alarm-recurrence → [07]:** `lib/features/clock/data/alarm_recurrence.dart`. `nextOccurrence(int,int,DateTime)→DateTime`, `ringsToday(int,int,DateTime)→bool`, `weekdaySchedule(int,int)→List<AlarmWeekdaySlot>`. Weekday-bit (BINDING for `Alarms.repeatDays`): bit0=Mon..bit6=Sun = `1<<(weekday-1)`, `everyDayMask=0x7F`.
- **02-clock-shell → [03,07,08]:** `ClockApi` interface (clock_api.dart); `ClockRepository` (clock_repository.dart); providers in providers.dart (clockRepositoryProvider, clockApiProvider, the 3 count providers, selectedClockTabProvider). `ClockTab {alarms,timer,stopwatch}` + pure `entryTab(...)`. Pane slots: `clock_screen.dart` TabBarView.children `[Alarms, Timer, Stopwatch]` — replace the matching `_Placeholder`; State owns the TabController (no DefaultTabController). Resume hook: `_ClockScreenState._onResume` (empty). ClockScreen is `ConsumerStatefulWidget`.
- **04-timer-data → [03,05,07]:**
  - `ClockDao` at `lib/features/clock/data/clock_dao.dart` = `@DriftAccessor(tables:[Timers]) ... with _$ClockDaoMixin { ClockDao(super.db); }`. To add a table (07 Alarms): add to the @DriftAccessor list HERE + @DriftDatabase tables in app_db.dart, then build_runner. **03 stopwatch reuses ModuleData — add methods, no new table.**
  - Generated row class is **`TimerRow`** (`@DataClassName('TimerRow')`) — Drift would otherwise singularize to `Timer` and collide with `dart:async.Timer`. 05 references `TimerRow` (exported via app_db.dart).
  - `ClockRepository(ClockDao dao, NotificationScheduler scheduler)` — NO longer const. Timer methods take optional `now`: `createTimer(Duration,{String? label,DateTime? now})→Future<int>`, `pauseTimer(int,{now})`, `resumeTimer(int,{now})`, `cancelTimer(int)`. Streams `watchRunningTimers()`/`watchAllTimers()`→`Stream<List<TimerRow>>`. `bool get notificationsAllowed`. **Scheduling is handled inside these repo methods — 05's UI just calls them.**
  - Providers (providers.dart): `notificationSchedulerProvider` (default `LocalNotificationScheduler`, override with fake/Noop in tests), `runningTimersProvider` (StreamProvider<List<TimerRow>>, soonest endsAt then createdAt — **05 consumes THIS, no providers.dart edit**), `runningTimerCountProvider` now real. clockRepositoryProvider non-const (injects clockDao + scheduler).
  - `NotificationScheduler` (notification_scheduler.dart): `ensurePermission()→Future<bool>`, `schedule({int id, DateTime at, String? payload})`, `cancel(int id)`. Timer impl heads-up (fullScreenIntent:false) channel 'clock_timer', exact-while-idle. `NoopNotificationScheduler` = test no-op. **07 ADDS a sibling method (scheduleAlarm, fullScreenIntent:true, own channel + boot reschedule) — keep schedule/cancel as-is.**
  - **schemaVersion now 3.** 07 adds a NEW `if (from < 4)` branch for Alarms — do NOT modify the existing branches. Migration-test style: seed prior schema in raw sqlite3, stamp user_version, open `AppDb.forTesting(NativeDatabase.opened(raw))`, assert table exists + old data preserved (see migration_v2_to_v3_test.dart).
  - Timers columns: id PK, label TEXT?, durationMs INT, endsAt DATETIME? (running incl. finished-past), remainingMs INT? (paused only), createdAt DATETIME default now. No status column. **Drift DateTime test gotcha:** Drift round-trips DateTime via Unix epoch in LOCAL zone — use local `DateTime(...)` literals in tests, not `DateTime.utc(...)`.

## Deviations

- **01:** chose `stopwatchElapsed`/`countdownRemaining`/`pausedRemaining` signatures (routed to dependents). No downstream invalidated.
- **06:** `weekdaySchedule→List<AlarmWeekdaySlot>` (new const type); added bit-convention helper exports. 07 depends on `AlarmWeekdaySlot` by name. No downstream invalidated.
- **02:** `ClockScreen` is `ConsumerStatefulWidget` (needs TabController/AppLifecycleListener); Brief card shows alarms always + timer/stopwatch only when live; `core/app_module.dart` Clock case already existed. No downstream invalidated.
- **04:** `TimerRow` row-class name (collision avoidance — routed to 05). Updated 2 wave-1 test files (widget_test.dart, clock_repository_test.dart) since making `watchRunningTimerCount` real broke their const-placeholder assumption — legitimate contract ripple, all green. Added `NoopNotificationScheduler`. pub get downgraded some transitive analyzer/test packages within constraints (flutter_local_notifications 18) — no source impact, 140 tests green. **No downstream brief invalidated.**
