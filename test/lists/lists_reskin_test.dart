import 'dart:async';

import 'package:basecamp/core/db/app_db.dart';
import 'package:basecamp/core/events/event_bus.dart';
import 'package:basecamp/core/providers.dart';
import 'package:basecamp/core/theme.dart';
import 'package:basecamp/core/widgets/components.dart';
import 'package:basecamp/features/lists/data/lists_dao.dart';
import 'package:basecamp/features/lists/data/lists_repository.dart';
import 'package:basecamp/features/lists/list_detail_screen.dart';
import 'package:basecamp/features/lists/lists_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Presentational regression tests for the design-system reskin (brief 08): the
/// Lists overview + detail render in the design language (BcListItem rows,
/// BcBadge counts, ProgressRing summary, brand-voice empty states) while every
/// behaviour from the existing Lists tests is unchanged (those live in
/// lists_screen_test.dart / list_detail_screen_test.dart and remain the
/// behavioural gate).

class _FakeListsRepository extends ListsRepository {
  _FakeListsRepository(super.dao, super.bus);

  final _lists = StreamController<List<TrackedListWithCount>>.broadcast();
  final _items = StreamController<List<ListItem>>.broadcast();

  void emitLists(List<TrackedListWithCount> rows) => _lists.add(rows);
  void emitItems(List<ListItem> items) => _items.add(items);

  @override
  Stream<List<TrackedListWithCount>> watchLists() => _lists.stream;

  @override
  Stream<List<ListItem>> watchItems(int listId) => _items.stream;

  Future<void> close() async {
    await _lists.close();
    await _items.close();
  }
}

TrackedListWithCount _list(int id, String name,
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
    db = AppDb.forTesting(NativeDatabase.memory());
    repo = _FakeListsRepository(db.listsDao, EventBus());
  });

  tearDown(() async {
    await repo.close();
    await db.close();
  });

  Widget wrap(Widget child) => ProviderScope(
        overrides: [listsRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          theme: basecampTheme(Brightness.light),
          home: child,
        ),
      );

  group('Lists overview reskin', () {
    testWidgets('rows render as BcListItem with a BcBadge open-item count',
        (tester) async {
      await tester.pumpWidget(wrap(const ListsScreen()));
      await tester.pump();
      repo.emitLists([_list(1, 'Groceries', openCount: 3)]);
      await tester.pumpAndSettle();

      expect(find.byType(BcListItem), findsOneWidget);
      // The open count surfaces as a design-system badge, not a stock Chip.
      expect(find.widgetWithText(BcBadge, '3'), findsOneWidget);
      expect(find.byType(Chip), findsNothing);
    });

    testWidgets('empty state is a single calm brand-voice line', (tester) async {
      await tester.pumpWidget(wrap(const ListsScreen()));
      await tester.pump();
      repo.emitLists(const []);
      await tester.pumpAndSettle();

      expect(find.text('No lists yet. Start one to keep track.'),
          findsOneWidget);
    });

    testWidgets('pushed route: no drawer', (tester) async {
      await tester.pumpWidget(wrap(const ListsScreen()));
      await tester.pump();
      repo.emitLists([_list(1, 'Groceries')]);
      await tester.pumpAndSettle();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.drawer, isNull);
    });
  });

  group('List detail reskin', () {
    testWidgets('rows render as BcListItem with a ProgressRing summary',
        (tester) async {
      await tester.pumpWidget(
        wrap(const ListDetailScreen(listId: 1, title: 'Groceries')),
      );
      await tester.pump();
      repo.emitItems([
        _item(1, 'Milk'),
        _item(2, 'Eggs', done: true),
      ]);
      await tester.pumpAndSettle();

      expect(find.byType(BcListItem), findsNWidgets(2));
      // The completion summary ring shows a tabular done/total count.
      expect(find.byType(ProgressRing), findsOneWidget);
      expect(find.text('1/2'), findsOneWidget);
    });

    testWidgets('empty state is a single calm brand-voice line', (tester) async {
      await tester.pumpWidget(
        wrap(const ListDetailScreen(listId: 1, title: 'Groceries')),
      );
      await tester.pump();
      repo.emitItems(const []);
      await tester.pumpAndSettle();

      expect(find.text('Nothing here yet. Add the first item.'),
          findsOneWidget);
      // No summary ring on an empty list.
      expect(find.byType(ProgressRing), findsNothing);
    });

    testWidgets('checked items still strike through; unchecked do not',
        (tester) async {
      await tester.pumpWidget(
        wrap(const ListDetailScreen(listId: 1, title: 'Groceries')),
      );
      await tester.pump();
      repo.emitItems([
        _item(1, 'Milk'),
        _item(2, 'Eggs', done: true),
      ]);
      await tester.pumpAndSettle();

      final eggs = tester.widget<Text>(find.text('Eggs'));
      expect(eggs.style?.decoration, TextDecoration.lineThrough);
      final milk = tester.widget<Text>(find.text('Milk'));
      expect(milk.style?.decoration, isNot(TextDecoration.lineThrough));
    });
  });
}
