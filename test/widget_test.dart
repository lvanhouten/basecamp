import 'package:basecamp/app.dart';
import 'package:basecamp/core/app_module.dart';
import 'package:basecamp/core/providers.dart';
import 'package:basecamp/core/widgets/app_drawer.dart';
import 'package:basecamp/features/home/home_screen.dart';
import 'package:basecamp/features/lists/data/lists_dao.dart';
import 'package:basecamp/features/lists/lists_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Stubs the reactive read models the Brief depends on, so no real DB is opened.
/// The Clock counts are stubbed too: as of 04-timer-data `watchRunningTimerCount`
/// is a real Drift query, so without these overrides the Brief card would open
/// the real DB + notification scheduler during the test.
final _dbStubs = [
  listCountProvider.overrideWith((ref) => Stream.value(0)),
  openItemCountProvider.overrideWith((ref) => Stream.value(0)),
  listsProvider.overrideWith((ref) => Stream.value(<TrackedListWithCount>[])),
  todaysAlarmCountProvider.overrideWith((ref) => Stream.value(0)),
  runningTimerCountProvider.overrideWith((ref) => Stream.value(0)),
  stopwatchRunningProvider.overrideWith((ref) => Stream.value(false)),
];

void main() {
  testWidgets('boots into the Brief hub, no bottom bar (DB stubbed)',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(overrides: _dbStubs, child: const BasecampApp()),
    );
    await tester.pump();

    // Modules live in an IndexedStack now; the bottom NavigationBar is gone.
    expect(find.byType(IndexedStack), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    // Brief is the default module: its app bar + summary cards render.
    expect(find.widgetWithText(AppBar, 'Basecamp'), findsOneWidget);
    expect(find.byType(Card), findsWidgets);
  });

  testWidgets('drawer destination switches the selected module', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final scaffoldKey = GlobalKey<ScaffoldState>();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(key: scaffoldKey, drawer: const AppDrawer()),
        ),
      ),
    );
    scaffoldKey.currentState!.openDrawer();
    await tester.pumpAndSettle();

    expect(container.read(selectedModuleProvider), AppModule.brief);

    await tester.tap(find.text('Workouts'));
    await tester.pumpAndSettle(); // drawer closes + selection updates

    expect(container.read(selectedModuleProvider), AppModule.workouts);
  });

  testWidgets('Brief card tap switches the selected module', (tester) async {
    final container = ProviderContainer(overrides: _dbStubs);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump();

    expect(container.read(selectedModuleProvider), AppModule.brief);

    // Scope to the Card so we don't collide with the drawer's 'Clock' label.
    await tester.tap(find.widgetWithText(Card, 'Clock'));
    await tester.pump();

    expect(container.read(selectedModuleProvider), AppModule.clock);
  });

  testWidgets('Android back from a module returns to the Brief', (tester) async {
    final container = ProviderContainer(overrides: _dbStubs);
    addTearDown(container.dispose);
    container.read(selectedModuleProvider.notifier).select(AppModule.workouts);

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const BasecampApp()),
    );
    await tester.pump();
    expect(container.read(selectedModuleProvider), AppModule.workouts);

    await tester.binding.handlePopRoute(); // simulate system back
    await tester.pump();

    expect(container.read(selectedModuleProvider), AppModule.brief);
  });

  group('promptForText', () {
    testWidgets('no initial value: empty field, "Add" button', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      final ctx = tester.element(find.byType(Scaffold));

      final future = promptForText(ctx, title: 'Title', hint: 'Hint');
      await tester.pumpAndSettle();

      // Field is empty.
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, '');
      // Confirm button defaults to "Add".
      expect(find.widgetWithText(FilledButton, 'Add'), findsOneWidget);

      // Cancel returns null.
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();
      expect(await future, isNull);
    });

    testWidgets('initial value pre-fills the field', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      final ctx = tester.element(find.byType(Scaffold));

      final future = promptForText(
        ctx,
        title: 'Title',
        hint: 'Hint',
        initialValue: 'Groceries',
      );
      await tester.pumpAndSettle();

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, 'Groceries');
      // Pre-selected so a keystroke replaces it.
      expect(field.controller!.selection.baseOffset, 0);
      expect(field.controller!.selection.extentOffset, 'Groceries'.length);

      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();
      expect(await future, isNull);
    });

    testWidgets('confirm button shows the supplied action label',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      final ctx = tester.element(find.byType(Scaffold));

      final future = promptForText(
        ctx,
        title: 'Rename',
        hint: 'Hint',
        initialValue: 'Old',
        actionLabel: 'Save',
      );
      await tester.pumpAndSettle();

      expect(find.widgetWithText(FilledButton, 'Save'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Add'), findsNothing);

      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();
      await future;
    });

    testWidgets('returns the trimmed input on confirm', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      final ctx = tester.element(find.byType(Scaffold));

      final future = promptForText(ctx, title: 'Title', hint: 'Hint');
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '  Milk  ');
      await tester.tap(find.widgetWithText(FilledButton, 'Add'));
      await tester.pumpAndSettle();

      expect(await future, 'Milk');
    });

    testWidgets('returns null on cancel', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      final ctx = tester.element(find.byType(Scaffold));

      final future = promptForText(ctx, title: 'Title', hint: 'Hint');
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'discarded');
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      expect(await future, isNull);
    });
  });
}
