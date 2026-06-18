import 'package:basecamp/app.dart';
import 'package:basecamp/core/app_module.dart';
import 'package:basecamp/core/bar_destination.dart';
import 'package:basecamp/core/db/app_db.dart';
import 'package:basecamp/core/home_shell.dart';
import 'package:basecamp/core/providers.dart';
import 'package:basecamp/core/theme.dart';
import 'package:basecamp/core/widgets/components.dart';
import 'package:basecamp/features/activity/activity_screen.dart';
import 'package:basecamp/features/calendar/calendar_screen.dart';
import 'package:basecamp/features/clock/alarm_launch_host.dart';
import 'package:basecamp/features/clock/clock_screen.dart';
import 'package:basecamp/features/clock/clock_tab.dart';
import 'package:basecamp/features/clock/data/alarm_launch_router.dart';
import 'package:basecamp/features/home/home_screen.dart';
import 'package:basecamp/features/lists/data/lists_dao.dart';
import 'package:basecamp/features/lists/lists_screen.dart';
import 'package:basecamp/features/modules/modules_screen.dart';
import 'package:basecamp/features/workouts/workouts_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

/// Stubs the reactive read models the shell + modules depend on, so no real DB
/// is opened. The Clock counts are stubbed too: `watchRunningTimerCount` /
/// `watchStopwatchRunning` are real Drift queries, so without these overrides
/// entering Clock (and the Modules placeholder building) would open the real
/// on-disk Drift file + notification scheduler.
List<Override> dbStubs({
  bool stopwatchRunning = false,
  int runningTimers = 0,
  int alarmsToday = 0,
}) =>
    [
      dbProvider.overrideWithValue(AppDb.forTesting(NativeDatabase.memory())),
      listCountProvider.overrideWith((ref) => Stream.value(0)),
      openItemCountProvider.overrideWith((ref) => Stream.value(0)),
      listsProvider.overrideWith((ref) => Stream.value(<TrackedListWithCount>[])),
      todaysAlarmCountProvider.overrideWith((ref) => Stream.value(alarmsToday)),
      runningTimerCountProvider.overrideWith((ref) => Stream.value(runningTimers)),
      stopwatchRunningProvider.overrideWith((ref) => Stream.value(stopwatchRunning)),
      // The Alarms pane (08-alarm-ui) watches alarmsProvider; stub it so the pane
      // doesn't open a live Drift query stream.
      alarmsProvider.overrideWith((ref) => Stream.value(const <AlarmRow>[])),
      // The Brief (05-brief-screen) watches the running-timers stream for its
      // "Up next today" rows; stub it so mounting the shell (whose Brief body is
      // now the real digest) doesn't open a live Drift query stream + leave a
      // pending timer on dispose.
      runningTimersProvider.overrideWith((ref) => Stream.value(const <TimerRow>[])),
      // BasecampApp wraps the shell in an AlarmLaunchHost which reads the launch
      // router post-frame; the real one hits the notifications plugin. No-op it.
      alarmLaunchRouterProvider.overrideWithValue(NoopAlarmLaunchRouter()),
    ];

/// The launcher bar reads `BasecampTokens` from the theme extension, so any
/// harness that mounts [HomeShell] directly must supply the basecamp theme
/// (BasecampApp does this itself; a bare MaterialApp does not).
Widget themedShell(Widget child) => MaterialApp(
      theme: basecampTheme(Brightness.light),
      home: child,
    );

