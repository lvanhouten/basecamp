import 'dart:async';

import 'package:basecamp/core/db/app_db.dart';
import 'package:basecamp/core/providers.dart';
import 'package:basecamp/features/clock/alarm_format.dart' as fmt;
import 'package:basecamp/features/clock/alarms_pane.dart';
import 'package:basecamp/features/clock/data/alarm_recurrence.dart';
import 'package:basecamp/features/clock/data/clock_repository.dart';
import 'package:basecamp/features/clock/data/notification_scheduler.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A test double for [ClockRepository] for the AlarmsPane. Satisfies the
/// concrete super-type with throwaway in-memory infra (mirroring
/// `timer_pane_test`), drives [watchAlarms] from a controller so the test pushes
/// any alarm list it wants, records each mutation the pane fires, and exposes a
/// settable [notificationsAllowed] so the silent-alarms warning is exercised.
class _FakeClockRepository extends ClockRepository {
  _FakeClockRepository(super.dao, super.scheduler);

  final _controller = StreamController<List<AlarmRow>>.broadcast();

  final List<({int timeOfDayMinutes, int repeatDays, String? label})>
      createCalls = [];
  final List<({int id, int timeOfDayMinutes, int repeatDays, String? label})>
      updateCalls = [];
  final List<({int id, bool enabled})> setEnabledCalls = [];
  final List<int> deleteCalls = [];

  bool _allowed = true;
  set notificationsAllowedTest(bool v) => _allowed = v;

  @override
  bool get notificationsAllowed => _allowed;

  void emit(List<AlarmRow> alarms) => _controller.add(alarms);

  @override
  Stream<List<AlarmRow>> watchAlarms() => _controller.stream;

  @override
  Future<int> createAlarm({
    required int timeOfDayMinutes,
    int repeatDays = 0,
    String? label,
    bool enabled = true,
    DateTime? now,
  }) async {
    createCalls
        .add((timeOfDayMinutes: timeOfDayMinutes, repeatDays: repeatDays, label: label));
    return createCalls.length;
  }

  @override
  Future<void> updateAlarm(
    int id, {
    required int timeOfDayMinutes,
    int repeatDays = 0,
    String? label,
    DateTime? now,
  }) async {
    updateCalls.add((
      id: id,
      timeOfDayMinutes: timeOfDayMinutes,
      repeatDays: repeatDays,
      label: label,
    ));
  }

  @override
  Future<void> setAlarmEnabled(int id, bool enabled, {DateTime? now}) async {
    setEnabledCalls.add((id: id, enabled: enabled));
  }

  @override
  Future<void> deleteAlarm(int id) async => deleteCalls.add(id);

  Future<void> closeStream() => _controller.close();
}

