import 'package:basecamp/core/app_module.dart';
import 'package:basecamp/core/db/app_db.dart';
import 'package:basecamp/core/providers.dart';
import 'package:basecamp/core/theme.dart';
import 'package:basecamp/features/goals/goals_screen.dart';
import 'package:basecamp/features/journal/journal_screen.dart';
import 'package:basecamp/features/lists/lists_screen.dart';
import 'package:basecamp/features/modules/modules_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // All summary read models (lists counts, clock counts) flow through
  // dbProvider; point it at an in-memory database so mounting the grid (and any
  // pushed module screen) never touches the real on-disk Drift file. The
  // returned container lets a test seed Lists data and assert provider state.
  ProviderContainer makeContainer() {
    final db = AppDb.forTesting(NativeDatabase.memory());
    final container = ProviderContainer(
      overrides: [dbProvider.overrideWithValue(db)],
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
    });
    return container;
  }

  // The grid is a bar-destination body (no Scaffold of its own — the shell owns
  // it), so wrap it in a Scaffold here to host the coming-soon ScaffoldMessenger
  // and apply the real theme (the tiles read BasecampTokens from it).
  Widget host(ProviderContainer container) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: basecampTheme(Brightness.light),
        home: const Scaffold(body: ModulesScreen()),
      ),
    );
  }

  // Pump the grid into a tall viewport so the lazy ListView lays out every tile
  // at once (the default 800×600 test surface clips the last tile off-screen,
  // and a ListView never builds off-screen children — so finders would miss
  // them). Restores the view on teardown.
  Future<void> pumpGrid(
    WidgetTester tester,
    ProviderContainer container,
  ) async {
    tester.view.physicalSize = const Size(1000, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(host(container));
    // Let the count StreamProviders deliver their first values. The streams are
    // backed by a real Drift (in-memory) DB whose query I/O runs in the real
    // async zone, so we flush real microtasks via runAsync, then pump the
    // resulting emissions into the meta lines. We avoid pumpAndSettle: the
    // Drift-backed streams keep the widget reactive and settle never reliably
    // quiesces (the repo's clock/lists widget tests sidestep it the same way).
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();
    await tester.pump();
  }

  group('ModulesScreen grid', () {
    testWidgets('renders a tile per AppModule with icon, name, and meta',
        (tester) async {
      await pumpGrid(tester, makeContainer());

      // One raised-card tile per module (the Add affordance is not a Card).
      expect(find.byType(Card), findsNWidgets(AppModule.values.length));

      for (final m in AppModule.values) {
        expect(find.text(m.label), findsOneWidget);
        expect(find.byIcon(m.icon), findsOneWidget);
      }

      // Quiet meta for the three data-less modules (workouts/goals/journal).
      expect(find.text('No activity yet'), findsNWidgets(3));
    });

    testWidgets('Lists tile shows live summary meta from the read models',
        (tester) async {
      final container = makeContainer();
      final repo = container.read(listsRepositoryProvider);
      // Seed real Drift rows in the real async zone (tester.runAsync) — awaiting
      // DB I/O directly in the fake-async test body would hang. Two lists; one
      // with two open items → "2 lists · 2 open".
      await tester.runAsync(() async {
        await repo.createList('Groceries');
        await repo.createList('Chores');
        final lists = await repo.watchLists().first;
        final groceries = lists.firstWhere((r) => r.list.name == 'Groceries');
        await repo.addItem(groceries.list.id, 'Milk');
        await repo.addItem(groceries.list.id, 'Eggs');
      });

      await pumpGrid(tester, container);

      expect(find.text('2 lists · 2 open'), findsOneWidget);
    });

    testWidgets('Lists meta with no lists reads "0 lists" (no open clause)',
        (tester) async {
      await pumpGrid(tester, makeContainer());

      expect(find.text('0 lists'), findsOneWidget);
    });

    testWidgets('Clock tile shows the quiet "No alarms today" meta at rest',
        (tester) async {
      await pumpGrid(tester, makeContainer());

      // Nothing in progress, no alarms enabled today → the quiet clock meta.
      expect(find.text('No alarms today'), findsOneWidget);
    });
  });

  // Drive a tile tap and let the push route transition run. We pump a fixed
  // span rather than pumpAndSettle: some module screens (e.g. Lists) show a
  // CircularProgressIndicator while their Drift stream loads, which schedules
  // frames forever and would make pumpAndSettle hang.
  Future<void> tapAndLand(WidgetTester tester, String tileLabel) async {
    await tester.tap(find.text(tileLabel));
    await tester.pump(); // start the route push
    await tester.pump(const Duration(milliseconds: 400)); // run the transition
  }

  group('ModulesScreen tile taps push the module screen', () {
    testWidgets('Goals tile pushes the Goals stub screen', (tester) async {
      await pumpGrid(tester, makeContainer());

      await tapAndLand(tester, 'Goals');

      expect(find.byType(GoalsScreen), findsOneWidget);
    });

    testWidgets('Journal tile pushes the Journal stub screen', (tester) async {
      await pumpGrid(tester, makeContainer());

      await tapAndLand(tester, 'Journal');

      expect(find.byType(JournalScreen), findsOneWidget);
    });

    testWidgets('Lists tile pushes the Lists screen', (tester) async {
      await pumpGrid(tester, makeContainer());

      await tapAndLand(tester, 'Lists');

      expect(find.byType(ListsScreen), findsOneWidget);
    });
  });

  group('Add a module affordance', () {
    testWidgets('shows a coming-soon snackbar and pushes nothing',
        (tester) async {
      await pumpGrid(tester, makeContainer());

      await tester.tap(find.text('New module'));
      await tester.pump(); // let the snackbar mount

      expect(find.text('Add a module — coming soon'), findsOneWidget);
      // No real add flow: still on the grid, no module screen pushed.
      expect(find.byType(ModulesScreen), findsOneWidget);
      expect(find.byType(GoalsScreen), findsNothing);
    });
  });

  group('design-system styling', () {
    testWidgets('tiles use the themed Card (raised-card tile look)',
        (tester) async {
      await pumpGrid(tester, makeContainer());

      // The tiles use the themed Card; the CardTheme in basecampTheme supplies
      // the soft radius + navy-tinted shadow, so the tile doesn't hardcode them.
      expect(find.byType(Card), findsNWidgets(AppModule.values.length));
    });
  });
}
