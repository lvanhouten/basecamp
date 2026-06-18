import 'package:basecamp/core/db/app_db.dart';
import 'package:basecamp/core/providers.dart';
import 'package:basecamp/core/theme.dart';
import 'package:basecamp/core/widgets/components.dart';
import 'package:basecamp/features/clock/clock_screen.dart';
import 'package:basecamp/features/clock/clock_tab.dart';
import 'package:basecamp/features/clock/data/notification_scheduler.dart';
import 'package:basecamp/features/home/home_screen.dart';
import 'package:basecamp/features/profile/profile_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Every read model the Brief consumes (lists counts, clock alarms/timers)
  // flows through dbProvider; point it at an in-memory DB so mounting the Brief
  // never touches the real Drift file. A no-op scheduler keeps alarm/timer
  // creation from reaching the real plugin. The container lets a test seed data
  // and assert provider state.
  ProviderContainer makeContainer() {
    final db = AppDb.forTesting(NativeDatabase.memory());
    final container = ProviderContainer(
      overrides: [
        dbProvider.overrideWithValue(db),
        notificationSchedulerProvider
            .overrideWithValue(const NoopNotificationScheduler()),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
    });
    return container;
  }

  // The Brief is a bar-destination body (no Scaffold of its own — the shell owns
  // it). Wrap it in a Scaffold + the real theme (its widgets read BasecampTokens
  // — a bare MaterialApp throws a null-check, handoff 09). MaterialApp gives a
  // Navigator so the avatar push and module pushes resolve.
  Widget host(ProviderContainer container) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: basecampTheme(Brightness.light),
        home: const Scaffold(body: HomeScreen()),
      ),
    );
  }

  // Pump into a tall viewport so the whole digest lays out, then let the
  // Drift-backed StreamProviders deliver their first values. We flush real
  // microtasks via runAsync (the query I/O runs in the real async zone), then
  // pump the emissions in. We avoid pumpAndSettle: the Drift-backed streams keep
  // the widget reactive and settle never reliably quiesces (the repo's other
  // widget tests sidestep it the same way).
  Future<void> pumpBrief(
    WidgetTester tester,
    ProviderContainer container,
  ) async {
    tester.view.physicalSize = const Size(1000, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(host(container));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();
    await tester.pump();
  }

  group('Brief hero', () {
    testWidgets('renders a time-based greeting, a date eyebrow, and a profile '
        'avatar', (tester) async {
      await pumpBrief(tester, makeContainer());

      // Greeting is one of the three time-of-day forms (whichever the test
      // clock lands on) — and exactly one is present.
      final greetings = [
        'Good morning',
        'Good afternoon',
        'Good evening',
      ].where((g) => find.text(g).evaluate().isNotEmpty).toList();
      expect(greetings, hasLength(1));

      // Date eyebrow uses the "<Weekday> · <Mon> <day>" shape.
      expect(find.textContaining(' · '), findsWidgets);

      // The profile avatar affordance.
      expect(find.byKey(const ValueKey('brief-profile-avatar')), findsOneWidget);
    });

    testWidgets('greeting matches the time of day', (tester) async {
      // The greeting is derived from DateTime.now(); assert it agrees with the
      // wall clock the test is running under (deterministic for that run).
      await pumpBrief(tester, makeContainer());
      final hour = DateTime.now().hour;
      final expected = hour < 12
          ? 'Good morning'
          : hour < 18
              ? 'Good afternoon'
              : 'Good evening';
      expect(find.text(expected), findsOneWidget);
    });

    testWidgets('tapping the avatar pushes the Profile screen', (tester) async {
      await pumpBrief(tester, makeContainer());

      await tester.tap(find.byKey(const ValueKey('brief-profile-avatar')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(ProfileScreen), findsOneWidget);
    });
  });

  group('Brief progress card', () {
    testWidgets('with no lists shows a calm zero-state (no percent, calm line)',
        (tester) async {
      await pumpBrief(tester, makeContainer());

      // ProgressRing is always present.
      expect(find.byType(ProgressRing), findsOneWidget);
      // Zero-state headline + calm caption; no "N of M done today".
      expect(find.text('Nothing due today'), findsOneWidget);
      expect(find.text('Your lists are clear.'), findsOneWidget);
    });

    testWidgets('shows "N of M done today" derived from live list data',
        (tester) async {
      final container = makeContainer();
      final repo = container.read(listsRepositoryProvider);
      // Two lists; one cleared (no items), one with an open item → "1 of 2
      // done today".
      await tester.runAsync(() async {
        await repo.createList('Cleared');
        await repo.createList('Busy');
        final lists = await repo.watchLists().first;
        final busy = lists.firstWhere((r) => r.list.name == 'Busy');
        await repo.addItem(busy.list.id, 'Milk');
      });

      await pumpBrief(tester, container);

      expect(find.text('1 of 2 done today'), findsOneWidget);
      // One open item → the encouraging "one thing left" caption.
      expect(find.text('Nice pace — one thing left.'), findsOneWidget);
    });

    testWidgets('all lists cleared reads as all-done', (tester) async {
      final container = makeContainer();
      final repo = container.read(listsRepositoryProvider);
      await tester.runAsync(() async {
        await repo.createList('Done');
      });

      await pumpBrief(tester, container);

      expect(find.text('1 of 1 done today'), findsOneWidget);
      expect(find.text('All done — nice work.'), findsOneWidget);
    });
  });

  group('Brief "Up next today"', () {
    testWidgets('with nothing time-bound shows a one-line empty state',
        (tester) async {
      await pumpBrief(tester, makeContainer());

      expect(find.text('Up next today'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('brief-upnext-empty')),
        findsOneWidget,
      );
    });

    testWidgets('lists today\'s enabled alarms and running timers only',
        (tester) async {
      final container = makeContainer();
      final repo = container.read(clockRepositoryProvider);
      final now = DateTime.now();
      await tester.runAsync(() async {
        // A daily (recurring) alarm — always due today, enabled.
        await repo.createAlarm(
          timeOfDayMinutes: 7 * 60,
          repeatDays: 0x7F, // every day
          label: 'Wake up',
          now: now,
        );
        // A disabled alarm — must NOT appear.
        await repo.createAlarm(
          timeOfDayMinutes: 8 * 60,
          repeatDays: 0x7F,
          label: 'Snooze me',
          enabled: false,
          now: now,
        );
        // A running timer — must appear.
        await repo.createTimer(
          const Duration(minutes: 5),
          label: 'Tea',
          now: now,
        );
      });

      await pumpBrief(tester, container);

      // The empty state is gone; the time-bound rows are present.
      expect(find.byKey(const ValueKey('brief-upnext-empty')), findsNothing);
      expect(find.text('Wake up'), findsOneWidget);
      expect(find.text('Tea'), findsOneWidget);
      // The disabled alarm is excluded.
      expect(find.text('Snooze me'), findsNothing);
    });

    testWidgets('tapping a running-timer row opens Clock on the Timer tool',
        (tester) async {
      final container = makeContainer();
      final repo = container.read(clockRepositoryProvider);
      await tester.runAsync(() async {
        await repo.createTimer(
          const Duration(minutes: 5),
          label: 'Tea',
          now: DateTime.now(),
        );
      });

      await pumpBrief(tester, container);
      // Warm the count providers so pushModule's precedence reads settled values.
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump();

      await tester.tap(find.text('Tea'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(ClockScreen), findsOneWidget);
      // A running timer → entry-precedence lands on the Timer tool.
      expect(
        container.read(selectedClockTabProvider),
        equals(ClockTab.timer),
      );
    });
  });

  group('Brief no longer shows module summary cards', () {
    testWidgets('renders no module-name tiles (those moved to Modules)',
        (tester) async {
      await pumpBrief(tester, makeContainer());

      // The retired three-card summary used the module names as titles; none of
      // them appear on the Brief now.
      expect(find.text('Lists'), findsNothing);
      expect(find.text('Workouts'), findsNothing);
      expect(find.text('Clock'), findsNothing);
    });
  });
}
