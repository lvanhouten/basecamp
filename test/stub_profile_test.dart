import 'package:basecamp/core/db/app_db.dart';
import 'package:basecamp/core/providers.dart';
import 'package:basecamp/core/settings.dart';
import 'package:basecamp/core/theme.dart';
import 'package:basecamp/core/widgets/components.dart';
import 'package:basecamp/features/activity/activity_screen.dart';
import 'package:basecamp/features/calendar/calendar_screen.dart';
import 'package:basecamp/features/goals/goals_screen.dart';
import 'package:basecamp/features/journal/journal_screen.dart';
import 'package:basecamp/features/profile/profile_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wraps a bar-destination BODY (no Scaffold of its own) in a themed Scaffold so
/// SafeArea/Material ancestors resolve.
Widget themedBody(Widget child) => MaterialApp(
      theme: basecampTheme(Brightness.light),
      home: Scaffold(body: child),
    );

/// Wraps a screen that brings its own Scaffold (Goals/Journal/Profile).
Widget themedScreen(Widget child) => MaterialApp(
      theme: basecampTheme(Brightness.light),
      darkTheme: basecampTheme(Brightness.dark),
      home: child,
    );

void main() {
  group('Calendar / Activity stubs (brief 07)', () {
    testWidgets('Calendar renders a heading + one calm empty line, no grid',
        (tester) async {
      await tester.pumpWidget(themedBody(const CalendarScreen()));
      await tester.pump();

      expect(find.text('Calendar'), findsOneWidget);
      expect(find.text('Nothing here yet.'), findsOneWidget);
      // No fabricated scheduling data / grid.
      expect(find.byType(GridView), findsNothing);
    });

    testWidgets('Activity renders a heading + one calm empty line; no '
        'feed/insights and no Friends/social UI', (tester) async {
      await tester.pumpWidget(themedBody(const ActivityScreen()));
      await tester.pump();

      expect(find.text('Activity'), findsOneWidget);
      expect(find.text('Nothing here yet.'), findsOneWidget);

      // No completion feed, no insights, no Friends/social — social is dropped
      // permanently (CONTEXT.md). No fabricated rows, no scope switcher.
      expect(find.byType(SegmentedControl<String>), findsNothing);
      expect(find.byType(BcListItem), findsNothing);
      expect(find.textContaining('Friend', findRichText: true), findsNothing);
      expect(find.textContaining('friend', findRichText: true), findsNothing);
    });
  });

  group('Goals / Journal stub modules (brief 07)', () {
    testWidgets('Goals renders as a styled placeholder screen with a back '
        'arrow and a calm line', (tester) async {
      // Pushed from a host route so the AppBar shows a back arrow.
      await tester.pumpWidget(themedScreen(
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const GoalsScreen()),
                ),
                child: const Text('go'),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();

      expect(find.byType(GoalsScreen), findsOneWidget);
      expect(find.widgetWithText(AppBar, 'Goals'), findsOneWidget);
      expect(find.text('Coming soon.'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
    });

    testWidgets('Journal renders as a styled placeholder screen', (tester) async {
      await tester.pumpWidget(themedScreen(const JournalScreen()));
      await tester.pump();

      expect(find.byType(JournalScreen), findsOneWidget);
      expect(find.widgetWithText(AppBar, 'Journal'), findsOneWidget);
      expect(find.text('Coming soon.'), findsOneWidget);
    });
  });

  group('Profile theme control (brief 07 drives brief 01 provider)', () {
    testWidgets('Profile reflects the current mode and drives the provider on '
        'selection, flipping the app theme immediately', (tester) async {
      // themeModeProvider hydrates + persists through the settings store →
      // dbProvider; back it with an in-memory DB so the async reads/writes are
      // real but don't touch disk (persistence itself is brief 01's test).
      final container = ProviderContainer(overrides: [
        dbProvider.overrideWithValue(AppDb.forTesting(NativeDatabase.memory())),
      ]);
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: themedScreen(
            Consumer(
              builder: (context, ref, _) => MaterialApp(
                theme: basecampTheme(Brightness.light),
                darkTheme: basecampTheme(Brightness.dark),
                themeMode: ref.watch(themeModeProvider),
                home: const ProfileScreen(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Reflects the current mode: starts at system (the build() default, also
      // what the fresh in-memory store hydrates to).
      expect(container.read(themeModeProvider), ThemeMode.system);
      expect(find.byType(SegmentedControl<ThemeMode>), findsOneWidget);

      // Selecting Dark drives the provider (the control calls .set).
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();
      expect(container.read(themeModeProvider), ThemeMode.dark);

      // The chosen mode is reflected back in the subtitle (current mode shown).
      expect(find.text('Dark'), findsWidgets);

      // Selecting Light flips it again — immediate, provider-driven.
      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();
      expect(container.read(themeModeProvider), ThemeMode.light);

      // System remains selectable too (light/dark/system control).
      await tester.tap(find.text('System'));
      await tester.pumpAndSettle();
      expect(container.read(themeModeProvider), ThemeMode.system);
    });

    testWidgets('Profile is a pushable screen with its own AppBar + back',
        (tester) async {
      final container = ProviderContainer(overrides: [
        dbProvider.overrideWithValue(AppDb.forTesting(NativeDatabase.memory())),
      ]);
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: themedScreen(
            Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const ProfileScreen(),
                      ),
                    ),
                    child: const Text('go'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();

      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(find.widgetWithText(AppBar, 'Profile'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
    });
  });
}
