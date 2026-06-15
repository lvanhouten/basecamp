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

  Future<void> deleteItem(int id) => _dao.deleteItem(id);

  Future<void> deleteList(int id) => _dao.deleteList(id);
}
