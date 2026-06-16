import 'package:basecamp/core/db/app_db.dart';
import 'package:basecamp/features/clock/data/alarm_recurrence.dart';
import 'package:basecamp/features/clock/data/clock_dao.dart';
import 'package:basecamp/features/clock/data/clock_repository.dart';
import 'package:basecamp/features/clock/data/notification_scheduler.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records every scheduler call so the repository's alarm coordination is
/// asserted without the real plugin. Tracks the timer `schedule`/`cancel` AND
/// the alarm `scheduleAlarm`/`rescheduleAlarms` (07) so a single fake covers the
/// whole seam.
class _FakeScheduler implements NotificationScheduler {
  final scheduled = <({int id, DateTime at, String? payload})>[];
  final alarmsScheduled = <({int id, DateTime at, String? payload})>[];
  final cancelled = <int>[];
  int permissionRequests = 0;
  bool permission = true;

  @override
  Future<bool> ensurePermission() async {
    permissionRequests++;
    return permission;
  }

  @override
  Future<void> schedule({
    required int id,
    required DateTime at,
    String? payload,
  }) async =>
      scheduled.add((id: id, at: at, payload: payload));

  @override
  Future<void> cancel(int id) async => cancelled.add(id);

  @override
  Future<void> scheduleAlarm({
    required int id,
    required DateTime at,
    String? payload,
  }) async =>
      alarmsScheduled.add((id: id, at: at, payload: payload));

  @override
  Future<void> rescheduleAlarms(List<ScheduledAlarm> slots) async {
    for (final s in slots) {
      alarmsScheduled.add((id: s.id, at: s.at, payload: s.payload));
    }
  }
}

