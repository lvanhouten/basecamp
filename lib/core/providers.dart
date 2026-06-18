import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/clock/clock_tab.dart';
import '../features/clock/data/chime_player.dart';
import '../features/clock/data/clock_repository.dart';
import '../features/clock/data/notification_scheduler.dart';
import '../features/clock/data/stopwatch_state.dart';
import '../features/lists/data/lists_dao.dart';
import '../features/lists/data/lists_repository.dart';
import 'bar_destination.dart';
import 'contracts/clock_api.dart';
import 'contracts/lists_api.dart';
import 'db/app_db.dart';
import 'events/event_bus.dart';

/// Single database instance for the app's lifetime.
final dbProvider = Provider<AppDb>((ref) {
  final db = AppDb();
  ref.onDispose(db.close);
  return db;
});

/// The event bus, lifecycle owned by Riverpod (replaces a get_it singleton).
final eventBusProvider = Provider<EventBus>((ref) {
  final bus = EventBus();
  ref.onDispose(bus.dispose);
  return bus;
});

/// Which launcher **bar destination** the shell is showing (ADR-0005). The
/// [LauncherTabBar] writes it; the shell's IndexedStack reads it. This is the
/// only navigation the shell remembers — modules are pushed views whose landing
/// is derived from Drift, not from this notifier (CONTEXT.md / ADR-0005). The
/// resting default is the Brief.
///
/// Replaces ADR-0001's `selectedModuleProvider`: that mixed the Brief and the
/// modules into one switchable IndexedStack; the bar set and the module set are
/// now distinct.
class SelectedBar extends Notifier<BarDestination> {
  @override
  BarDestination build() => BarDestination.brief;

  void select(BarDestination destination) => state = destination;
}

final selectedBarProvider =
    NotifierProvider<SelectedBar, BarDestination>(SelectedBar.new);

/// The Lists module's repository (its full internal surface).
final listsRepositoryProvider = Provider<ListsRepository>((ref) {
  return ListsRepository(
    ref.watch(dbProvider).listsDao,
    ref.watch(eventBusProvider),
  );
});

/// The module-agnostic contract other modules depend on. Note it resolves to
/// the same repository — but consumers only see the narrow [ListsApi] surface.
final listsApiProvider = Provider<ListsApi>((ref) => ref.watch(listsRepositoryProvider));

// --- Reactive read models (Drift streams → UI; survive cold start for free) ---

final listsProvider = StreamProvider<List<TrackedListWithCount>>(
  (ref) => ref.watch(listsRepositoryProvider).watchLists(),
);

final listItemsProvider = StreamProvider.family<List<ListItem>, int>(
  (ref, listId) => ref.watch(listsRepositoryProvider).watchItems(listId),
);

// These two go through the CONTRACT, demonstrating cross-module pull:
final openItemCountProvider = StreamProvider<int>(
  (ref) => ref.watch(listsApiProvider).watchOpenItemCount(),
);

final listCountProvider = StreamProvider<int>(
  (ref) => ref.watch(listsApiProvider).watchListCount(),
);

// --- Clock module ---

/// The OS notification-scheduling seam (ADR-0003). Overridable in tests/widget
/// pumps with a fake or [NoopNotificationScheduler] so timer scheduling is
/// verifiable without the real plugin. Briefs 03/07 reuse this same provider;
/// 07 extends the interface for the alarm full-screen intent.
final notificationSchedulerProvider = Provider<NotificationScheduler>((ref) {
  return LocalNotificationScheduler();
});

/// The Clock module's repository (its full internal surface). As of
/// `04-timer-data` it injects the shared [ClockDao] + the
/// [NotificationScheduler]; `watchRunningTimerCount` is now real. Briefs 03/07
/// add their deps to the same DAO (and 07 to the scheduler) — keep additive.
final clockRepositoryProvider = Provider<ClockRepository>((ref) {
  return ClockRepository(
    ref.watch(dbProvider).clockDao,
    ref.watch(notificationSchedulerProvider),
  );
});

/// The module-agnostic contract the Brief depends on. Resolves to the same
/// repository, but consumers only see the narrow [ClockApi] surface — mirrors
/// the `listsRepositoryProvider`/`listsApiProvider` split.
final clockApiProvider =
    Provider<ClockApi>((ref) => ref.watch(clockRepositoryProvider));

// Clock's three reactive counts, read through the CONTRACT (cross-module pull).
// All three are now real: timers (04), stopwatch (03), alarms (07).

final todaysAlarmCountProvider = StreamProvider<int>(
  (ref) => ref.watch(clockApiProvider).watchTodaysAlarmCount(),
);

final runningTimerCountProvider = StreamProvider<int>(
  (ref) => ref.watch(clockApiProvider).watchRunningTimerCount(),
);

/// The Clock-module-internal running-timer list (soonest `endsAt` first, then
/// creation order). Exposed here so the TimerPane (05-timer-ui) consumes it
/// WITHOUT editing this file. Goes through the repository (not the narrow
/// ClockApi) because the row type is Clock-internal.
final runningTimersProvider = StreamProvider<List<TimerRow>>(
  (ref) => ref.watch(clockRepositoryProvider).watchRunningTimers(),
);

// Backs the Brief card's stopwatch segment. Real as of 03-stopwatch: derived
// from the persisted ModuleData record's `isRunning` (via the ClockApi).
final stopwatchRunningProvider = StreamProvider<bool>(
  (ref) => ref.watch(clockApiProvider).watchStopwatchRunning(),
);

/// The single stopwatch's full persisted state (start segment, banked elapsed,
/// running flag, laps). Backs the StopwatchPane (03-stopwatch); the pane derives
/// its displayed time from this record + `now` via clock-math and an in-memory
/// display ticker. Goes through the repository (not the narrow ClockApi)
/// because [StopwatchState] is Clock-internal.
final stopwatchStateProvider = StreamProvider<StopwatchState>(
  (ref) => ref.watch(clockRepositoryProvider).watchStopwatch(),
);

/// Every alarm (enabled or not), soonest time-of-day first then creation order.
/// Exposed here so the AlarmsPane (08-alarm-ui) consumes it WITHOUT editing this
/// file. Goes through the repository (not the narrow ClockApi) because the
/// [AlarmRow] type is Clock-internal.
final alarmsProvider = StreamProvider<List<AlarmRow>>(
  (ref) => ref.watch(clockRepositoryProvider).watchAlarms(),
);

/// The looping-chime capability the alarm ring screen (08-alarm-ui) drives:
/// `start()` on launch, `stop()` on Snooze/Dismiss (ADR-0003). Overridable in
/// tests/widget pumps with a [NoopChimePlayer] or a recording fake so the ring
/// screen is verifiable without playing audio.
final chimePlayerProvider = Provider<ChimePlayer>((ref) {
  return DefaultChimePlayer();
});

/// The Clock module's selected tool tab. Written on module ENTRY by the
/// `pushModule` precedence (`module_navigation.dart`) — derived from live Drift
/// state (ADR-0004), not remembered across hops — before `ClockScreen` mounts,
/// which seeds its [TabController] from it. A manual in-module tab switch also
/// writes it, persisting within the pushed session. Defaults to Alarms — the
/// resting landing tab.
class SelectedClockTab extends Notifier<ClockTab> {
  @override
  ClockTab build() => ClockTab.alarms;

  void select(ClockTab tab) => state = tab;
}

final selectedClockTabProvider =
    NotifierProvider<SelectedClockTab, ClockTab>(SelectedClockTab.new);
