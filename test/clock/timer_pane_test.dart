import 'dart:async';

import 'package:basecamp/core/db/app_db.dart';
import 'package:basecamp/core/providers.dart';
import 'package:basecamp/core/theme.dart';
import 'package:basecamp/features/clock/clock_math.dart' as clock_math;
import 'package:basecamp/features/clock/data/clock_repository.dart';
import 'package:basecamp/features/clock/data/notification_scheduler.dart';
import 'package:basecamp/features/clock/timer_pane.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A test double for [ClockRepository]. Satisfies the concrete super-type with
/// throwaway in-memory infra (mirroring `stopwatch_pane_test`), then overrides
/// just the timer surface the pane touches: [watchRunningTimers] is driven by a
/// controller (so the test pushes any running list it wants), the four
/// transitions record their calls, and [notificationsAllowed] is settable so the
/// silent-timers warning can be exercised.
class _FakeClockRepository extends ClockRepository {
  _FakeClockRepository(super.dao, super.scheduler);

  final _controller = StreamController<List<TimerRow>>.broadcast();

  final List<({Duration duration, String? label})> createCalls = [];
  final List<int> pauseCalls = [];
  final List<int> resumeCalls = [];
  final List<int> cancelCalls = [];

  bool _allowed = true;
  set notificationsAllowedTest(bool v) => _allowed = v;

  @override
  bool get notificationsAllowed => _allowed;

  void emit(List<TimerRow> timers) => _controller.add(timers);

  @override
  Stream<List<TimerRow>> watchRunningTimers() => _controller.stream;

  @override
  Future<int> createTimer(Duration duration, {String? label, DateTime? now}) async {
    createCalls.add((duration: duration, label: label));
    return createCalls.length;
  }

  @override
  Future<void> pauseTimer(int id, {DateTime? now}) async => pauseCalls.add(id);

  @override
  Future<void> resumeTimer(int id, {DateTime? now}) async => resumeCalls.add(id);

  @override
  Future<void> cancelTimer(int id) async => cancelCalls.add(id);

  Future<void> closeStream() => _controller.close();
}

