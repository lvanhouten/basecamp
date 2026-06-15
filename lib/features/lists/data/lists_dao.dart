import 'package:drift/drift.dart';

import '../../../core/db/app_db.dart';
import '../../../core/db/tables.dart';
import 'apply_reorder.dart';

part 'lists_dao.g.dart';

/// A list paired with its count of unchecked items — a small read model the
/// Lists screen renders directly (not a persisted table).
class TrackedListWithCount {
  const TrackedListWithCount(this.list, this.openCount);
  final TrackedList list;
  final int openCount;
}

/// A list plus its items, captured for ephemeral undo. Held in memory by the
/// UI between a delete and a possible restore — never persisted (events and
/// view-state are transient; only Drift rows survive a cold start).
class ListSnapshot {
  const ListSnapshot(this.list, this.items);
  final TrackedList list;
  final List<ListItem> items;
}

/// All persistence for the Lists module lives here. Other modules never touch
/// these tables — they go through the [ListsApi] facade instead.
@DriftAccessor(tables: [TrackedLists, ListItems])
class ListsDao extends DatabaseAccessor<AppDb> with _$ListsDaoMixin {
  ListsDao(super.db);

  /// Lists emit `pinned DESC, position ASC` — pinned float to the top, manual
  /// drag order applies within each group (ADR-0002). `id` is a stable final
  /// tiebreaker so equal positions never flicker.
  Stream<List<TrackedListWithCount>> watchLists() {
    final open = listItems.id.count(filter: listItems.done.equals(false));
    final query = select(trackedLists).join([
      leftOuterJoin(listItems, listItems.listId.equalsExp(trackedLists.id)),
    ])
      ..addColumns([open])
      ..groupBy([trackedLists.id])
      ..orderBy([
        OrderingTerm(expression: trackedLists.pinned, mode: OrderingMode.desc),
        OrderingTerm(expression: trackedLists.position),
        OrderingTerm(expression: trackedLists.id),
      ]);

    return query
        .map((row) =>
            TrackedListWithCount(row.readTable(trackedLists), row.read(open) ?? 0))
        .watch();
  }

