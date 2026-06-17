import 'dart:async';

import 'package:basecamp/core/db/app_db.dart';
import 'package:basecamp/core/providers.dart';
import 'package:basecamp/features/clock/alarm_ringing_screen.dart';
import 'package:basecamp/features/clock/data/chime_player.dart';
import 'package:basecamp/features/clock/data/clock_repository.dart';
import 'package:basecamp/features/clock/data/notification_scheduler.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records snooze/dismiss so the ring screen's actions are asserted without the
/// real scheduler. Drives [watchAlarms] from a controller for the display
/// lookup. Mirrors the AlarmsPane fake.
class _FakeClockRepository extends ClockRepository {
  _FakeClockRepository(super.dao, super.scheduler);

  final _controller = StreamController<List<AlarmRow>>.broadcast();
  final List<({int id, int minutes})> snoozeCalls = [];
  final List<int> dismissCalls = [];

  void emit(List<AlarmRow> alarms) => _controller.add(alarms);

  @override
  Stream<List<AlarmRow>> watchAlarms() => _controller.stream;

  @override
  Future<void> snooze(int id, int minutes, {DateTime? now}) async {
    snoozeCalls.add((id: id, minutes: minutes));
  }

  @override
  Future<void> dismiss(int id, {DateTime? now}) async => dismissCalls.add(id);

  Future<void> closeStream() => _controller.close();
}

/// Records start/stop so the looping-chime coordination is asserted without
/// playing audio (the [ChimePlayer] contract).
class _RecordingChimePlayer implements ChimePlayer {
  int starts = 0;
  int stops = 0;

  @override
  Future<void> start() async => starts++;

  @override
  Future<void> stop() async => stops++;
}

AlarmRow _alarm({
  required int id,
  required int timeOfDayMinutes,
  String? label,
  int repeatDays = 0,
}) =>
    AlarmRow(
      id: id,
      timeOfDayMinutes: timeOfDayMinutes,
      enabled: true,
      repeatDays: repeatDays,
      label: label,
      createdAt: DateTime(2026, 6, 16, 12),
    );

void main() {
  late AppDb db;
  late _FakeClockRepository repo;
  late _RecordingChimePlayer chime;

  setUp(() {
    db = AppDb.forTesting(NativeDatabase.memory());
    repo = _FakeClockRepository(db.clockDao, const NoopNotificationScheduler());
    chime = _RecordingChimePlayer();
  });

  tearDown(() async {
    await repo.closeStream();
    await db.close();
  });

  Future<void> pumpRing(WidgetTester tester, {required int alarmId}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clockRepositoryProvider.overrideWithValue(repo),
          chimePlayerProvider.overrideWithValue(chime),
          alarmsProvider.overrideWith((ref) => repo.watchAlarms()),
        ],
        child: MaterialApp(home: AlarmRingingScreen(alarmId: alarmId)),
      ),
    );
    await tester.pump(); // build + post-frame callback (chime start)
  }

  testWidgets('opening the ring screen starts the looping chime',
      (tester) async {
    await pumpRing(tester, alarmId: 1);
    repo.emit([_alarm(id: 1, timeOfDayMinutes: 7 * 60, label: 'Wake up')]);
    await tester.pump(); // deliver the stream event
    await tester.pump(); // post-frame chime start + rebuild with the alarm row

    expect(chime.starts, 1);
    expect(chime.stops, 0);
    // Shows the alarm's time + label.
    expect(find.byKey(const ValueKey('ringing-time')), findsOneWidget);
    expect(find.text('Wake up'), findsOneWidget);
    // Large Snooze + Dismiss are present.
    expect(find.byKey(const ValueKey('ringing-snooze')), findsOneWidget);
    expect(find.byKey(const ValueKey('ringing-dismiss')), findsOneWidget);
  });

  testWidgets('Snooze stops the chime and calls snooze(id, 9)', (tester) async {
    await pumpRing(tester, alarmId: 42);
    repo.emit([_alarm(id: 42, timeOfDayMinutes: 6 * 60)]);
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('ringing-snooze')));
    await tester.pumpAndSettle();

    expect(repo.snoozeCalls, [(id: 42, minutes: 9)]);
    expect(repo.dismissCalls, isEmpty);
    expect(chime.stops, 1);
  });

  testWidgets('Dismiss stops the chime and calls dismiss(id)', (tester) async {
    await pumpRing(tester, alarmId: 7);
    repo.emit([_alarm(id: 7, timeOfDayMinutes: 6 * 60)]);
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('ringing-dismiss')));
    await tester.pumpAndSettle();

    expect(repo.dismissCalls, [7]);
    expect(repo.snoozeCalls, isEmpty);
    expect(chime.stops, 1);
  });

  testWidgets('a deleted/unknown alarm still rings generically and can be acted on',
      (tester) async {
    await pumpRing(tester, alarmId: 99);
    repo.emit(const []); // no matching row
    await tester.pump();

    expect(chime.starts, 1);
    // Falls back to a generic "Alarm" label, no time row.
    expect(find.text('Alarm'), findsOneWidget);
    expect(find.byKey(const ValueKey('ringing-time')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('ringing-dismiss')));
    await tester.pumpAndSettle();
    expect(repo.dismissCalls, [99]);
  });
}