void main() {
  late AppDb db;
  late ClockDao dao;
  late _FakeScheduler scheduler;
  late ClockRepository repo;

  // A fixed local Monday at noon. LOCAL (not UTC) so Drift round-trips match.
  // 2026-06-15 is a Monday.
  final monNoon = DateTime(2026, 6, 15, 12, 0, 0);

  setUp(() {
    db = AppDb.forTesting(NativeDatabase.memory());
    dao = db.clockDao;
    scheduler = _FakeScheduler();
    repo = ClockRepository(dao, scheduler);
  });

  tearDown(() async {
    await db.close();
  });

  group('createAlarm scheduling', () {
    test('enabled recurring schedules one notification per selected weekday',
        () async {
      final mask = weekdayBit(DateTime.monday) |
          weekdayBit(DateTime.wednesday) |
          weekdayBit(DateTime.friday);
      final id = await repo.createAlarm(
        timeOfDayMinutes: 7 * 60, // 07:00
        repeatDays: mask,
        label: 'Wake up',
        now: monNoon,
      );

      // One full-screen alarm notification per selected weekday (3).
      expect(scheduler.alarmsScheduled, hasLength(3));
      // Each lands on its weekday at 07:00, matching 06's nextOccurrence.
      for (final slot in weekdaySchedule(7 * 60, mask)) {
        final singleDay = weekdayBit(slot.dartWeekday);
        final expectedAt = nextOccurrence(7 * 60, singleDay, monNoon);
        final notifId =
            ClockRepository.alarmNotificationId(id, slot.dartWeekday);
        final match =
            scheduler.alarmsScheduled.firstWhere((s) => s.id == notifId);
        expect(match.at, expectedAt);
        expect(match.payload, 'alarm:$id');
      }
    });

    test('enabled one-off schedules a single notification at next occurrence',
        () async {
      // 18:00 today (still ahead of noon) → fires today.
      final id = await repo.createAlarm(
        timeOfDayMinutes: 18 * 60,
        repeatDays: 0,
        now: monNoon,
      );

      expect(scheduler.alarmsScheduled, hasLength(1));
      final s = scheduler.alarmsScheduled.single;
      expect(s.id, ClockRepository.alarmNotificationId(id, 0));
      expect(s.at, nextOccurrence(18 * 60, 0, monNoon));
      expect(s.payload, 'alarm:$id');
    });

    test('disabled alarm schedules nothing', () async {
      await repo.createAlarm(
        timeOfDayMinutes: 8 * 60,
        repeatDays: 0,
        enabled: false,
        now: monNoon,
      );
      expect(scheduler.alarmsScheduled, isEmpty);
    });

    test('requests POST_NOTIFICATIONS permission contextually', () async {
      await repo.createAlarm(
          timeOfDayMinutes: 8 * 60, repeatDays: 0, now: monNoon);
      expect(scheduler.permissionRequests, 1);
    });
  });

  group('setAlarmEnabled', () {
    test('disabling cancels all slots; re-enabling reschedules', () async {
      final mask = weekdayBit(DateTime.tuesday);
      final id = await repo.createAlarm(
          timeOfDayMinutes: 9 * 60, repeatDays: mask, now: monNoon);
      scheduler.alarmsScheduled.clear();

      await repo.setAlarmEnabled(id, false, now: monNoon);
      // Cancels the one-off slot + all seven weekday slots (safe regardless).
      expect(scheduler.cancelled, contains(ClockRepository.alarmNotificationId(id, 0)));
      expect(scheduler.cancelled,
          contains(ClockRepository.alarmNotificationId(id, DateTime.tuesday)));
      expect((await dao.findAlarm(id))!.enabled, isFalse);

      await repo.setAlarmEnabled(id, true, now: monNoon);
      expect((await dao.findAlarm(id))!.enabled, isTrue);
      // Re-enabling reschedules the recurring slot.
      expect(
        scheduler.alarmsScheduled.map((s) => s.id),
        contains(ClockRepository.alarmNotificationId(id, DateTime.tuesday)),
      );
    });
  });

  group('updateAlarm', () {
    test('cancels old notifications and reschedules from the new schedule',
        () async {
      final id = await repo.createAlarm(
          timeOfDayMinutes: 6 * 60, repeatDays: 0, now: monNoon);
      scheduler.alarmsScheduled.clear();
      scheduler.cancelled.clear();

      await repo.updateAlarm(
        id,
        timeOfDayMinutes: 10 * 60,
        repeatDays: weekdayBit(DateTime.sunday),
        now: monNoon,
      );

      // Cancelled the prior slots.
      expect(scheduler.cancelled, contains(ClockRepository.alarmNotificationId(id, 0)));
      // Rescheduled the new recurring Sunday slot.
      expect(
        scheduler.alarmsScheduled.single.id,
        ClockRepository.alarmNotificationId(id, DateTime.sunday),
      );
      final row = await dao.findAlarm(id);
      expect(row!.timeOfDayMinutes, 10 * 60);
      expect(row.repeatDays, weekdayBit(DateTime.sunday));
    });
  });

  group('snooze', () {
    test('schedules a re-fire `minutes` from now under the one-off slot id',
        () async {
      final id = await repo.createAlarm(
          timeOfDayMinutes: 7 * 60, repeatDays: 0, now: monNoon);
      scheduler.alarmsScheduled.clear();

      await repo.snooze(id, 9, now: monNoon);

      final s = scheduler.alarmsScheduled.single;
      expect(s.id, ClockRepository.alarmNotificationId(id, 0));
      expect(s.at, monNoon.add(const Duration(minutes: 9)));
      expect(s.payload, 'alarm:$id');
    });

    test('honours the interval argument (not hard-coded 9)', () async {
      final id = await repo.createAlarm(
          timeOfDayMinutes: 7 * 60, repeatDays: 0, now: monNoon);
      scheduler.alarmsScheduled.clear();

      await repo.snooze(id, 15, now: monNoon);
      expect(scheduler.alarmsScheduled.single.at,
          monNoon.add(const Duration(minutes: 15)));
    });
  });

  group('dismiss', () {
    test('one-off: disables the alarm and cancels its ring', () async {
      final id = await repo.createAlarm(
          timeOfDayMinutes: 7 * 60, repeatDays: 0, now: monNoon);
      scheduler.cancelled.clear();

      await repo.dismiss(id, now: monNoon);

      expect((await dao.findAlarm(id))!.enabled, isFalse);
      expect(scheduler.cancelled,
          contains(ClockRepository.alarmNotificationId(id, 0)));
    });

    test('recurring: stays enabled with next occurrence still scheduled',
        () async {
      final mask = weekdayBit(DateTime.monday) | weekdayBit(DateTime.thursday);
      final id = await repo.createAlarm(
          timeOfDayMinutes: 7 * 60, repeatDays: mask, now: monNoon);
      scheduler.alarmsScheduled.clear();
      scheduler.cancelled.clear();

      await repo.dismiss(id, now: monNoon);

      expect((await dao.findAlarm(id))!.enabled, isTrue,
          reason: 'a recurring alarm stays armed after dismiss');
      // Cancels the transient snooze slot...
      expect(scheduler.cancelled,
          contains(ClockRepository.alarmNotificationId(id, 0)));
      // ...and re-registers the per-weekday schedule.
      expect(
        scheduler.alarmsScheduled.map((s) => s.id).toSet(),
        {
          ClockRepository.alarmNotificationId(id, DateTime.monday),
          ClockRepository.alarmNotificationId(id, DateTime.thursday),
        },
      );
    });
  });

  group('watchTodaysAlarmCount (real, via 06 ringsToday)', () {
    test('every-day-recurring enabled alarms are counted as due today',
        () async {
      // every-day recurring is always due today regardless of the wall clock
      // watchTodaysAlarmCount reads internally — a deterministic floor.
      await repo.createAlarm(
          timeOfDayMinutes: 23 * 60, repeatDays: everyDayMask, now: monNoon);
      await repo.createAlarm(
          timeOfDayMinutes: 6 * 60, repeatDays: everyDayMask, now: monNoon);
      expect(await repo.watchTodaysAlarmCount().first, 2);
    });

    test('disabled alarms are excluded from the count', () async {
      final id = await repo.createAlarm(
          timeOfDayMinutes: 23 * 60, repeatDays: everyDayMask, now: monNoon);
      expect(await repo.watchTodaysAlarmCount().first, 1);
      await repo.setAlarmEnabled(id, false, now: monNoon);
      expect(await repo.watchTodaysAlarmCount().first, 0,
          reason: 'a disabled alarm is not due, even with all weekday bits set');
    });

    test('one-off whose time-of-day has already passed today is not counted',
        () async {
      // A one-off at 00:01 — past for essentially the entire test-run day, so
      // ringsToday(now) is false. (Edge: if the suite runs in that first
      // minute, this would flip; acceptable for a deterministic-enough check.)
      await repo.createAlarm(
          timeOfDayMinutes: 1, repeatDays: 0, now: monNoon);
      expect(await repo.watchTodaysAlarmCount().first, 0);
    });

    test('recurring with today bit set vs. not, asserted via 06 directly', () {
      // The wall-clock-coupled count is exercised above; here we pin the pure
      // predicate the count is built on, for the Monday example.
      expect(ringsToday(7 * 60, weekdayBit(DateTime.monday), monNoon), isTrue);
      expect(ringsToday(7 * 60, weekdayBit(DateTime.tuesday), monNoon), isFalse);
      expect(ringsToday(18 * 60, 0, monNoon), isTrue, reason: '18:00 > noon');
      expect(ringsToday(6 * 60, 0, monNoon), isFalse, reason: '06:00 < noon');
    });
  });

  group('alarmNotificationId', () {
    test('alarm ids are offset out of the timer id space and distinct per slot',
        () {
      final oneOff = ClockRepository.alarmNotificationId(5, 0);
      final mon = ClockRepository.alarmNotificationId(5, DateTime.monday);
      final sun = ClockRepository.alarmNotificationId(5, DateTime.sunday);
      expect(oneOff, greaterThan(1000));
      expect({oneOff, mon, sun}, hasLength(3));
      // A different alarm never collides with another's slots.
      expect(ClockRepository.alarmNotificationId(6, 0),
          isNot(ClockRepository.alarmNotificationId(5, 0)));
    });
  });
}
