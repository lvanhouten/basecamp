import 'package:basecamp/core/db/app_db.dart';
import 'package:basecamp/features/lists/data/lists_dao.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDb db;
  late ListsDao dao;

  setUp(() {
    db = AppDb.forTesting(NativeDatabase.memory());
    dao = db.listsDao;
  });

  tearDown(() async {
    await db.close();
  });

  // --- watchLists ordering ----------------------------------------------
  group('watchLists', () {
    test('emits pinned before unpinned, each group by position asc', () async {
      // Insert lists with explicit pin/position via the table directly.
      final a = await db.into(db.trackedLists).insert(
          TrackedListsCompanion.insert(name: 'A', position: const Value(2)));
      final b = await db.into(db.trackedLists).insert(
          TrackedListsCompanion.insert(name: 'B', position: const Value(1)));
      final c = await db.into(db.trackedLists).insert(TrackedListsCompanion.insert(
          name: 'C',
          position: const Value(5),
          pinned: const Value(true)));
      final d = await db.into(db.trackedLists).insert(TrackedListsCompanion.insert(
          name: 'D',
          position: const Value(0),
          pinned: const Value(true)));

      final rows = await dao.watchLists().first;
      // pinned (D pos0, C pos5) then unpinned (B pos1, A pos2)
      expect(rows.map((r) => r.list.id).toList(), [d, c, b, a]);
    });

    test('open count is reported per list', () async {
      final l = await dao.createList('Groceries');
      await dao.addItem(l, 'Milk');
      final eggs = await dao.addItem(l, 'Eggs');
      await dao.toggleItem((await dao.snapshotItem(eggs)));

      final rows = await dao.watchLists().first;
      expect(rows.single.openCount, 1);
    });
  });

  // --- watchItems ordering ----------------------------------------------
  group('watchItems', () {
    test('emits unchecked before checked, each group by position asc', () async {
      final l = await dao.createList('L');
      final i0 = await dao.addItem(l, 'i0'); // pos 0
      final i1 = await dao.addItem(l, 'i1'); // pos 1
      final i2 = await dao.addItem(l, 'i2'); // pos 2
      final i3 = await dao.addItem(l, 'i3'); // pos 3

      // Check i0 and i2 -> they sink, keeping their relative position.
      await dao.toggleItem(await dao.snapshotItem(i0));
      await dao.toggleItem(await dao.snapshotItem(i2));

      final items = await dao.watchItems(l).first;
      // unchecked: i1(1), i3(3); checked: i0(0), i2(2)
      expect(items.map((i) => i.id).toList(), [i1, i3, i0, i2]);
    });
  });

  // --- createList / addItem placement -----------------------------------
  test('createList places the new list at the top of the unpinned block',
      () async {
    final first = await dao.createList('First');
    final second = await dao.createList('Second');
    final third = await dao.createList('Third');

    final rows = await dao.watchLists().first;
    // Newest on top: Third, Second, First.
    expect(rows.map((r) => r.list.id).toList(), [third, second, first]);
  });

  test('createList stays below pinned lists', () async {
    final pinned = await dao.createList('Pinned');
    await dao.setPinned(pinned, true);
    final fresh = await dao.createList('Fresh');

    final rows = await dao.watchLists().first;
    expect(rows.first.list.id, pinned);
    expect(rows.last.list.id, fresh);
  });

  test('addItem appends to the bottom of its list', () async {
    final l = await dao.createList('L');
    final a = await dao.addItem(l, 'a');
    final b = await dao.addItem(l, 'b');
    final c = await dao.addItem(l, 'c');

    final items = await dao.watchItems(l).first;
    expect(items.map((i) => i.id).toList(), [a, b, c]);
  });

  // --- setPinned --------------------------------------------------------
  test('setPinned(true) floats above all unpinned regardless of position',
      () async {
    final a = await dao.createList('A'); // newest-on-top dynamics
    final b = await dao.createList('B');
    final c = await dao.createList('C');

    // c, b, a order initially. Pin a (lowest position-wise / oldest).
    await dao.setPinned(a, true);
    var rows = await dao.watchLists().first;
    expect(rows.first.list.id, a);
    expect(rows.map((r) => r.list.id).toList(), [a, c, b]);

    // Unpin a -> returns to position order (top of unpinned was c,b,a).
    await dao.setPinned(a, false);
    rows = await dao.watchLists().first;
    expect(rows.map((r) => r.list.id).toList(), [c, b, a]);
  });

  // --- reorder ----------------------------------------------------------
  group('reorderItems', () {
    late int listId;
    late List<int> ids;

    setUp(() async {
      listId = await dao.createList('L');
      ids = [
        await dao.addItem(listId, '0'),
        await dao.addItem(listId, '1'),
        await dao.addItem(listId, '2'),
        await dao.addItem(listId, '3'),
      ];
    });

    test('move-up', () async {
      await dao.reorderItems([ids[0], ids[3], ids[1], ids[2]]);
      final items = await dao.watchItems(listId).first;
      expect(items.map((i) => i.id).toList(), [ids[0], ids[3], ids[1], ids[2]]);
    });

    test('move-down', () async {
      await dao.reorderItems([ids[1], ids[0], ids[2], ids[3]]);
      final items = await dao.watchItems(listId).first;
      expect(items.map((i) => i.id).toList(), [ids[1], ids[0], ids[2], ids[3]]);
    });

    test('move-to-first', () async {
      await dao.reorderItems([ids[2], ids[0], ids[1], ids[3]]);
      final items = await dao.watchItems(listId).first;
      expect(items.map((i) => i.id).toList(), [ids[2], ids[0], ids[1], ids[3]]);
    });

    test('move-to-last', () async {
      await dao.reorderItems([ids[1], ids[2], ids[3], ids[0]]);
      final items = await dao.watchItems(listId).first;
      expect(items.map((i) => i.id).toList(), [ids[1], ids[2], ids[3], ids[0]]);
    });
  });

  group('reorderLists', () {
    late List<int> ids;

    setUp(() async {
      // createList puts newest on top; build a known set then reorder explicitly.
      ids = [
        await dao.createList('0'),
        await dao.createList('1'),
        await dao.createList('2'),
        await dao.createList('3'),
      ];
    });

    test('renumbers the whole unpinned section to the given order', () async {
      await dao.reorderLists([ids[0], ids[1], ids[2], ids[3]]);
      final rows = await dao.watchLists().first;
      expect(rows.map((r) => r.list.id).toList(), [ids[0], ids[1], ids[2], ids[3]]);
    });

    test('move-to-last within section', () async {
      await dao.reorderLists([ids[1], ids[2], ids[3], ids[0]]);
      final rows = await dao.watchLists().first;
      expect(rows.map((r) => r.list.id).toList(), [ids[1], ids[2], ids[3], ids[0]]);
    });
  });

  // --- rename / delete --------------------------------------------------
  test('renameList changes the name', () async {
    final l = await dao.createList('Old');
    await dao.renameList(l, 'New');
    final rows = await dao.watchLists().first;
    expect(rows.single.list.name, 'New');
  });

  test('renameItem changes the label', () async {
    final l = await dao.createList('L');
    final i = await dao.addItem(l, 'Old');
    await dao.renameItem(i, 'New');
    final items = await dao.watchItems(l).first;
    expect(items.single.label, 'New');
  });

  test('deleteList hard-deletes and cascades to items', () async {
    final l = await dao.createList('L');
    await dao.addItem(l, 'a');
    await dao.addItem(l, 'b');
    await dao.deleteList(l);

    expect(await dao.watchLists().first, isEmpty);
    final remaining = await db.select(db.listItems).get();
    expect(remaining, isEmpty);
  });

  test('deleteItem hard-deletes a single item', () async {
    final l = await dao.createList('L');
    final a = await dao.addItem(l, 'a');
    await dao.addItem(l, 'b');
    await dao.deleteItem(a);

    final items = await dao.watchItems(l).first;
    expect(items.map((i) => i.label).toList(), ['b']);
  });

  // --- snapshot / restore -----------------------------------------------
  test('snapshotList -> deleteList -> restoreList preserves name and items',
      () async {
    final l = await dao.createList('Groceries');
    final milk = await dao.addItem(l, 'Milk');
    await dao.addItem(l, 'Eggs');
    await dao.addItem(l, 'Bread');
    await dao.toggleItem(await dao.snapshotItem(milk)); // Milk done

    final snap = await dao.snapshotList(l);
    await dao.deleteList(l);
    expect(await dao.watchLists().first, isEmpty);

    final newId = await dao.restoreList(snap);
    final rows = await dao.watchLists().first;
    expect(rows.single.list.name, 'Groceries');

    final items = await dao.watchItems(newId).first;
    // Same labels + done states (set comparison; emitted order: unchecked first).
    final byLabel = {for (final i in items) i.label: i.done};
    expect(byLabel, {'Milk': true, 'Eggs': false, 'Bread': false});
    expect(items.length, 3);
  });

  test('snapshotItem -> deleteItem -> restoreItem preserves the item', () async {
    final l = await dao.createList('L');
    final i = await dao.addItem(l, 'Target');
    await dao.toggleItem(await dao.snapshotItem(i));

    final snap = await dao.snapshotItem(i);
    await dao.deleteItem(i);
    expect(await dao.watchItems(l).first, isEmpty);

    await dao.restoreItem(snap);
    final items = await dao.watchItems(l).first;
    expect(items.single.label, 'Target');
    expect(items.single.done, true);
    expect(items.single.listId, l);
  });

  // --- ListsApi unchanged ----------------------------------------------
  group('ListsApi surface', () {
    test('watchListCount counts lists', () async {
      expect(await dao.watchListCount().first, 0);
      await dao.createList('A');
      await dao.createList('B');
      expect(await dao.watchListCount().first, 2);
    });

    test('watchOpenItemCount counts unchecked items across all lists', () async {
      final l1 = await dao.createList('L1');
      final l2 = await dao.createList('L2');
      final a = await dao.addItem(l1, 'a');
      await dao.addItem(l2, 'b');
      expect(await dao.watchOpenItemCount().first, 2);
      await dao.toggleItem(await dao.snapshotItem(a));
      expect(await dao.watchOpenItemCount().first, 1);
    });
  });
}