AlarmRow _alarm({
  required int id,
  required int timeOfDayMinutes,
  bool enabled = true,
  int repeatDays = 0,
  String? label,
  DateTime? createdAt,
}) =>
    AlarmRow(
      id: id,
      timeOfDayMinutes: timeOfDayMinutes,
      enabled: enabled,
      repeatDays: repeatDays,
      label: label,
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
          alarmsProvider.overrideWith((ref) => repo.watchAlarms()),
        ],
        child: const MaterialApp(home: AlarmsPane()),
      ),
    );
    await tester.pump(); // loading frame before the stream emits
  }

  group('repeatSummary (pure)', () {
    test('Once / Daily / Weekdays / Weekends presets and specific days', () {
      expect(fmt.repeatSummary(0), 'Once');
      expect(fmt.repeatSummary(everyDayMask), 'Daily');
      expect(fmt.repeatSummary(fmt.weekdaysMask), 'Weekdays');
      expect(fmt.repeatSummary(fmt.weekendsMask), 'Weekends');
      // A specific subset lists the day abbreviations in Mon→Sun order.
      final monWedFri = weekdayBit(DateTime.monday) |
          weekdayBit(DateTime.wednesday) |
          weekdayBit(DateTime.friday);
      expect(fmt.repeatSummary(monWedFri), 'Mon, Wed, Fri');
    });

    test('preset masks set the correct weekday bits', () {
      // Weekdays = Mon..Fri, Weekends = Sat+Sun, Daily = all seven.
      for (final wd in [
        DateTime.monday,
        DateTime.tuesday,
        DateTime.wednesday,
        DateTime.thursday,
        DateTime.friday,
      ]) {
        expect(maskHasWeekday(fmt.weekdaysMask, wd), isTrue);
        expect(maskHasWeekday(fmt.weekendsMask, wd), isFalse);
      }
      for (final wd in [DateTime.saturday, DateTime.sunday]) {
        expect(maskHasWeekday(fmt.weekendsMask, wd), isTrue);
        expect(maskHasWeekday(fmt.weekdaysMask, wd), isFalse);
      }
      for (var wd = 1; wd <= 7; wd++) {
        expect(maskHasWeekday(everyDayMask, wd), isTrue);
      }
    });
  });

  testWidgets('empty: shows the empty state and the add affordance',
      (tester) async {
    await pumpPane(tester);
    repo.emit(const []);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('alarms-empty')), findsOneWidget);
    expect(find.byKey(const ValueKey('add-alarm')), findsOneWidget);
  });

  testWidgets('lists alarms with time, label, repeat summary, and a toggle',
      (tester) async {
    await pumpPane(tester);
    repo.emit([
      _alarm(
        id: 1,
        timeOfDayMinutes: 7 * 60, // 07:00
        label: 'Wake up',
        repeatDays: fmt.weekdaysMask,
      ),
    ]);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('alarm-1')), findsOneWidget);
    expect(find.textContaining('Wake up'), findsOneWidget);
    // Repeat summary surfaces in the subtitle.
    expect(find.textContaining('Weekdays'), findsOneWidget);
    // The enable toggle reflects the row state.
    final sw = tester.widget<Switch>(
      find.byKey(const ValueKey('toggle-alarm-1')),
    );
    expect(sw.value, isTrue);
  });

  testWidgets('toggling an alarm calls setAlarmEnabled with the new value',
      (tester) async {
    await pumpPane(tester);
    repo.emit([_alarm(id: 5, timeOfDayMinutes: 6 * 60, enabled: true)]);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('toggle-alarm-5')));
    await tester.pump();

    expect(repo.setEnabledCalls, [(id: 5, enabled: false)]);
  });

  testWidgets('deleting an alarm calls deleteAlarm', (tester) async {
    await pumpPane(tester);
    repo.emit([_alarm(id: 9, timeOfDayMinutes: 8 * 60)]);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('delete-alarm-9')));
    await tester.pump();

    expect(repo.deleteCalls, [9]);
  });

  testWidgets('adding via the editor with a Weekdays preset + label persists it',
      (tester) async {
    await pumpPane(tester);
    repo.emit(const []);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('add-alarm')));
    await tester.pumpAndSettle();

    // Pick the Weekdays preset and type a label, then save (default time 07:00).
    await tester.tap(find.byKey(const ValueKey('preset-weekdays')));
    await tester.pump();
    await tester.enterText(
        find.byKey(const ValueKey('alarm-label-field')), 'Standup');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('save-alarm')));
    await tester.pumpAndSettle();

    expect(repo.createCalls, hasLength(1));
    final c = repo.createCalls.single;
    expect(c.timeOfDayMinutes, 7 * 60); // default 07:00
    expect(c.repeatDays, fmt.weekdaysMask);
    expect(c.label, 'Standup');
  });

  testWidgets('toggling individual days writes the matching weekday bits',
      (tester) async {
    await pumpPane(tester);
    repo.emit(const []);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('add-alarm')));
    await tester.pumpAndSettle();

    // Select Monday (day-1) and Friday (day-5).
    await tester.tap(find.byKey(const ValueKey('day-1')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('day-5')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('save-alarm')));
    await tester.pumpAndSettle();

    final expected =
        weekdayBit(DateTime.monday) | weekdayBit(DateTime.friday);
    expect(repo.createCalls.single.repeatDays, expected);
  });

  testWidgets('no days selected yields a one-off ("Once") on save',
      (tester) async {
    await pumpPane(tester);
    repo.emit(const []);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('add-alarm')));
    await tester.pumpAndSettle();
    // Save immediately — no preset, no day toggled.
    await tester.tap(find.byKey(const ValueKey('save-alarm')));
    await tester.pumpAndSettle();

    expect(repo.createCalls.single.repeatDays, 0);
  });

  testWidgets('editing an existing alarm calls updateAlarm for that id',
      (tester) async {
    await pumpPane(tester);
    repo.emit([
      _alarm(id: 3, timeOfDayMinutes: 9 * 60, label: 'Old', repeatDays: 0),
    ]);
    await tester.pumpAndSettle();

    // Tap the row body to open the editor seeded from the existing alarm.
    await tester.tap(find.byKey(const ValueKey('alarm-3')));
    await tester.pumpAndSettle();

    // The editor seeds the existing label.
    expect(find.text('Old'), findsOneWidget);

    // Switch it to Daily and save.
    await tester.tap(find.byKey(const ValueKey('preset-daily')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('save-alarm')));
    await tester.pumpAndSettle();

    expect(repo.updateCalls, hasLength(1));
    final u = repo.updateCalls.single;
    expect(u.id, 3);
    expect(u.repeatDays, everyDayMask);
    expect(u.timeOfDayMinutes, 9 * 60); // unchanged time seeded from the row
    expect(repo.createCalls, isEmpty);
  });

  testWidgets('surfaces the silent-alarms warning when notifications are denied',
      (tester) async {
    repo.notificationsAllowedTest = false;
    await pumpPane(tester);
    repo.emit(const []);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('alarms-silent-warning')), findsOneWidget);
  });

  testWidgets('no warning while notifications are allowed', (tester) async {
    await pumpPane(tester);
    repo.emit(const []);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('alarms-silent-warning')), findsNothing);
  });
}
