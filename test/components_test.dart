import 'package:basecamp/core/theme.dart';
import 'package:basecamp/core/tokens.dart';
import 'package:basecamp/core/widgets/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wraps [child] in a themed [MaterialApp] so widgets can read the
/// [ColorScheme] and [BasecampTokens]. [disableAnimations] simulates the
/// reduced-motion accessibility setting via [MediaQuery].
Widget _host(Widget child, {bool disableAnimations = false}) {
  return MaterialApp(
    theme: basecampTheme(Brightness.light),
    home: Builder(
      builder: (context) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(disableAnimations: disableAnimations),
          child: Scaffold(body: Center(child: child)),
        );
      },
    ),
  );
}

ThemeData get _theme => basecampTheme(Brightness.light);
ColorScheme get _scheme => _theme.colorScheme;
BasecampTokens get _tokens => _theme.extension<BasecampTokens>()!;

void main() {
  group('ProgressRing', () {
    test('normalize: fraction passthrough, percentage scaling, clamping', () {
      // Fractions in [0,1] pass through.
      expect(ProgressRing.normalize(0), 0);
      expect(ProgressRing.normalize(0.5), 0.5);
      expect(ProgressRing.normalize(1), 1);
      // Values > 1 are treated as percentages.
      expect(ProgressRing.normalize(62), closeTo(0.62, 1e-9));
      expect(ProgressRing.normalize(40), closeTo(0.40, 1e-9));
      // Out of range clamps.
      expect(ProgressRing.normalize(-0.5), 0);
      expect(ProgressRing.normalize(150), 1);
    });

    testWidgets('renders an arc proportional to its value (semantic percent)',
        (tester) async {
      await tester.pumpWidget(_host(const ProgressRing(value: 0.62)));
      await tester.pumpAndSettle();
      // The semantic label reflects the proportion (62%).
      expect(find.bySemanticsLabel('62 percent'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('clamps out-of-range values', (tester) async {
      await tester.pumpWidget(_host(const ProgressRing(value: 150)));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('100 percent'), findsOneWidget);

      await tester.pumpWidget(_host(const ProgressRing(value: -20)));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('0 percent'), findsOneWidget);
    });

    testWidgets('renders a center label slot when provided', (tester) async {
      await tester.pumpWidget(
        _host(const ProgressRing(value: 0.4, label: Text('4/10'))),
      );
      await tester.pumpAndSettle();
      expect(find.text('4/10'), findsOneWidget);
    });

    testWidgets('reduced motion: paints final value immediately (no tween)',
        (tester) async {
      await tester.pumpWidget(
        _host(const ProgressRing(value: 0.8), disableAnimations: true),
      );
      // No pumpAndSettle — a single frame. Under reduced motion there is no
      // TweenAnimationBuilder, so the painter is at the final fraction at once.
      await tester.pump();
      expect(find.byType(TweenAnimationBuilder<double>), findsNothing);
      expect(find.bySemanticsLabel('80 percent'), findsOneWidget);
    });

    testWidgets('normal motion: animates via a tween', (tester) async {
      await tester.pumpWidget(_host(const ProgressRing(value: 0.8)));
      await tester.pump();
      expect(find.byType(TweenAnimationBuilder<double>), findsOneWidget);
      await tester.pumpAndSettle();
    });
  });

  group('Badge', () {
    testWidgets('renders its label', (tester) async {
      await tester.pumpWidget(
        _host(const BcBadge(label: 'On track', tone: BadgeTone.success)),
      );
      expect(find.text('On track'), findsOneWidget);
    });

    testWidgets('renders a leading dot only when requested', (tester) async {
      await tester.pumpWidget(
        _host(const BcBadge(label: 'Due', tone: BadgeTone.warning, dot: true)),
      );
      // The dot is a circular 6x6 container — present alongside the label.
      final dots = tester.widgetList<Container>(find.byType(Container)).where(
            (c) =>
                c.decoration is BoxDecoration &&
                (c.decoration as BoxDecoration).shape == BoxShape.circle,
          );
      expect(dots, isNotEmpty);

      await tester.pumpWidget(
        _host(const BcBadge(label: 'Due', tone: BadgeTone.warning)),
      );
      final noDots = tester.widgetList<Container>(find.byType(Container)).where(
            (c) =>
                c.decoration is BoxDecoration &&
                (c.decoration as BoxDecoration).shape == BoxShape.circle,
          );
      expect(noDots, isEmpty);
    });

    testWidgets('applies the correct semantic color per tone', (tester) async {
      // danger maps to the error role from the ColorScheme.
      await tester.pumpWidget(
        _host(const BcBadge(label: 'Failed', tone: BadgeTone.danger)),
      );
      final dangerText = tester.widget<Text>(find.text('Failed'));
      expect(dangerText.style!.color, _scheme.onErrorContainer);

      // brand maps to the brand-hover (secondary) foreground.
      await tester.pumpWidget(
        _host(const BcBadge(label: 'New', tone: BadgeTone.brand)),
      );
      final brandText = tester.widget<Text>(find.text('New'));
      expect(brandText.style!.color, _scheme.secondary);
    });
  });

  group('Stat', () {
    testWidgets('renders value, unit and label in tabular figures',
        (tester) async {
      await tester.pumpWidget(
        _host(const Stat(value: '32.5', unit: 'km', label: 'This week')),
      );
      // Label is uppercased.
      expect(find.text('THIS WEEK'), findsOneWidget);

      // Value + unit share a single rich-text tree; the value span uses
      // tabular figures and the unit is its trailing sibling span.
      final richText = tester.widget<RichText>(find.byType(RichText).first);
      TextSpan? valueSpan;
      TextSpan? unitSpan;
      void visit(InlineSpan span) {
        if (span is TextSpan) {
          if (span.text == '32.5') valueSpan = span;
          if (span.text == ' km') unitSpan = span;
          for (final c in span.children ?? const <InlineSpan>[]) {
            visit(c);
          }
        }
      }

      visit(richText.text);
      expect(valueSpan, isNotNull);
      expect(
        valueSpan!.style!.fontFeatures,
        contains(const FontFeature.tabularFigures()),
      );
      expect(unitSpan, isNotNull);
    });

    testWidgets('label is optional', (tester) async {
      await tester.pumpWidget(_host(const Stat(value: '7')));
      expect(find.text('7'), findsOneWidget);
    });
  });

  group('Tag', () {
    testWidgets('renders label and optional leading icon', (tester) async {
      await tester.pumpWidget(
        _host(const Tag(label: 'Groceries', icon: Icons.list)),
      );
      expect(find.text('Groceries'), findsOneWidget);
      expect(find.byIcon(Icons.list), findsOneWidget);
    });

    testWidgets('fires onRemove when the × is tapped', (tester) async {
      var removed = false;
      await tester.pumpWidget(
        _host(Tag(label: 'Upper body', onRemove: () => removed = true)),
      );
      expect(find.byIcon(Icons.close), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close));
      expect(removed, isTrue);
    });
  });

  group('BcListItem', () {
    testWidgets('renders leading, title, subtitle and trailing slots',
        (tester) async {
      await tester.pumpWidget(
        _host(const BcListItem(
          leading: BcListItemIcon(Icons.check_circle),
          title: 'Groceries',
          subtitle: '3 of 8 done',
          trailing: Icon(Icons.chevron_right),
        )),
      );
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('3 of 8 done'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('fires its tap callback when interactive', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _host(BcListItem(title: 'Open', onTap: () => tapped = true)),
      );
      await tester.tap(find.text('Open'));
      expect(tapped, isTrue);
    });

    testWidgets('static row (no onTap) has no InkWell', (tester) async {
      await tester.pumpWidget(_host(const BcListItem(title: 'Static')));
      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets('done strikes through the title', (tester) async {
      await tester.pumpWidget(
        _host(const BcListItem(title: 'Oat milk', done: true)),
      );
      final text = tester.widget<Text>(find.text('Oat milk'));
      expect(text.style!.decoration, TextDecoration.lineThrough);
    });

    testWidgets('grouped rows are separated by a single hairline',
        (tester) async {
      await tester.pumpWidget(
        _host(const BcListGroup(children: [
          BcListItem(title: 'One'),
          BcListItem(title: 'Two'),
          BcListItem(title: 'Three'),
        ])),
      );
      // 3 rows => exactly 2 dividers (none before first / after last).
      final dividers = tester.widgetList<Divider>(find.byType(Divider));
      expect(dividers.length, 2);
      for (final d in dividers) {
        expect(d.thickness, 1);
        expect(d.color, _scheme.outlineVariant);
      }
    });
  });

  group('SegmentedControl', () {
    final options = const [
      SegmentOption(value: 'timer', label: 'Timer'),
      SegmentOption(value: 'stopwatch', label: 'Stopwatch'),
      SegmentOption(value: 'alarm', label: 'Alarm'),
    ];

    testWidgets('renders all of its options', (tester) async {
      await tester.pumpWidget(
        _host(SegmentedControl<String>(
          options: options,
          value: 'timer',
          onChanged: (_) {},
        )),
      );
      expect(find.text('Timer'), findsOneWidget);
      expect(find.text('Stopwatch'), findsOneWidget);
      expect(find.text('Alarm'), findsOneWidget);
    });

    testWidgets('marks the selected option with the brand accent',
        (tester) async {
      await tester.pumpWidget(
        _host(SegmentedControl<String>(
          options: options,
          value: 'stopwatch',
          onChanged: (_) {},
        )),
      );
      // Selected text uses onPrimary (on the brand pill); unselected uses
      // the secondary text colour.
      final selected = tester.widget<Text>(find.text('Stopwatch'));
      expect(selected.style!.color, _scheme.onPrimary);
      final unselected = tester.widget<Text>(find.text('Timer'));
      expect(unselected.style!.color, _scheme.onSurfaceVariant);
    });

    testWidgets('fires onChanged with the tapped value', (tester) async {
      String? picked;
      await tester.pumpWidget(
        _host(SegmentedControl<String>(
          options: options,
          value: 'timer',
          onChanged: (v) => picked = v,
        )),
      );
      await tester.tap(find.text('Alarm'));
      expect(picked, 'alarm');
    });
  });

  group('token sourcing', () {
    testWidgets('themed primitives read radii from tokens (pill = full)',
        (tester) async {
      // The badge/tag/segmented pills must carry the tokens.radii.full pill
      // radius, not a hardcoded literal.
      await tester.pumpWidget(
        _host(const BcBadge(label: 'x', tone: BadgeTone.neutral)),
      );
      final box = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(BcBadge),
              matching: find.byType(Container),
            )
            .first,
      );
      final radius =
          (box.decoration as BoxDecoration).borderRadius as BorderRadius;
      expect(radius.topLeft.x, _tokens.radii.full);
    });

    testWidgets('danger badge sources its color from the ColorScheme error role',
        (tester) async {
      await tester.pumpWidget(
        _host(const BcBadge(label: 'err', tone: BadgeTone.danger)),
      );
      expect(
        tester.widget<Text>(find.text('err')).style!.color,
        _scheme.onErrorContainer,
      );
    });
  });
}
