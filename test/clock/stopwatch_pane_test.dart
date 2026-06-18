import 'dart:async';

import 'package:basecamp/core/db/app_db.dart';
import 'package:basecamp/core/providers.dart';
import 'package:basecamp/core/theme.dart';
import 'package:basecamp/features/clock/data/clock_repository.dart';
import 'package:basecamp/features/clock/data/notification_scheduler.dart';
import 'package:basecamp/features/clock/data/stopwatch_state.dart';
import 'package:basecamp/features/clock/stopwatch_pane.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A test double for [ClockRepository]. Satisfies the concrete super-type with
/// throwaway in-memory infra, then overrides the stopwatch surface the pane
/// uses: [watchStopwatch] is driven by a controller, and the four transitions
/// record their calls so the test asserts the pane fires them.
class _FakeClockRepository extends ClockRepository {
  _FakeClockRepository(super.dao, super.scheduler);

  final _controller = StreamController<StopwatchState>.broadcast();

  int startCalls = 0;
  int pauseCalls = 0;
  int lapCalls = 0;
  int resetCalls = 0;

  void emit(StopwatchState s) => _controller.add(s);

  @override
  Stream<StopwatchState> watchStopwatch() => _controller.stream;

  @override
  Future<void> startStopwatch({DateTime? now}) async => startCalls++;

  @override
  Future<void> pauseStopwatch({DateTime? now}) async => pauseCalls++;

  @override
  Future<void> lapStopwatch({DateTime? now}) async => lapCalls++;

  @override
  Future<void> resetStopwatch() async => resetCalls++;

  Future<void> closeStream() => _controller.close();
}

StopwatchState _running({DateTime? startedAt, List<Duration> laps = const []}) =>
    StopwatchState(
      startedAt: startedAt ?? DateTime(2026, 6, 16, 12),
      accumulatedMs: 0,
      isRunning: true,
      laps: laps,
    );

StopwatchState _paused({int accumulatedMs = 0, List<Duration> laps = const []}) =>
    StopwatchState(
      startedAt: null,
      accumulatedMs: accumulatedMs,
      isRunning: false,
      laps: laps,
    );

void main() {
  late AppDb db;
  late _FakeClockRepository repo;

  setUp(() {
    db = AppDb.forTesting(NativeDatabase.memory());
    repo = _FakeClockRepository(db.clockDao, const NoopNotificationScheduler());
  });

  tearDown(() async {
    await repo.closeStream();
    await db.close();
  });

  Future<void> pumpPane(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [clockRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          theme: basecampTheme(Brightness.light),
          home: const Scaffold(body: StopwatchPane()),
        ),
      ),
    );
    await tester.pump(); // loading frame before the stream emits
  }

  testWidgets('idle: shows Start + Reset, zero readout, no laps', (tester) async {
    await pumpPane(tester);
    repo.emit(StopwatchState.idle);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('start')), findsOneWidget);
    expect(find.byKey(const ValueKey('reset')), findsOneWidget);
    expect(find.byKey(const ValueKey('pause')), findsNothing);
    expect(find.byKey(const ValueKey('lap')), findsNothing);
    expect(find.text('00:00.00'), findsOneWidget);
    expect(find.byType(ListTile), findsNothing);
  });

  testWidgets('tapping Start fires startStopwatch', (tester) async {
    await pumpPane(tester);
    repo.emit(StopwatchState.idle);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('start')));
    await tester.pump();
    expect(repo.startCalls, 1);
  });

  testWidgets('running: shows Lap + Pause; Lap fires, Pause fires',
      (tester) async {
    await pumpPane(tester);
    repo.emit(_running());
    // A running pane starts a display Ticker, so never pumpAndSettle here —
    // a couple of explicit frames deliver the stream event and start the ticker.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));

    expect(find.byKey(const ValueKey('lap')), findsOneWidget);
    expect(find.byKey(const ValueKey('pause')), findsOneWidget);
    expect(find.byKey(const ValueKey('start')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('lap')));
    await tester.pump();
    expect(repo.lapCalls, 1);

    await tester.tap(find.byKey(const ValueKey('pause')));
    await tester.pump();
    expect(repo.pauseCalls, 1);
  });

  testWidgets('reset is disabled when idle-empty, enabled once there is data',
      (tester) async {
    await pumpPane(tester);

    // Truly empty: nothing to reset.
    repo.emit(StopwatchState.idle);
    await tester.pumpAndSettle();
    final disabled = tester.widget<OutlinedButton>(
      find.descendant(
        of: find.byKey(const ValueKey('reset')),
        matching: find.byType(OutlinedButton),
      ),
    );
    expect(disabled.onPressed, isNull);

    // Paused with banked elapsed: reset is now actionable.
    repo.emit(_paused(accumulatedMs: 5000));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('reset')));
    await tester.pump();
    expect(repo.resetCalls, 1);
  });

  testWidgets('laps render in tap order', (tester) async {
    await pumpPane(tester);
    // accumulatedMs distinct from both lap values so the main readout text
    // doesn't collide with a lap's trailing text.
    repo.emit(_paused(
      accumulatedMs: 40000,
      laps: const [Duration(seconds: 10), Duration(seconds: 25)],
    ));
    await tester.pumpAndSettle();

    expect(find.text('Lap 1'), findsOneWidget);
    expect(find.text('Lap 2'), findsOneWidget);

    // Each lap value renders inside its own ListTile (trailing text).
    String? lapValue(String label) {
      final tile = find.ancestor(
        of: find.text(label),
        matching: find.byType(ListTile),
      );
      final trailing = find.descendant(of: tile, matching: find.byType(Text));
      return tester
          .widgetList<Text>(trailing)
          .map((t) => t.data)
          .firstWhere((d) => d != label);
    }

    expect(lapValue('Lap 1'), '00:10.00');
    expect(lapValue('Lap 2'), '00:25.00');

    // Main readout shows the banked accumulated total (40s), not a lap.
    expect(find.text('00:40.00'), findsOneWidget);
  });

  testWidgets('paused readout reflects the persisted accumulated elapsed',
      (tester) async {
    await pumpPane(tester);
    // 1m05.00 banked while paused — derived purely from the record (now-free).
    repo.emit(_paused(accumulatedMs: 65000));
    await tester.pumpAndSettle();
    expect(find.text('01:05.00'), findsOneWidget);
  });
}