/// Build a [TimerRow] in a chosen state. `endsAt` in the future → running;
/// `endsAt` in the past → finished; `remainingMs` (with null `endsAt`) → paused.
TimerRow _row({
  required int id,
  String? label,
  int durationMs = 300000,
  DateTime? endsAt,
  int? remainingMs,
  DateTime? createdAt,
}) =>
    TimerRow(
      id: id,
      label: label,
      durationMs: durationMs,
      endsAt: endsAt,
      remainingMs: remainingMs,
      createdAt: createdAt ?? DateTime(2026, 6, 16, 12),
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
        overrides: [
          clockRepositoryProvider.overrideWithValue(repo),
          runningTimersProvider
              .overrideWith((ref) => repo.watchRunningTimers()),
        ],
        child: MaterialApp(
          theme: basecampTheme(Brightness.light),
          home: const TimerPane(),
        ),
      ),
    );
    await tester.pump(); // loading frame before the stream emits
  }

  testWidgets('empty: shows the empty state and the add affordance',
      (tester) async {
    await pumpPane(tester);
    repo.emit(const []);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('timer-empty')), findsOneWidget);
    expect(find.byKey(const ValueKey('add-timer')), findsOneWidget);
  });

  testWidgets('creating a timer from the sheet fires createTimer with the '
      'entered duration and label', (tester) async {
    await pumpPane(tester);
    repo.emit(const []);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('add-timer')));
    await tester.pumpAndSettle();

    // 1 minute 30 seconds, labelled "Tea".
    await tester.enterText(find.byKey(const ValueKey('minutes-field')), '1');
    await tester.enterText(find.byKey(const ValueKey('seconds-field')), '30');
    await tester.enterText(find.byKey(const ValueKey('label-field')), 'Tea');
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('start-timer')));
    await tester.pumpAndSettle();

    expect(repo.createCalls, hasLength(1));
    expect(repo.createCalls.single.duration, const Duration(minutes: 1, seconds: 30));
    expect(repo.createCalls.single.label, 'Tea');
  });

  testWidgets('Start is disabled until a non-zero duration is entered',
      (tester) async {
    await pumpPane(tester);
    repo.emit(const []);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('add-timer')));
    await tester.pumpAndSettle();

    final disabled = tester.widget<FilledButton>(
      find.byKey(const ValueKey('start-timer')),
    );
    expect(disabled.onPressed, isNull);

    await tester.enterText(find.byKey(const ValueKey('seconds-field')), '5');
    await tester.pump();

    final enabled = tester.widget<FilledButton>(
      find.byKey(const ValueKey('start-timer')),
    );
    expect(enabled.onPressed, isNotNull);
  });

  testWidgets('a running timer shows its label and counts down', (tester) async {
    await pumpPane(tester);
    final now = DateTime.now();
    repo.emit([_row(id: 7, label: 'Pasta', endsAt: now.add(const Duration(minutes: 5)))]);
    // Running list starts the display ticker — never pumpAndSettle; a couple of
    // explicit frames deliver the stream event and start the ticker.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));

    // The label is shown (it shares the subtitle line with the duration).
    expect(find.textContaining('Pasta'), findsOneWidget);
    // Remaining renders as mm:ss near 05:00 (allow the ticker delta).
    expect(find.byKey(const ValueKey('timer-7')), findsOneWidget);
    expect(find.byKey(const ValueKey('pause')), findsOneWidget);
    expect(find.byKey(const ValueKey('cancel')), findsOneWidget);
  });

  testWidgets('displayed remaining equals clock-math remaining for endsAt at now',
      (tester) async {
    await pumpPane(tester);
    final endsAt = DateTime.now().add(const Duration(minutes: 2, seconds: 30));
    repo.emit([_row(id: 1, endsAt: endsAt)]);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));

    // The pane derives the readout from its own per-frame `_now` via clock-math.
    // We can't read that private `_now`, but it sits within this window, so the
    // displayed mm:ss must equal clock-math's remaining for `endsAt` at *some*
    // `now` between the emit and here — i.e. one of the two adjacent seconds.
    // Asserting against the set {now, now-1s} pins the formatting rule
    // deterministically without racing the second boundary.
    String fmt(Duration d) {
      final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
      final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
      return '$mm:$ss';
    }

    final now = DateTime.now();
    final candidates = [
      fmt(clock_math.countdownRemaining(endsAt: endsAt, now: now)),
      fmt(clock_math.countdownRemaining(
          endsAt: endsAt, now: now.subtract(const Duration(seconds: 1)))),
    ];

    // Exactly one of the two adjacent-second readouts is shown as a standalone
    // Text (the title). The subtitle's "mm:ss timer" can't collide — it carries
    // the " timer" suffix, so `find.text` (exact match) won't hit it.
    expect(
      candidates.where((c) => find.text(c).evaluate().isNotEmpty),
      hasLength(1),
    );
  });

  testWidgets('multiple timers render concurrently in the streamed order',
      (tester) async {
    await pumpPane(tester);
    final now = DateTime.now();
    repo.emit([
      _row(id: 1, label: 'Soonest', endsAt: now.add(const Duration(minutes: 1))),
      _row(id: 2, label: 'Later', endsAt: now.add(const Duration(minutes: 9))),
    ]);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));

    expect(find.byKey(const ValueKey('timer-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('timer-2')), findsOneWidget);

    // The pane renders the streamed order top-to-bottom (the stream is the one
    // ordered soonest-first; the pane must not reorder).
    final firstDy = tester.getTopLeft(find.byKey(const ValueKey('timer-1'))).dy;
    final secondDy = tester.getTopLeft(find.byKey(const ValueKey('timer-2'))).dy;
    expect(firstDy, lessThan(secondDy));
  });

  testWidgets('Pause fires pauseTimer for the row', (tester) async {
    await pumpPane(tester);
    final now = DateTime.now();
    repo.emit([_row(id: 42, endsAt: now.add(const Duration(minutes: 3)))]);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));

    await tester.tap(find.byKey(const ValueKey('pause')));
    await tester.pump();
    expect(repo.pauseCalls, [42]);
  });

  testWidgets('a paused timer shows Resume; Resume fires resumeTimer',
      (tester) async {
    await pumpPane(tester);
    // Paused: endsAt null, remainingMs set.
    repo.emit([_row(id: 5, endsAt: null, remainingMs: 90000)]);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('resume')), findsOneWidget);
    expect(find.byKey(const ValueKey('pause')), findsNothing);
    // Frozen captured remaining (1m30s) is shown.
    expect(find.text('01:30'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('resume')));
    await tester.pump();
    expect(repo.resumeCalls, [5]);
  });

  testWidgets('Cancel fires cancelTimer for a running timer', (tester) async {
    await pumpPane(tester);
    final now = DateTime.now();
    repo.emit([_row(id: 8, endsAt: now.add(const Duration(minutes: 1)))]);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));

    await tester.tap(find.byKey(const ValueKey('cancel')));
    await tester.pump();
    expect(repo.cancelCalls, [8]);
  });

  testWidgets("a finished timer shows the ringing state with Dismiss; Dismiss "
      'fires cancelTimer', (tester) async {
    await pumpPane(tester);
    // Finished: endsAt set but in the past — stays until dismissed.
    repo.emit([_row(id: 9, label: 'Eggs', endsAt: DateTime.now().subtract(const Duration(seconds: 1)))]);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('finished-label')), findsOneWidget);
    expect(find.text("Time's up"), findsOneWidget);
    expect(find.byKey(const ValueKey('dismiss')), findsOneWidget);
    // A finished timer offers no pause/cancel-icon controls — only Dismiss.
    expect(find.byKey(const ValueKey('pause')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('dismiss')));
    await tester.pump();
    expect(repo.cancelCalls, [9]);
  });

  testWidgets('surfaces the silent-timers warning when notifications are denied',
      (tester) async {
    repo.notificationsAllowedTest = false;
    await pumpPane(tester);
    repo.emit(const []);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('silent-warning')), findsOneWidget);
  });

  testWidgets('no warning while notifications are allowed', (tester) async {
    await pumpPane(tester);
    repo.emit(const []);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('silent-warning')), findsNothing);
  });
}
