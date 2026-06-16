import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/clock/clock_tab.dart';
import '../features/clock/data/clock_repository.dart';
import '../features/clock/data/notification_scheduler.dart';
import '../features/lists/data/lists_dao.dart';
import '../features/lists/data/lists_repository.dart';
import 'app_module.dart';
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

/// Which module the hub is showing. The drawer and the Brief's cards write it;
/// the shell's IndexedStack reads it. Navigation is hub-level state, not a
/// remembered route — see ADR-0001.
class SelectedModule extends Notifier<AppModule> {
  @override
  AppModule build() => AppModule.brief;

  void select(AppModule module) => state = module;
}

final selectedModuleProvider =
    NotifierProvider<SelectedModule, AppModule>(SelectedModule.new);

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
// Placeholder-backed in this brief; later briefs make each real.

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

final stopwatchRunningProvider = StreamProvider<bool>(
  (ref) => ref.watch(clockApiProvider).watchStopwatchRunning(),
);

/// The Clock module's selected tool tab. The Brief card writes it (via the
/// `entryTab` precedence) on tap; `ClockScreen` reads it to sync its
/// [TabController]. A manual in-module tab switch also writes it, and because
/// the module is kept alive in the hub IndexedStack, that choice persists for
/// the session (ADR-0004). Defaults to Alarms — the resting landing tab.
class SelectedClockTab extends Notifier<ClockTab> {
  @override
  ClockTab build() => ClockTab.alarms;

  void select(ClockTab tab) => state = tab;
}

final selectedClockTabProvider =
    NotifierProvider<SelectedClockTab, ClockTab>(SelectedClockTab.new);