  /// Items emit `done ASC, position ASC` — checked items sink, manual drag
  /// order applies within each done-group (ADR-0002). `id` is a stable final
  /// tiebreaker so equal positions never flicker.
  Stream<List<ListItem>> watchItems(int listId) {
    return (select(listItems)
          ..where((t) => t.listId.equals(listId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.done),
            (t) => OrderingTerm(expression: t.position),
            (t) => OrderingTerm(expression: t.id),
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

  /// A new list is unpinned and placed at the top of the unpinned block: one
  /// below the current minimum position across all lists. (Pinned lists still
  /// sort above it because `pinned DESC` is the primary key.)
  Future<int> createList(String name) async {
    final minPos = trackedLists.position.min();
    final current = await (selectOnly(trackedLists)..addColumns([minPos]))
        .map((row) => row.read(minPos))
        .getSingleOrNull();
    final position = current == null ? 0 : current - 1;
    return into(trackedLists).insert(
      TrackedListsCompanion.insert(name: name, position: Value(position)),
    );
  }

  /// A new item is appended to the bottom of its list: one above the current
  /// maximum position within that list. (It is unchecked, so it lands at the
  /// bottom of the unchecked group.)
  Future<int> addItem(int listId, String label) async {
    final maxPos = listItems.position.max();
    final current = await (selectOnly(listItems)
          ..addColumns([maxPos])
          ..where(listItems.listId.equals(listId)))
        .map((row) => row.read(maxPos))
        .getSingleOrNull();
    final position = current == null ? 0 : current + 1;
    return into(listItems).insert(
      ListItemsCompanion.insert(
        listId: listId,
        label: label,
        position: Value(position),
      ),
    );
  }

  Future<void> toggleItem(ListItem item) =>
      (update(listItems)..where((t) => t.id.equals(item.id)))
          .write(ListItemsCompanion(done: Value(!item.done)));

  Future<void> setPinned(int listId, bool pinned) =>
      (update(trackedLists)..where((t) => t.id.equals(listId)))
          .write(TrackedListsCompanion(pinned: Value(pinned)));

  Future<void> renameList(int listId, String name) =>
      (update(trackedLists)..where((t) => t.id.equals(listId)))
          .write(TrackedListsCompanion(name: Value(name)));

  Future<void> renameItem(int itemId, String label) =>
      (update(listItems)..where((t) => t.id.equals(itemId)))
          .write(ListItemsCompanion(label: Value(label)));

  /// Persists a contiguous `0..n` renumber of one *section* of lists. The
  /// caller has already applied [applyReorder] to a single pinned/unpinned
  /// group; this just writes `position = index` for each id in one transaction.
  Future<void> reorderLists(List<int> orderedIds) =>
      transaction(() async {
        for (var i = 0; i < orderedIds.length; i++) {
          await (update(trackedLists)..where((t) => t.id.equals(orderedIds[i])))
              .write(TrackedListsCompanion(position: Value(i)));
        }
      });

  /// Persists a contiguous `0..n` renumber of one *done-group* of items. The
  /// caller has already applied [applyReorder] to a single (checked or
  /// unchecked) group; this writes `position = index` in one transaction.
  Future<void> reorderItems(List<int> orderedIds) =>
      transaction(() async {
        for (var i = 0; i < orderedIds.length; i++) {
          await (update(listItems)..where((t) => t.id.equals(orderedIds[i])))
              .write(ListItemsCompanion(position: Value(i)));
        }
      });

  Future<void> deleteItem(int id) =>
      (delete(listItems)..where((t) => t.id.equals(id))).go();

  Future<void> deleteList(int id) =>
      (delete(trackedLists)..where((t) => t.id.equals(id))).go();

  /// Captures a list plus all its items for ephemeral undo. Pair with
  /// [restoreList] after a [deleteList].
  Future<ListSnapshot> snapshotList(int listId) async {
    final list = await (select(trackedLists)..where((t) => t.id.equals(listId)))
        .getSingle();
    final items = await (select(listItems)
          ..where((t) => t.listId.equals(listId)))
        .get();
    return ListSnapshot(list, items);
  }

  /// Re-inserts a snapshotted list and its items in one transaction. Fresh
  /// autoincrement ids are acceptable — nothing durable references the old
  /// ones — so the list's `pinned`/`position` and each item's `done`/`label`/
  /// `position` are preserved while ids are reassigned. Returns the new list id.
  Future<int> restoreList(ListSnapshot snapshot) => transaction(() async {
        final newListId = await into(trackedLists).insert(
          TrackedListsCompanion.insert(
            name: snapshot.list.name,
            createdAt: Value(snapshot.list.createdAt),
            pinned: Value(snapshot.list.pinned),
            position: Value(snapshot.list.position),
          ),
        );
        for (final item in snapshot.items) {
          await into(listItems).insert(
            ListItemsCompanion.insert(
              listId: newListId,
              label: item.label,
              done: Value(item.done),
              createdAt: Value(item.createdAt),
              position: Value(item.position),
            ),
          );
        }
        return newListId;
      });

  /// Captures a single item for ephemeral undo. Pair with [restoreItem] after
  /// a [deleteItem].
  Future<ListItem> snapshotItem(int itemId) =>
      (select(listItems)..where((t) => t.id.equals(itemId))).getSingle();

  /// Re-inserts a snapshotted item (fresh autoincrement id). Preserves its
  /// list, label, done state and position. Returns the new item id.
  Future<int> restoreItem(ListItem item) => into(listItems).insert(
        ListItemsCompanion.insert(
          listId: item.listId,
          label: item.label,
          done: Value(item.done),
          createdAt: Value(item.createdAt),
          position: Value(item.position),
        ),
      );
}
