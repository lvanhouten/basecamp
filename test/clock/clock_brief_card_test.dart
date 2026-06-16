import 'package:basecamp/core/app_module.dart';
import 'package:basecamp/core/providers.dart';
import 'package:basecamp/features/clock/clock_tab.dart';
import 'package:basecamp/features/home/home_screen.dart';
import 'package:basecamp/features/lists/data/lists_dao.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Boots the Brief with the Lists read models stubbed (no real DB) and the
/// Clock counts overridden per-test to drive the phrase + precedence. The
/// override list is built inline so its element type is inferred — Riverpod's
/// override type isn't exported under a stable public name to annotate with.
Future<ProviderContainer> _pumpBrief(
  WidgetTester tester, {
  required int alarms,
  required int timers,
  required bool stopwatch,
}) async {
  final container = ProviderContainer(
    overrides: [
      listCountProvider.overrideWith((ref) => Stream.value(0)),
      openItemCountProvider.overrideWith((ref) => Stream.value(0)),
      listsProvider.overrideWith((ref) => Stream.value(<TrackedListWithCount>[])),
      todaysAlarmCountProvider.overrideWith((ref) => Stream.value(alarms)),
      runningTimerCountProvider.overrideWith((ref) => Stream.value(timers)),
      stopwatchRunningProvider.overrideWith((ref) => Stream.value(stopwatch)),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: HomeScreen()),
    ),
  );
  await tester.pump(); // let the stubbed streams emit
  return container;
}

Finder _clockCardSubtitle() => find.descendant(
      of: find.widgetWithText(Card, 'Clock'),
      matching: find.byType(Text),
    );

/// Reads the subtitle line of the Clock card (the second Text in the ListTile;
/// the first is the 'Clock' title).
String _clockLineText(WidgetTester tester) {
  final texts = tester
      .widgetList<Text>(_clockCardSubtitle())
      .map((t) => t.data)
      .whereType<String>()
      .toList();
  return texts.firstWhere((t) => t != 'Clock');
}

void main() {
  group('Brief Clock card phrase', () {
    testWidgets('all-placeholder state reads naturally (no "Active 0")',
        (tester) async {
      await _pumpBrief(tester, alarms: 0, timers: 0, stopwatch: false);
      final line = _clockLineText(tester);
      expect(line, 'No alarms today');
      expect(line, isNot(contains('Active')));
      expect(line, isNot(contains('0 timer')));
    });

    testWidgets('renders all three counts as a precise phrase', (tester) async {
      await _pumpBrief(tester, alarms: 2, timers: 1, stopwatch: true);
      expect(
        _clockLineText(tester),
        '2 alarms today · 1 timer running · stopwatch running',
      );
    });

    testWidgets('singular alarm and plural timers', (tester) async {
      await _pumpBrief(tester, alarms: 1, timers: 3, stopwatch: false);
      expect(_clockLineText(tester), '1 alarm today · 3 timers running');
    });

    testWidgets('stopwatch-only omits the timer segment', (tester) async {
      await _pumpBrief(tester, alarms: 0, timers: 0, stopwatch: true);
      expect(_clockLineText(tester), 'No alarms today · stopwatch running');
    });
  });

  group('Brief Clock card tap (module + precedence entry tab)', () {
    testWidgets('all placeholders → selects Clock, lands on Alarms',
        (tester) async {
      final container =
          await _pumpBrief(tester, alarms: 0, timers: 0, stopwatch: false);

      expect(container.read(selectedModuleProvider), AppModule.brief);
      await tester.tap(find.widgetWithText(Card, 'Clock'));
      await tester.pump();

      expect(container.read(selectedModuleProvider), AppModule.clock);
      expect(container.read(selectedClockTabProvider), ClockTab.alarms);
    });

    testWidgets('running stopwatch → entry tab is Stopwatch', (tester) async {
      final container =
          await _pumpBrief(tester, alarms: 5, timers: 2, stopwatch: true);

      await tester.tap(find.widgetWithText(Card, 'Clock'));
      await tester.pump();

      expect(container.read(selectedModuleProvider), AppModule.clock);
      expect(container.read(selectedClockTabProvider), ClockTab.stopwatch);
    });

    testWidgets('running timer (no stopwatch) → entry tab is Timer',
        (tester) async {
      final container =
          await _pumpBrief(tester, alarms: 5, timers: 1, stopwatch: false);

      await tester.tap(find.widgetWithText(Card, 'Clock'));
      await tester.pump();

      expect(container.read(selectedClockTabProvider), ClockTab.timer);
    });
  });
}
