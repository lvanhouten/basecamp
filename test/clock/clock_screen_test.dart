import 'package:basecamp/core/db/app_db.dart';
import 'package:basecamp/core/providers.dart';
import 'package:basecamp/core/widgets/app_drawer.dart';
import 'package:basecamp/features/clock/clock_screen.dart';
import 'package:basecamp/features/clock/clock_tab.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // The Stopwatch tab embeds StopwatchPane (03-stopwatch), which watches the
  // clock repository → dbProvider. Point dbProvider at an in-memory database so
  // mounting the screen (any tab) never opens the real on-disk Drift file.
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

  group('ClockScreen', () {
    testWidgets('renders three tabs, the hub drawer, and lands on Alarms',
        (tester) async {
      final container = makeContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: ClockScreen()),
        ),
      );
      await tester.pump();

      // Hub drawer present on the module root. The Scaffold builds its `drawer`
      // lazily (only when opened), so assert the slot is wired rather than
      // searching the live tree for the AppDrawer widget.
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.drawer, isA<AppDrawer>());

      // Three tool tabs.
      expect(find.byType(Tab), findsNWidgets(3));
      expect(find.widgetWithText(Tab, 'Alarms'), findsOneWidget);
      expect(find.widgetWithText(Tab, 'Timer'), findsOneWidget);
      expect(find.widgetWithText(Tab, 'Stopwatch'), findsOneWidget);

      // Resting default landing tab is Alarms — both the controller index and
      // the shared tab state agree.
      final tabBar = tester.widget<TabBar>(find.byType(TabBar));
      expect(tabBar.controller!.index, ClockTab.alarms.index);
      expect(container.read(selectedClockTabProvider), ClockTab.alarms);
    });

    testWidgets('seeds the controller from an entry tab set before mount',
        (tester) async {
      final container = makeContainer();
      // Simulate the Brief card having chosen the Stopwatch tab on tap.
      container.read(selectedClockTabProvider.notifier).select(ClockTab.stopwatch);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: ClockScreen()),
        ),
      );
      await tester.pump();

      final tabBar = tester.widget<TabBar>(find.byType(TabBar));
      expect(tabBar.controller!.index, ClockTab.stopwatch.index);
    });

    testWidgets('a manual tab tap persists into the shared tab state',
        (tester) async {
      final container = makeContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: ClockScreen()),
        ),
      );
      await tester.pump();

      await tester.tap(find.widgetWithText(Tab, 'Timer'));
      await tester.pumpAndSettle();

      expect(container.read(selectedClockTabProvider), ClockTab.timer);
    });

    testWidgets('an external entry-tab change moves the live controller',
        (tester) async {
      final container = makeContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: ClockScreen()),
        ),
      );
      await tester.pump();

      // The screen is alive; the Brief card writes a new entry tab.
      container
          .read(selectedClockTabProvider.notifier)
          .select(ClockTab.stopwatch);
      await tester.pumpAndSettle();

      final tabBar = tester.widget<TabBar>(find.byType(TabBar));
      expect(tabBar.controller!.index, ClockTab.stopwatch.index);
    });
  });
}
