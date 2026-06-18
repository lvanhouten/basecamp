import 'package:basecamp/core/theme.dart';
import 'package:basecamp/core/tokens.dart';
import 'package:basecamp/core/widgets/launcher_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Hosts [child] in a themed [MaterialApp] so it can read the [ColorScheme] and
/// [BasecampTokens]. The bar lives at the bottom of a Scaffold, matching its
/// intended use.
Widget _host(Widget child) {
  return MaterialApp(
    theme: basecampTheme(Brightness.light),
    home: Scaffold(bottomNavigationBar: child),
  );
}

ThemeData get _theme => basecampTheme(Brightness.light);
ColorScheme get _scheme => _theme.colorScheme;

/// The resolved colour a destination label actually paints with. The bar
/// applies the colour through [AnimatedDefaultTextStyle], so the [Text]'s own
/// `style` is null — read the effective style off the rendered [RichText].
Color? _labelColor(WidgetTester tester, String label) {
  final richText = tester.widget<RichText>(
    find.descendant(of: find.text(label), matching: find.byType(RichText)),
  );
  return richText.text.style?.color;
}

const _items = <LauncherTabItem<String>>[
  LauncherTabItem(value: 'brief', label: 'Brief', icon: Icons.home),
  LauncherTabItem(value: 'calendar', label: 'Calendar', icon: Icons.event),
  LauncherTabItem(value: 'activity', label: 'Activity', icon: Icons.show_chart),
  LauncherTabItem(value: 'modules', label: 'Modules', icon: Icons.grid_view),
];

