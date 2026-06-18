import 'package:basecamp/core/theme.dart';
import 'package:basecamp/core/widgets/components.dart';
import 'package:basecamp/features/workouts/workouts_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wraps a screen that brings its own Scaffold (Workouts is a pushed module).
/// Themed widgets read the `BasecampTokens` extension, so the test MUST pump
/// with `basecampTheme` applied — a bare MaterialApp would throw (brief 09).
Widget themedScreen(Widget child) => MaterialApp(
      theme: basecampTheme(Brightness.light),
      darkTheme: basecampTheme(Brightness.dark),
      home: child,
    );

void main() {
  group('Workouts stub reskin (brief 10)', () {
    testWidgets(
        'renders in the design language with a heading and one calm '
        'brand-voice line (sentence case, emoji-free)', (tester) async {
      await tester.pumpWidget(themedScreen(const WorkoutsScreen()));
      await tester.pump();

      // Heading (the module name) + a single calm line.
      expect(find.widgetWithText(AppBar, 'Workouts'), findsOneWidget);
      expect(find.text('Workouts'), findsWidgets);
      expect(find.text('Coming soon.'), findsOneWidget);

      // Design-language surface: uses the shared design-system stub body and
      // its tinted leading icon tile (not a stock Material card/list).
      expect(find.byType(BcListItemIcon), findsOneWidget);

      // No fabricated workout data / affordances while it remains a stub:
      // no "start workout" CTA, no FAB, no list/grid of sessions.
      expect(find.byType(FloatingActionButton), findsNothing);
      expect(find.byType(GridView), findsNothing);
      expect(find.byType(BcListItem), findsNothing);
      expect(find.textContaining('Start', findRichText: true), findsNothing);
      expect(find.textContaining('sets', findRichText: true), findsNothing);

      // Emoji-free brand voice.
      final lineText = tester.widget<Text>(find.text('Coming soon.'));
      expect(_hasEmoji(lineText.data!), isFalse);
    });

    testWidgets('works as a pushed route: back arrow, no drawer',
        (tester) async {
      await tester.pumpWidget(themedScreen(
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const WorkoutsScreen(),
                  ),
                ),
                child: const Text('go'),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();

      expect(find.byType(WorkoutsScreen), findsOneWidget);
      // Automatic back arrow from being pushed.
      expect(find.byType(BackButton), findsOneWidget);

      // No drawer (ADR-0005): the Scaffold carries no drawer, so no hamburger.
      final scaffold = tester.widget<Scaffold>(
        find.descendant(
          of: find.byType(WorkoutsScreen),
          matching: find.byType(Scaffold),
        ),
      );
      expect(scaffold.drawer, isNull);
      expect(find.byType(DrawerButton), findsNothing);
    });
  });
}

/// True if [s] contains a pictographic emoji (rough surrogate-pair / symbol
/// range check — enough to guard product copy against accidental emoji).
bool _hasEmoji(String s) {
  for (final rune in s.runes) {
    if (rune >= 0x1F000 || (rune >= 0x2600 && rune <= 0x27BF)) return true;
  }
  return false;
}
