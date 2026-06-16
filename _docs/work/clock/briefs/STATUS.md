# Execution status — clock

| Brief | Status | Wave | Merged SHA | Criteria | Note |
|---|---|---|---|---|---|
| 01-clock-math      | integrated | 1 | 40ce4a5 | 8/8 | pure module, no hazards |
| 02-clock-shell     | integrated | 1 | e399524 | 7/7 | shell + ClockApi + repo skeleton + providers |
| 06-alarm-recurrence | integrated | 1 | 6725369 | 8/8 | pure module, no hazards |
| 03-stopwatch       | pending | 2 | — | — | ModuleData lane; collides with 04 on repo+providers |
| 04-timer-data      | pending | 2 | — | — | codegen: Timers table (+pubspec, manifest); collides with 03 |
| 05-timer-ui        | pending | 3 | — | — | |
| 07-alarm-data      | pending | 3 | — | — | codegen: Alarms table (+manifest) |
| 08-alarm-ui        | pending | 4 | — | — | sole brief |

## Dependency graph

- 01-clock-math → none
- 02-clock-shell → none
- 06-alarm-recurrence → none
- 03-stopwatch → 01, 02
- 04-timer-data → 01, 02
- 05-timer-ui → 04
- 07-alarm-data → 02, 04, 06
- 08-alarm-ui → 07

## Run model

- Workers self-verify in their worktree via the full flutter path (`/c/Users/Lukas5856/dev/flutter/bin/flutter.bat`); allowlist committed to `.claude/settings.json` so worktrees inherit it. **Confirmed working in wave 1** (all 3 ran pub get/analyze/test themselves).
- **Orchestrator owns codegen + generated files**: workers never run `build_runner` and never commit `*.g.dart`. I regenerate centrally after each merge.
- I re-gate every merge centrally: `flutter pub get` (if pubspec changed) → `build_runner` (if tables/DAOs changed) → `analyze` → `test`.
- Push straight through all waves; stop only on blocked/partial, semantic conflict, or a deviation invalidating a downstream brief.

## Handoff notes

- **01-clock-math → [03-stopwatch, 04-timer-data]:** module at `lib/features/clock/clock_math.dart`. Pure functions, all `Duration`-returning, named params: `stopwatchElapsed({DateTime? startedAt, int accumulatedMs, DateTime now})` (startedAt null ⇒ paused ⇒ `accumulatedMs`; else accumulated + now−startedAt); `countdownRemaining({DateTime endsAt, DateTime now})` (clamped ≥0); `pausedRemaining({DateTime endsAt, DateTime now})` (alias of countdownRemaining, call at pause to capture remaining; on resume rebuild `endsAt = resumedAt + storedRemaining`). Timestamps are `DateTime`, `accumulatedMs` is `int` ms — convert at the repo boundary if storing epoch ints.
- **06-alarm-recurrence → [07-alarm-data]:** module at `lib/features/clock/data/alarm_recurrence.dart`. `nextOccurrence(int timeOfDayMinutes, int repeatDaysMask, DateTime from) → DateTime`; `ringsToday(int timeOfDayMinutes, int repeatDaysMask, DateTime date) → bool` (use to filter enabled alarms for `watchTodaysAlarmCount`); `weekdaySchedule(int, int) → List<AlarmWeekdaySlot>` (one slot per set bit, Mon→Sun; `AlarmWeekdaySlot` = const value type `{int dartWeekday (1=Mon..7=Sun), int timeOfDayMinutes}`). **Weekday-bit convention (BINDING for `Alarms.repeatDays`):** 7-bit, bit 0 = Mon … bit 6 = Sun = `1 << (weekday-1)`, `everyDayMask = 0x7F`. Exported helpers: `weekdayBit`, `maskHasWeekday`, `isRecurring`, `isValidTimeOfDay`. All pure — pass an explicit `DateTime`.
- **02-clock-shell → [03, 04, 07, 08]:** `ClockApi` (`lib/core/contracts/clock_api.dart`) = abstract interface, exactly `Stream<int> watchTodaysAlarmCount()`, `Stream<int> watchRunningTimerCount()`, `Stream<bool> watchStopwatchRunning()` — depend on the interface, not the concrete repo. `ClockRepository` (`lib/features/clock/data/clock_repository.dart`) implements ClockApi, currently `const ClockRepository()` returning `Stream.value(0/0/false)`. **To make a count real:** add your DAO as a ctor param (mirror `ListsRepository(dao,bus)`), swap that one method to `_dao.watchX()`, update `clockRepositoryProvider` to inject `ref.watch(dbProvider).yourDao`, **drop `const`** from class+provider; leave the other two placeholders intact. Providers (all in `lib/core/providers.dart`): `clockRepositoryProvider`, `clockApiProvider`, `todaysAlarmCountProvider`/`runningTimerCountProvider` (StreamProvider<int>), `stopwatchRunningProvider` (StreamProvider<bool>), `selectedClockTabProvider` (NotifierProvider<SelectedClockTab, ClockTab>). `ClockTab` enum (`lib/features/clock/clock_tab.dart`) = `{alarms, timer, stopwatch}`, index order MATCHES TabBar/TabBarView; pure `entryTab({bool stopwatchRunning, int runningTimerCount, int todaysAlarmCount}) → ClockTab`. **Pane slots:** `clock_screen.dart` `TabBarView.children` is `[Alarms, Timer, Stopwatch]` — replace the matching `_Placeholder(...)` with your pane; do NOT add your own DefaultTabController (the State owns the controller, synced to `selectedClockTabProvider`). **Resume hook:** `_ClockScreenState` has an `AppLifecycleListener` with empty `_onResume` — hang resume recompute there. **ModuleData clock-key convention is OPEN** — owned by the data briefs (03/04/07); nothing in the shell constrains it.

## Deviations

- **01-clock-math:** brief named functions only by description; chose `stopwatchElapsed`/`countdownRemaining`/`pausedRemaining` with named `DateTime`/`int` params → `Duration`. Downstream 03/04 depend on these exact signatures (routed via handoff). No downstream brief invalidated.
- **06-alarm-recurrence:** the "(weekday, time-of-day) pairs" helper is `weekdaySchedule(...) → List<AlarmWeekdaySlot>` (new const value type, not `MapEntry`); added convenience exports (`weekdayBit`/`maskHasWeekday`/`isRecurring`/`everyDayMask`/`isValidTimeOfDay`) so 07 shares one bit-convention definition. 07 should depend on `AlarmWeekdaySlot` by name. No downstream brief invalidated.
- **02-clock-shell:** `ClockScreen` is a `ConsumerStatefulWidget` (not bare `ConsumerWidget`) — needs State for TabController + AppLifecycleListener; still Riverpod-aware + carries the hub drawer. Brief card shows alarms always as a summary line ("No alarms today" / "N alarm(s) today") with timer/stopwatch segments only when live (so the placeholder state reads as just "No alarms today", no "Active 0"). Did NOT modify `core/app_module.dart` — the Clock enum case already existed. None of these contradict 03/04/07/08's premises.