void main() {
  group('LauncherTabBar — midpoint split', () {
    testWidgets('4 items + centerAction renders 2, then FAB, then 2',
        (tester) async {
      await tester.pumpWidget(_host(LauncherTabBar<String>(
        items: _items,
        value: 'brief',
        onChange: (_) {},
        centerAction: LauncherCenterAction(
          icon: Icons.add,
          label: 'Quick add',
          onClick: () {},
        ),
      )));

      // All four destinations render.
      for (final it in _items) {
        expect(find.text(it.label), findsOneWidget);
      }
      // The FAB (plus glyph) renders.
      expect(find.byIcon(Icons.add), findsOneWidget);

      // Ordering: Brief, Calendar (left), FAB, Activity, Modules (right).
      final briefX = tester.getCenter(find.text('Brief')).dx;
      final calendarX = tester.getCenter(find.text('Calendar')).dx;
      final fabX = tester.getCenter(find.byIcon(Icons.add)).dx;
      final activityX = tester.getCenter(find.text('Activity')).dx;
      final modulesX = tester.getCenter(find.text('Modules')).dx;

      expect(briefX, lessThan(calendarX));
      expect(calendarX, lessThan(fabX));
      expect(fabX, lessThan(activityX));
      expect(activityX, lessThan(modulesX));
    });

    testWidgets('without centerAction renders a plain N-tab bar (no FAB)',
        (tester) async {
      await tester.pumpWidget(_host(LauncherTabBar<String>(
        items: _items,
        value: 'brief',
        onChange: (_) {},
      )));

      for (final it in _items) {
        expect(find.text(it.label), findsOneWidget);
      }
      // No FAB: no plus glyph, no 58x58 circular action.
      expect(find.byIcon(Icons.add), findsNothing);
      expect(find.byType(LauncherTabBar<String>), findsOneWidget);
    });
  });

  group('LauncherTabBar — selection + onChange', () {
    testWidgets('the destination matching value is selected (brand accent)',
        (tester) async {
      await tester.pumpWidget(_host(LauncherTabBar<String>(
        items: _items,
        value: 'activity',
        onChange: (_) {},
        centerAction: LauncherCenterAction(
          icon: Icons.add,
          label: 'Quick add',
          onClick: () {},
        ),
      )));

      // Selected destination's label adopts the brand accent (primary). The
      // colour is applied via AnimatedDefaultTextStyle, so read the resolved
      // RichText, not the Text widget's own (null) style.
      expect(_labelColor(tester, 'Activity'), _scheme.primary);

      // Others use the tertiary/secondary text colour.
      expect(_labelColor(tester, 'Brief'), _scheme.onSurfaceVariant);

      // The selected icon is brand-coloured too (icon takes the colour directly).
      final selectedIcon = tester.widget<Icon>(
        find.descendant(
          of: find.ancestor(
            of: find.text('Activity'),
            matching: find.byType(Column),
          ),
          matching: find.byIcon(Icons.show_chart),
        ),
      );
      expect(selectedIcon.color, _scheme.primary);
    });

    testWidgets('tapping a destination fires onChange with its value',
        (tester) async {
      String? picked;
      await tester.pumpWidget(_host(LauncherTabBar<String>(
        items: _items,
        value: 'brief',
        onChange: (v) => picked = v,
        centerAction: LauncherCenterAction(
          icon: Icons.add,
          label: 'Quick add',
          onClick: () {},
        ),
      )));

      await tester.tap(find.text('Modules'));
      expect(picked, 'modules');

      await tester.tap(find.text('Calendar'));
      expect(picked, 'calendar');
    });
  });

  group('LauncherTabBar — center FAB is an action, never a destination', () {
    testWidgets('tapping the FAB fires its callback and never changes selection',
        (tester) async {
      var added = 0;
      var changed = 0;
      await tester.pumpWidget(_host(LauncherTabBar<String>(
        items: _items,
        value: 'brief',
        onChange: (_) => changed++,
        centerAction: LauncherCenterAction(
          icon: Icons.add,
          label: 'Quick add',
          onClick: () => added++,
        ),
      )));

      await tester.tap(find.byIcon(Icons.add));
      expect(added, 1);
      // onChange is never invoked by the FAB.
      expect(changed, 0);
    });

    testWidgets(
        'FAB is never rendered selected even if its value collides with value',
        (tester) async {
      // The bar's value is set to the FAB's conceptual value ('add'). No
      // destination carries that value, so nothing should render selected —
      // and the FAB must not adopt the selected state.
      await tester.pumpWidget(_host(LauncherTabBar<String>(
        items: _items,
        value: 'add',
        onChange: (_) {},
        centerAction: LauncherCenterAction(
          icon: Icons.add,
          label: 'Quick add',
          onClick: () {},
        ),
      )));

      // No destination label is brand-accented (none matches 'add').
      for (final it in _items) {
        expect(_labelColor(tester, it.label), _scheme.onSurfaceVariant,
            reason: '${it.label} should be unselected');
      }

      // The FAB's Semantics explicitly declares it is not selected — it carries
      // a button role but never the selected state. Find it by its action label.
      final fabSemantics = tester
          .widgetList<Semantics>(find.byType(Semantics))
          .firstWhere((s) => s.properties.label == 'Quick add');
      expect(fabSemantics.properties.selected, isFalse);
      expect(fabSemantics.properties.button, isTrue);
    });
  });

  group('LauncherTabBar — touch targets', () {
    testWidgets('destinations meet the minimum tap size', (tester) async {
      await tester.pumpWidget(_host(LauncherTabBar<String>(
        items: _items,
        value: 'brief',
        onChange: (_) {},
        centerAction: LauncherCenterAction(
          icon: Icons.add,
          label: 'Quick add',
          onClick: () {},
        ),
      )));

      // Each destination's ConstrainedBox enforces the minimum tap target
      // (spacing.tapMin = 44).
      final tapMin = _theme.extension<BasecampTokens>()!.spacing.tapMin;
      final boxes = find.descendant(
        of: find.byType(LauncherTabBar<String>),
        matching: find.byType(ConstrainedBox),
      );
      final minHeights = boxes
          .evaluate()
          .map((e) => (e.widget as ConstrainedBox).constraints.minHeight)
          .where((h) => h == tapMin);
      expect(minHeights.length, _items.length,
          reason: 'every destination enforces the minimum tap height');

      // The FAB is a generous 58x58 target.
      final fabSize = tester.getSize(find.byIcon(Icons.add).first);
      expect(fabSize.width, greaterThanOrEqualTo(44.0));
      expect(fabSize.height, greaterThanOrEqualTo(44.0));
    });
  });
}
