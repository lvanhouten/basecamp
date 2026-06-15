import 'package:drift/drift.dart';

import '../../../core/db/app_db.dart';
import '../../../core/db/tables.dart';

part 'lists_dao.g.dart';

/// A list paired with its count of unchecked items — a small read model the
/// Lists screen renders directly (not a persisted table).
class TrackedListWithCount {
  const TrackedListWithCount(this.list, this.openCount);
  final TrackedList list;
  final int openCount;
}

/// All persistence for the Lists module lives here. Other modules never touch
/// these tables — they go through the [ListsApi] facade instead.
@DriftAccessor(tables: [TrackedLists, ListItems])
class ListsDao extends DatabaseAccessor<AppDb> with _$ListsDaoMixin {
  ListsDao(super.db);

  Stream<List<TrackedListWithCount>> watchLists() {
    final open = listItems.id.count(filter: listItems.done.equals(false));
    final query = select(trackedLists).join([
      leftOuterJoin(listItems, listItems.listId.equalsExp(trackedLists.id)),
    ])
      ..addColumns([open])
      ..groupBy([trackedLists.id])
      ..orderBy([OrderingTerm(expression: trackedLists.createdAt)]);

    return query
        .map((row) =>
            TrackedListWithCount(row.readTable(trackedLists), row.read(open) ?? 0))
        .watch();
  }

  Stream<List<ListItem>> watchItems(int listId) {
    return (select(listItems)
          ..where((t) => t.listId.equals(listId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.done),
            (t) => OrderingTerm(expression: t.createdAt),
          ]))
        .watch();
  }

  /// Across all lists — backs the daily brief.
  Stream<int> watchOpenItemCount() {
    final open = listItems.id.count(filter: listItems.done.equals(false));
    return (selectOnly(listItems)..addColumns([open]))
        .map((row) => row.read(open) ?? 0)
        .watchSingle();
  }

  Stream<int> watchListCount() {
    final total = trackedLists.id.count();
    return (selectOnly(trackedLists)..addColumns([total]))
        .map((row) => row.read(total) ?? 0)
        .watchSingle();
  }

  Future<int> createList(String name) =>
      into(trackedLists).insert(TrackedListsCompanion.insert(name: name));

  Future<int> addItem(int listId, String label) => into(listItems)
      .insert(ListItemsCompanion.insert(listId: listId, label: label));

  Future<void> toggleItem(ListItem item) =>
      (update(listItems)..where((t) => t.id.equals(item.id)))
          .write(ListItemsCompanion(done: Value(!item.done)));

  Future<void> deleteItem(int id) =>
      (delete(listItems)..where((t) => t.id.equals(id))).go();

  Future<void> deleteList(int id) =>
      (delete(trackedLists)..where((t) => t.id.equals(id))).go();
}
