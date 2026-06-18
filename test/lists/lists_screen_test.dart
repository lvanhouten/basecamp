import 'dart:async';

import 'package:basecamp/core/db/app_db.dart';
import 'package:basecamp/core/events/event_bus.dart';
import 'package:basecamp/core/providers.dart';
import 'package:basecamp/core/theme.dart';
import 'package:basecamp/features/lists/data/lists_dao.dart';
import 'package:basecamp/features/lists/data/lists_repository.dart';
import 'package:basecamp/features/lists/lists_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A test double for [ListsRepository]. It satisfies the concrete super-type by
/// handing throwaway in-memory infra to `super`, then overrides every method the
/// Lists screen actually calls so the test can drive [watchLists] and assert on
/// recorded calls (e.g. that UNDO restored a snapshot).
class _FakeListsRepository extends ListsRepository {
  _FakeListsRepository(super.dao, super.bus);

  final _controller = StreamController<List<TrackedListWithCount>>.broadcast();

  // Recorded calls, for assertions.
  final List<int> deleted = [];
  final List<int> snapshotted = [];
  final List<ListSnapshot> restored = [];
  final List<(int, bool)> pinnedCalls = [];
  final List<(int, String)> renamed = [];
  final List<List<int>> reordered = [];
  final List<String> created = [];

  void emit(List<TrackedListWithCount> rows) => _controller.add(rows);

  @override
  Stream<List<TrackedListWithCount>> watchLists() => _controller.stream;

  @override
  Future<ListSnapshot> snapshotList(int listId) async {
    snapshotted.add(listId);
    // A plausible snapshot for the deleted list; contents are irrelevant to the
    // screen — it only round-trips the object back to restoreList on UNDO.
    return ListSnapshot(
      TrackedList(
        id: listId,
        name: 'snap-$listId',
        createdAt: DateTime(2026),
        pinned: false,
        position: 0,
      ),
      const [],
    );
  }

  @override
  Future<void> deleteList(int id) async => deleted.add(id);

  @override
  Future<int> restoreList(ListSnapshot snapshot) async {
    restored.add(snapshot);
    return 999;
  }

  @override
  Future<void> setPinned(int listId, bool pinned) async =>
      pinnedCalls.add((listId, pinned));

  @override
  Future<void> renameList(int listId, String name) async =>
      renamed.add((listId, name));

  @override
  Future<void> reorderLists(List<int> orderedIds) async =>
      reordered.add(orderedIds);

  @override
  Future<void> createList(String name) async => created.add(name);

  Future<void> closeStream() async => _controller.close();
}

TrackedListWithCount _row(int id, String name,
    {bool pinned = false, int position = 0, int openCount = 0}) {
  return TrackedListWithCount(
    TrackedList(
      id: id,
      name: name,
      createdAt: DateTime(2026, 1, 1).add(Duration(seconds: id)),
      pinned: pinned,
      position: position,
    ),
    openCount,
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
        // The reskinned screen reads BasecampTokens from the theme extension
        // (brief 08), so the harness must supply the basecamp theme.
        child: MaterialApp(
          theme: basecampTheme(Brightness.light),
          home: const ListsScreen(),
        ),
      ),
    );
    // First frame: the StreamProvider has no value yet (loading spinner). The
    // caller emits rows then pumps again.
    await tester.pump();
  }

  testWidgets(
      'deleting a list shows a SnackBar with UNDO; UNDO restores the list',
      (tester) async {
    await pumpScreen(tester);
    repo.emit([_row(1, 'Groceries')]);
    await tester.pumpAndSettle();

    // Swipe the row away to delete it.
    await tester.drag(find.text('Groceries'), const Offset(-500, 0));
    await tester.pumpAndSettle();

    // The list was snapshotted BEFORE delete, then deleted.
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
    expect(repo.restored.single.list.id, 1);
  });

  testWidgets('Pinned header renders only when a pinned list exists',
      (tester) async {
    await pumpScreen(tester);

    // No pinned lists -> no "Pinned" header.
    repo.emit([_row(1, 'Groceries'), _row(2, 'Movies')]);
    await tester.pumpAndSettle();
    expect(find.text('Pinned'), findsNothing);

    // Pin one list -> the "Pinned" header appears.
    repo.emit([
      _row(2, 'Movies', pinned: true),
      _row(1, 'Groceries'),
    ]);
    await tester.pumpAndSettle();
    expect(find.text('Pinned'), findsOneWidget);
  });

  testWidgets('long-press menu Delete shows the UNDO SnackBar', (tester) async {
    await pumpScreen(tester);
    repo.emit([_row(1, 'Groceries')]);
    await tester.pumpAndSettle();

    await tester.longPress(find.text('Groceries'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ListTile, 'Delete'));
    await tester.pumpAndSettle();

    expect(repo.deleted, [1]);
    expect(find.widgetWithText(SnackBarAction, 'Undo'), findsOneWidget);
  });

  testWidgets('long-press menu Pin toggles the pinned state', (tester) async {
    await pumpScreen(tester);
    repo.emit([_row(1, 'Groceries')]);
    await tester.pumpAndSettle();

    await tester.longPress(find.text('Groceries'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ListTile, 'Pin'));
    await tester.pumpAndSettle();

    expect(repo.pinnedCalls, [(1, true)]);
  });

  testWidgets('long-press menu Rename applies the new name on Save',
      (tester) async {
    await pumpScreen(tester);
    repo.emit([_row(1, 'Groceries')]);
    await tester.pumpAndSettle();

    await tester.longPress(find.text('Groceries'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ListTile, 'Rename'));
    await tester.pumpAndSettle();

    // Dialog is prefilled with the current name and offers a "Save" button.
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, 'Groceries');
    expect(find.widgetWithText(FilledButton, 'Save'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Shopping');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(repo.renamed, [(1, 'Shopping')]);
  });
}
