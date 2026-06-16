import 'dart:async';

import 'package:basecamp/core/db/app_db.dart';
import 'package:basecamp/core/events/event_bus.dart';
import 'package:basecamp/core/providers.dart';
import 'package:basecamp/features/lists/data/lists_repository.dart';
import 'package:basecamp/features/lists/list_detail_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A test double for [ListsRepository]. It satisfies the concrete super-type by
/// handing throwaway in-memory infra to `super`, then overrides every method the
/// detail screen actually calls so the test can drive [watchItems] and assert on
/// recorded calls (e.g. that UNDO restored a snapshotted item).
class _FakeListsRepository extends ListsRepository {
  _FakeListsRepository(super.dao, super.bus);

  final _controller = StreamController<List<ListItem>>.broadcast();

  // Recorded calls, for assertions.
  final List<int> deleted = [];
  final List<int> snapshotted = [];
  final List<ListItem> restored = [];
  final List<(int, String)> renamed = [];
  final List<List<int>> reordered = [];
  final List<(int, String)> added = [];
  final List<int> toggled = [];

  void emit(List<ListItem> items) => _controller.add(items);

  @override
  Stream<List<ListItem>> watchItems(int listId) => _controller.stream;

  @override
  Future<ListItem> snapshotItem(int itemId) async {
    snapshotted.add(itemId);
    // A plausible snapshot for the deleted item; contents are irrelevant to the
    // screen — it only round-trips the object back to restoreItem on UNDO.
    return ListItem(
      id: itemId,
      listId: 1,
      label: 'snap-$itemId',
      done: false,
      createdAt: DateTime(2026),
      position: 0,
    );
  }

  @override
  Future<void> deleteItem(int id) async => deleted.add(id);

  @override
  Future<int> restoreItem(ListItem item) async {
    restored.add(item);
    return 999;
  }

  @override
  Future<void> renameItem(int itemId, String label) async =>
      renamed.add((itemId, label));

  @override
  Future<void> reorderItems(List<int> orderedIds) async =>
      reordered.add(orderedIds);

  @override
  Future<void> addItem(int listId, String label) async =>
      added.add((listId, label));

  @override
  Future<void> toggleItem(ListItem item) async => toggled.add(item.id);

  Future<void> closeStream() async => _controller.close();
}

ListItem _item(int id, String label, {bool done = false, int position = 0}) {
  return ListItem(
    id: id,
    listId: 1,
    label: label,
    done: done,
    createdAt: DateTime(2026, 1, 1).add(Duration(seconds: id)),
    position: position,
  );
}

void main() {
  late AppDb db;
  late _FakeListsRepository repo;

  setUp(() {
    // Real-but-unused in-memory DAO/bus satisfy the concrete super constructor;
    // every method the screen calls is overridden on the fake.
    db = AppDb.forTesting(NativeDatabase.memory());
    repo = _FakeListsRepository(db.listsDao, EventBus());
  });

  tearDown(() async {
    await repo.closeStream();
    await db.close();
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          listsRepositoryProvider.overrideWithValue(repo),
        ],
        child: const MaterialApp(
          home: ListDetailScreen(listId: 1, title: 'Groceries'),
        ),
      ),
    );
    // First frame: the StreamProvider has no value yet (loading spinner). The
    // caller emits items then pumps again.
    await tester.pump();
  }

  testWidgets(
      'deleting an item shows a SnackBar with UNDO; UNDO restores the item',
      (tester) async {
    await pumpScreen(tester);
    repo.emit([_item(1, 'Milk')]);
    await tester.pumpAndSettle();

    // Swipe the row away to delete it.
    await tester.drag(find.text('Milk'), const Offset(-500, 0));
    await tester.pumpAndSettle();

    // The item was snapshotted BEFORE delete, then deleted.
    expect(repo.snapshotted, [1]);
    expect(repo.deleted, [1]);

    // A SnackBar with an UNDO action is shown.
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.widgetWithText(SnackBarAction, 'Undo'), findsOneWidget);
    expect(repo.restored, isEmpty);

    // Tapping UNDO restores the snapshot.
    await tester.tap(find.widgetWithText(SnackBarAction, 'Undo'));
    await tester.pumpAndSettle();

    expect(repo.restored, hasLength(1));
    expect(repo.restored.single.id, 1);
  });

  testWidgets('long-press menu Delete shows the UNDO SnackBar', (tester) async {
    await pumpScreen(tester);
    repo.emit([_item(1, 'Milk')]);
    await tester.pumpAndSettle();

    await tester.longPress(find.text('Milk'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ListTile, 'Delete'));
    await tester.pumpAndSettle();

    expect(repo.snapshotted, [1]);
    expect(repo.deleted, [1]);
    expect(find.widgetWithText(SnackBarAction, 'Undo'), findsOneWidget);
  });

  testWidgets('long-press menu Rename applies the new label on Save',
      (tester) async {
    await pumpScreen(tester);
    repo.emit([_item(1, 'Milk')]);
    await tester.pumpAndSettle();

    await tester.longPress(find.text('Milk'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ListTile, 'Rename'));
    await tester.pumpAndSettle();

    // Dialog is prefilled with the current label and offers a "Save" button.
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, 'Milk');
    expect(find.widgetWithText(FilledButton, 'Save'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Oat Milk');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(repo.renamed, [(1, 'Oat Milk')]);
  });

  testWidgets('tap toggles done', (tester) async {
    await pumpScreen(tester);
    repo.emit([_item(1, 'Milk')]);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Milk'));
    await tester.pumpAndSettle();

    expect(repo.toggled, [1]);
  });

  testWidgets('checked items render struck-through after the unchecked group',
      (tester) async {
    await pumpScreen(tester);
    // Emitted order mirrors watchItems: unchecked first, then checked.
    repo.emit([
      _item(1, 'Milk'),
      _item(2, 'Eggs', done: true),
    ]);
    await tester.pumpAndSettle();

    final eggs = tester.widget<Text>(find.text('Eggs'));
    expect(eggs.style?.decoration, TextDecoration.lineThrough);

    final milk = tester.widget<Text>(find.text('Milk'));
    expect(milk.style?.decoration, isNot(TextDecoration.lineThrough));
  });

  testWidgets('dragging the handle reorders only the unchecked group',
      (tester) async {
    await pumpScreen(tester);
    repo.emit([
      _item(1, 'Milk', position: 0),
      _item(2, 'Eggs', position: 1),
      _item(3, 'Bread', done: true, position: 2),
    ]);
    await tester.pumpAndSettle();

    // Only the two unchecked rows carry a drag handle; the checked row does not.
    final handles = find.byIcon(Icons.drag_handle);
    expect(handles, findsNWidgets(2));

    // Drag the second unchecked row's handle up past the first row, using an
    // explicit gesture with intermediate pumps so the ReorderableListView's
    // drag machinery registers the slot change reliably.
    final gesture =
        await tester.startGesture(tester.getCenter(handles.at(1)));
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.moveBy(const Offset(0, -80));
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.up();
    await tester.pumpAndSettle();

    // reorderItems was called with the unchecked group's ids only (no id 3),
    // in the new display order (Eggs ahead of Milk).
    expect(repo.reordered, hasLength(1));
    expect(repo.reordered.single, [2, 1]);
  });
}
