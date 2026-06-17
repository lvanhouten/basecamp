import 'package:basecamp/core/db/app_db.dart';
import 'package:basecamp/features/clock/data/alarm_recurrence.dart';
import 'package:basecamp/features/clock/data/clock_dao.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDb db;
  late ClockDao dao;

  setUp(() {
    db = AppDb.forTesting(NativeDatabase.memory());
    dao = db.clockDao;
  });

  tearDown(() async {
    await db.close();
  });

  group('insertAlarm', () {
    test('persists time, mask, label; enabled defaults true', () async {
      final id = await dao.insertAlarm(
        timeOfDayMinutes: 7 * 60 + 30, // 07:30
        repeatDays: weekdayBit(DateTime.monday) | weekdayBit(DateTime.friday),
        label: 'Wake up',
      );

      final row = await dao.findAlarm(id);
      expect(row, isNotNull);
      expect(row!.timeOfDayMinutes, 450);
      expect(row.repeatDays,
          weekdayBit(DateTime.monday) | weekdayBit(DateTime.friday));
      expect(row.label, 'Wake up');
      expect(row.enabled, isTrue);
    });

    test('one-off (mask 0), optional label, can start disabled', () async {
      final id = await dao.insertAlarm(
        timeOfDayMinutes: 360,
        repeatDays: 0,
        enabled: false,
      );
      final row = await dao.findAlarm(id);
      expect(row!.repeatDays, 0);
      expect(row.label, isNull);
      expect(row.enabled, isFalse);
    });
  });

  group('updateAlarm / setAlarmEnabled', () {
    test('updateAlarm changes schedule + label, leaves enabled untouched',
        () async {
      final id = await dao.insertAlarm(timeOfDayMinutes: 100, repeatDays: 0);
      await dao.updateAlarm(id,
          timeOfDayMinutes: 200, repeatDays: everyDayMask, label: 'Meds');

      final row = await dao.findAlarm(id);
      expect(row!.timeOfDayMinutes, 200);
      expect(row.repeatDays, everyDayMask);
      expect(row.label, 'Meds');
      expect(row.enabled, isTrue, reason: 'updateAlarm is not the on/off');
    });

    test('setAlarmEnabled flips only the enabled flag', () async {
      final id = await dao.insertAlarm(timeOfDayMinutes: 100, repeatDays: 0);
      await dao.setAlarmEnabled(id, false);
      expect((await dao.findAlarm(id))!.enabled, isFalse);
      await dao.setAlarmEnabled(id, true);
      expect((await dao.findAlarm(id))!.enabled, isTrue);
    });
  });

  group('deleteAlarm', () {
    test('removes the row', () async {
      final id = await dao.insertAlarm(timeOfDayMinutes: 100, repeatDays: 0);
      await dao.deleteAlarm(id);
      expect(await dao.findAlarm(id), isNull);
    });
  });

  group('watchAlarms ordering', () {
    test('soonest time-of-day first, then creation order', () async {
      final later = await dao.insertAlarm(timeOfDayMinutes: 600, repeatDays: 0);
      final early = await dao.insertAlarm(timeOfDayMinutes: 300, repeatDays: 0);
      final mid = await dao.insertAlarm(timeOfDayMinutes: 450, repeatDays: 0);

      final all = await dao.watchAlarms().first;
      expect(all.map((a) => a.id).toList(), [early, mid, later]);
    });

    test('equal time-of-day falls back to creation order (id tiebreak)',
        () async {
      final a = await dao.insertAlarm(timeOfDayMinutes: 480, repeatDays: 0);
      final b = await dao.insertAlarm(timeOfDayMinutes: 480, repeatDays: 0);
      final all = await dao.watchAlarms().first;
      expect(all.map((x) => x.id).toList(), [a, b]);
    });

    test('includes disabled alarms (the list shows on/off state)', () async {
      final id =
          await dao.insertAlarm(timeOfDayMinutes: 480, repeatDays: 0, enabled: false);
      final all = await dao.watchAlarms().first;
      expect(all.map((a) => a.id), contains(id));
    });
  });
}
