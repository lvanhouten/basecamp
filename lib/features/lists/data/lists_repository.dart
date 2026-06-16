import '../../../core/contracts/lists_api.dart';
import '../../../core/db/app_db.dart';
import '../../../core/events/domain_event.dart';
import '../../../core/events/event_bus.dart';
import 'lists_dao.dart';

/// The Lists module's own data access. It IMPLEMENTS [ListsApi] (the narrow
/// cross-module contract) but also exposes richer methods used only by the
/// Lists UI. Other modules get the [ListsApi] view; this module uses the lot.
class ListsRepository implements ListsApi {
  ListsRepository(this._dao, this._bus);

  final ListsDao _dao;
  final EventBus _bus;

  // --- ListsApi (visible to other modules) ---
  @override
  Stream<int> watchOpenItemCount() => _dao.watchOpenItemCount();

  @override
  Stream<int> watchListCount() => _dao.watchListCount();

  // --- Internal to the Lists module ---
  Stream<List<TrackedListWithCount>> watchLists() => _dao.watchLists();

  Stream<List<ListItem>> watchItems(int listId) => _dao.watchItems(listId);

  Future<void> createList(String name) => _dao.createList(name);

  Future<void> addItem(int listId, String label) => _dao.addItem(listId, label);

  Future<void> toggleItem(ListItem item) async {
    await _dao.toggleItem(item);
    // Persisted effect already done above; the event is just a live signal.
    _bus.publish(ListItemToggled(itemId: item.id, done: !item.done));
  }

  Future<void> setPinned(int listId, bool pinned) =>
      _dao.setPinned(listId, pinned);

  Future<void> renameList(int listId, String name) =>
      _dao.renameList(listId, name);

  Future<void> renameItem(int itemId, String label) =>
      _dao.renameItem(itemId, label);

  /// Persists a renumber of one list section (pinned or unpinned). The caller
  /// passes the post-[applyReorder] id order for that section only.
  Future<void> reorderLists(List<int> orderedIds) =>
      _dao.reorderLists(orderedIds);

  /// Persists a renumber of one item done-group (checked or unchecked). The
  /// caller passes the post-[applyReorder] id order for that group only.
  Future<void> reorderItems(List<int> orderedIds) =>
      _dao.reorderItems(orderedIds);

  Future<void> deleteItem(int id) => _dao.deleteItem(id);

  Future<void> deleteList(int id) => _dao.deleteList(id);

  // --- Ephemeral undo (snapshot before delete, restore on SnackBar action) ---
  Future<ListSnapshot> snapshotList(int listId) => _dao.snapshotList(listId);

  Future<int> restoreList(ListSnapshot snapshot) => _dao.restoreList(snapshot);

  Future<ListItem> snapshotItem(int itemId) => _dao.snapshotItem(itemId);

  Future<int> restoreItem(ListItem item) => _dao.restoreItem(item);
}