void main() {
  group('Launcher shell (ADR-0005)', () {
    testWidgets('boots into the launcher shell: four-destination bar + FAB, '
        'no drawer anywhere', (tester) async {
      await tester.pumpWidget(
        ProviderScope(overrides: dbStubs(), child: const BasecampApp()),
      );
      await tester.pump();

      // The launcher bar is present; the retired drawer chrome is gone.
      expect(find.byType(LauncherTabBar<BarDestination>), findsOneWidget);
      expect(find.byType(NavigationDrawer), findsNothing);
      expect(find.byType(Drawer), findsNothing);

      // The four fixed destinations are labelled in the bar.
      for (final d in BarDestination.values) {
        expect(find.text(d.label), findsWidgets);
      }

      // The center ⊕ Quick add action is rendered (a separate, non-destination
      // FAB — verified by its accessible label / tooltip).
      expect(find.byTooltip('Quick add'), findsOneWidget);

      // The shell's Scaffold carries no drawer.
      final shellScaffold = tester.widget<Scaffold>(
        find.descendant(
          of: find.byType(HomeShell),
          matching: find.byType(Scaffold),
        ).first,
      );
      expect(shellScaffold.drawer, isNull);

      // Brief is the resting default destination.
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('switching among the four bar destinations does not unmount '
        'them (kept-alive IndexedStack body)', (tester) async {
      final container = ProviderContainer(overrides: dbStubs());
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: themedShell(const HomeShell()),
        ),
      );
      await tester.pump();

      expect(container.read(selectedBarProvider), BarDestination.brief);

      // All four destinations live in an IndexedStack, so each is mounted at
      // once regardless of which is on top (the inactive ones are Offstage, so
      // skipOffstage:false is needed to see them).
      expect(find.byType(HomeScreen, skipOffstage: false), findsOneWidget);
      expect(find.byType(CalendarScreen, skipOffstage: false), findsOneWidget);
      expect(find.byType(ActivityScreen, skipOffstage: false), findsOneWidget);
      expect(find.byType(ModulesScreen, skipOffstage: false), findsOneWidget);

      // Tap the Modules destination in the bar; selection updates and nothing
      // unmounts.
      await tester.tap(find.descendant(
        of: find.byType(LauncherTabBar<BarDestination>),
        matching: find.text('Modules'),
      ));
      await tester.pumpAndSettle();

      expect(container.read(selectedBarProvider), BarDestination.modules);
      // The Brief is still mounted (Offstage), proving no unmount on switch.
      expect(find.byType(HomeScreen, skipOffstage: false), findsOneWidget);
      expect(find.byType(ModulesScreen), findsOneWidget);
    });

    testWidgets('the ⊕ FAB invokes its no-op action and never selects a '
        'destination', (tester) async {
      final container = ProviderContainer(overrides: dbStubs());
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: themedShell(const HomeShell()),
        ),
      );
      await tester.pump();

      final before = container.read(selectedBarProvider);
      await tester.tap(find.byTooltip('Quick add'));
      await tester.pump();

      // Selection is untouched (the FAB is an action, never a destination).
      expect(container.read(selectedBarProvider), before);
      // The "coming soon" acknowledgement shows.
      expect(find.text('Quick add — coming soon'), findsOneWidget);
    });
  });

  group('Module push navigation (ADR-0005)', () {
    // Mounts the Modules grid directly (under a real Navigator) so the tile-tap
    // push path is exercised cleanly. The grid is the same widget the launcher
    // shell hosts as its Modules bar body; a separate shell test pins the bar /
    // IndexedStack wiring. (A shell-hosted IndexedStack body keeps every
    // destination mounted, which confounds onstage tile finders — testing the
    // grid in isolation keeps the push assertion deterministic.)
    Future<void> pumpModulesGrid(
      WidgetTester tester,
      ProviderContainer container,
    ) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: themedShell(const ModulesScreen()),
        ),
      );
      await tester.pump();
    }

    testWidgets('tapping a Modules tile pushes the module; back returns to '
        'the grid', (tester) async {
      final container = ProviderContainer(overrides: dbStubs());
      addTearDown(container.dispose);
      await pumpModulesGrid(tester, container);

      // Tap the Workouts tile → it is pushed over the grid.
      await tester.tap(find.text('Workouts'));
      await tester.pumpAndSettle();

      expect(find.byType(WorkoutsScreen), findsOneWidget);
      // The grid is now covered by the pushed route.
      expect(find.byType(ModulesScreen), findsNothing);

      // The pushed route shows a back arrow; tapping it returns to the grid.
      expect(find.byType(BackButton), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.byType(WorkoutsScreen), findsNothing);
      expect(find.byType(ModulesScreen), findsOneWidget);
    });

    testWidgets('every module (incl. Goals & Journal) pushes its screen',
        (tester) async {
      final container = ProviderContainer(overrides: dbStubs());
      addTearDown(container.dispose);
      await pumpModulesGrid(tester, container);

      // All five grid modules are present, including the new stub modules.
      for (final m in AppModule.values) {
        expect(find.text(m.label), findsOneWidget);
      }
      // Goals and Journal are real tiles that push a placeholder screen.
      await tester.tap(find.text('Goals'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Goals'), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Journal'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Journal'), findsOneWidget);
    });
  });

  group('Domain-state landing (ADR-0004 precedence on module entry)', () {
    // Enters Clock via the Modules tile (the real push path) and asserts the
    // tab it lands on, driven by the seeded live counts. Landing is computed on
    // ENTRY from Drift-derived state, not a remembered route.
    Future<void> enterClock(
      WidgetTester tester,
      ProviderContainer container,
    ) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: themedShell(const ModulesScreen()),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Clock'));
      await tester.pumpAndSettle();
    }

    testWidgets('running stopwatch → Clock lands on the Stopwatch tab',
        (tester) async {
      final container = ProviderContainer(
        overrides: dbStubs(stopwatchRunning: true, runningTimers: 2, alarmsToday: 4),
      );
      addTearDown(container.dispose);

      await enterClock(tester, container);

      expect(find.byType(ClockScreen), findsOneWidget);
      expect(container.read(selectedClockTabProvider), ClockTab.stopwatch);
      final tabBar = tester.widget<TabBar>(find.byType(TabBar));
      expect(tabBar.controller!.index, ClockTab.stopwatch.index);
    });

    testWidgets('running timer (no stopwatch) → Clock lands on the Timer tab',
        (tester) async {
      final container = ProviderContainer(
        overrides: dbStubs(stopwatchRunning: false, runningTimers: 1, alarmsToday: 4),
      );
      addTearDown(container.dispose);

      await enterClock(tester, container);

      expect(container.read(selectedClockTabProvider), ClockTab.timer);
      final tabBar = tester.widget<TabBar>(find.byType(TabBar));
      expect(tabBar.controller!.index, ClockTab.timer.index);
    });

    testWidgets('nothing in progress → Clock lands on the resting default '
        '(Alarms)', (tester) async {
      final container = ProviderContainer(
        overrides: dbStubs(stopwatchRunning: false, runningTimers: 0, alarmsToday: 9),
      );
      addTearDown(container.dispose);

      await enterClock(tester, container);

      // Alarms are scheduled future state, never a Resume target — they only
      // win by default, so a high alarm count still lands on Alarms.
      expect(container.read(selectedClockTabProvider), ClockTab.alarms);
      final tabBar = tester.widget<TabBar>(find.byType(TabBar));
      expect(tabBar.controller!.index, ClockTab.alarms.index);
    });
  });

  group('Alarm full-screen launch host (ADR-0003/0004)', () {
    testWidgets('the shell is hosted under an AlarmLaunchHost so a full-screen '
        'alarm routes above it', (tester) async {
      await tester.pumpWidget(
        ProviderScope(overrides: dbStubs(), child: const BasecampApp()),
      );
      await tester.pump();

      // The launcher shell sits beneath the alarm launch host (which pushes the
      // ring screen onto the root navigator above it). Detailed cold/warm
      // routing is covered in alarm_launch_routing_test.dart.
      expect(find.byType(AlarmLaunchHost), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AlarmLaunchHost),
          matching: find.byType(HomeShell),
        ),
        findsOneWidget,
      );
    });
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
