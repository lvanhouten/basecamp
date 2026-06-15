import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/lists/data/lists_dao.dart';
import '../features/lists/data/lists_repository.dart';
import 'app_module.dart';
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
