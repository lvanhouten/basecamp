import 'package:basecamp/features/clock/data/alarm_recurrence.dart';
import 'package:flutter_test/flutter_test.dart';

// Anchor dates (verified against the proleptic Gregorian calendar):
//   2024-06-10 = Monday    (DateTime.weekday 1, bit 0)
//   2024-06-11 = Tuesday   (weekday 2, bit 1)
//   2024-06-12 = Wednesday (weekday 3, bit 2)
//   2024-06-13 = Thursday  (weekday 4, bit 3)
//   2024-06-14 = Friday    (weekday 5, bit 4)
//   2024-06-15 = Saturday  (weekday 6, bit 5)
//   2024-06-16 = Sunday    (weekday 7, bit 6)
// All tests build local DateTimes (the math operates in local wall-clock
// terms) and inject `from`/`date` explicitly — nothing reads the clock.

const int monBit = 1 << 0;
const int tueBit = 1 << 1;
const int wedBit = 1 << 2;
const int thuBit = 1 << 3;
const int friBit = 1 << 4;
const int satBit = 1 << 5;
const int sunBit = 1 << 6;

/// 09:00 in minutes since midnight.
const int nineAm = 9 * 60;

void main() {
  group('weekday-bit convention', () {
    test('bit 0 = Monday ... bit 6 = Sunday, aligned to DateTime.weekday', () {
      expect(weekdayBit(DateTime.monday), monBit);
      expect(weekdayBit(DateTime.tuesday), tueBit);
      expect(weekdayBit(DateTime.wednesday), wedBit);
      expect(weekdayBit(DateTime.thursday), thuBit);
      expect(weekdayBit(DateTime.friday), friBit);
      expect(weekdayBit(DateTime.saturday), satBit);
      expect(weekdayBit(DateTime.sunday), sunBit);
    });

    test('everyDayMask is all seven bits (0x7F)', () {
      expect(everyDayMask, 0x7F);
      expect(everyDayMask, monBit | tueBit | wedBit | thuBit | friBit | satBit | sunBit);
    });

    test('maskHasWeekday reads the right bit', () {
      final weekdays = monBit | tueBit | wedBit | thuBit | friBit; // Mon-Fri
      expect(maskHasWeekday(weekdays, DateTime.monday), isTrue);
      expect(maskHasWeekday(weekdays, DateTime.friday), isTrue);
      expect(maskHasWeekday(weekdays, DateTime.saturday), isFalse);
      expect(maskHasWeekday(weekdays, DateTime.sunday), isFalse);
    });

    test('isRecurring: 0 is one-off, any set bit is recurring', () {
      expect(isRecurring(0), isFalse);
      expect(isRecurring(monBit), isTrue);
      expect(isRecurring(everyDayMask), isTrue);
    });
  });

  group('nextOccurrence — one-off (mask 0)', () {
    test('today at the time-of-day when still ahead', () {
      final from = DateTime(2024, 6, 10, 7, 30); // Mon 07:30
      expect(
        nextOccurrence(nineAm, 0, from),
        DateTime(2024, 6, 10, 9, 0), // same day 09:00
      );
    });

    test('tomorrow when the time-of-day has already passed today', () {
      final from = DateTime(2024, 6, 10, 10, 0); // Mon 10:00 — past 09:00
      expect(
        nextOccurrence(nineAm, 0, from),
        DateTime(2024, 6, 11, 9, 0), // next day 09:00
      );
    });

    test('exactly-now rolls to tomorrow (strictly ahead)', () {
      final from = DateTime(2024, 6, 10, 9, 0); // Mon 09:00 == time-of-day
      expect(
        nextOccurrence(nineAm, 0, from),
        DateTime(2024, 6, 11, 9, 0),
      );
    });

    test('midnight time-of-day (0) that is still ahead = today 00:00', () {
      final from = DateTime(2024, 6, 9, 23, 59); // Sun 23:59
      expect(
        nextOccurrence(0, 0, from),
        DateTime(2024, 6, 10, 0, 0), // the next 00:00 (next calendar day)
      );
    });

    test('one-off crosses a month boundary correctly', () {
      final from = DateTime(2024, 6, 30, 23, 0); // 23:00 on the last of June
      expect(
        nextOccurrence(nineAm, 0, from),
        DateTime(2024, 7, 1, 9, 0), // rolls into July
      );
    });
  });

  group('nextOccurrence — recurring', () {
    test('today when today\'s bit is set and time is still ahead', () {
      final from = DateTime(2024, 6, 10, 7, 0); // Monday 07:00
      expect(
        nextOccurrence(nineAm, monBit, from),
        DateTime(2024, 6, 10, 9, 0),
      );
    });

    test('skips today to next week when today is set but already passed', () {
      // Monday-only alarm, but it is already 10:00 on Monday -> next Monday.
      final from = DateTime(2024, 6, 10, 10, 0);
      expect(
        nextOccurrence(nineAm, monBit, from),
        DateTime(2024, 6, 17, 9, 0), // following Monday
      );
    });

    test('next set weekday when today is not selected', () {
      // Wed+Fri alarm, evaluated Monday -> Wednesday.
      final from = DateTime(2024, 6, 10, 8, 0); // Monday
      expect(
        nextOccurrence(nineAm, wedBit | friBit, from),
        DateTime(2024, 6, 12, 9, 0), // Wednesday
      );
    });

    test('wraps across the week end: Sunday-only evaluated on Friday', () {
      final from = DateTime(2024, 6, 14, 8, 0); // Friday
      expect(
        nextOccurrence(nineAm, sunBit, from),
        DateTime(2024, 6, 16, 9, 0), // upcoming Sunday
      );
    });

    test('wraps to next week: Monday-only evaluated on Saturday', () {
      final from = DateTime(2024, 6, 15, 8, 0); // Saturday
      expect(
        nextOccurrence(nineAm, monBit, from),
        DateTime(2024, 6, 17, 9, 0), // following Monday
      );
    });

    test('exactly-now on a selected weekday rolls to the next set weekday', () {
      // Mon+Thu, from == Monday 09:00 exactly -> Thursday (today not strictly ahead).
      final from = DateTime(2024, 6, 10, 9, 0);
      expect(
        nextOccurrence(nineAm, monBit | thuBit, from),
        DateTime(2024, 6, 13, 9, 0), // Thursday
      );
    });

    test('daily (all 7 bits) yields today when still ahead', () {
      final from = DateTime(2024, 6, 12, 6, 0); // Wednesday 06:00
      final next = nextOccurrence(nineAm, everyDayMask, from);
      expect(next, DateTime(2024, 6, 12, 9, 0));
      expect(next.difference(from) <= const Duration(hours: 24), isTrue);
    });

    test('daily (all 7 bits) yields tomorrow when passed, within 24h', () {
      final from = DateTime(2024, 6, 12, 12, 0); // Wednesday 12:00, past 09:00
      final next = nextOccurrence(nineAm, everyDayMask, from);
      expect(next, DateTime(2024, 6, 13, 9, 0)); // Thursday 09:00
      expect(next.difference(from) <= const Duration(hours: 24), isTrue);
    });

    test('daily across a week-wraparound stays within 24h (Sunday eval)', () {
      final from = DateTime(2024, 6, 16, 12, 0); // Sunday 12:00, past 09:00
      final next = nextOccurrence(nineAm, everyDayMask, from);
      expect(next, DateTime(2024, 6, 17, 9, 0)); // Monday 09:00 (wraps)
      expect(next.difference(from) <= const Duration(hours: 24), isTrue);
    });
  });

  group('ringsToday', () {
    test('recurring: true when today\'s bit is set', () {
      final monday = DateTime(2024, 6, 10, 0, 0);
      expect(ringsToday(nineAm, monBit, monday), isTrue);
    });

    test('recurring: false when today\'s bit is not set', () {
      final monday = DateTime(2024, 6, 10, 0, 0);
      expect(ringsToday(nineAm, tueBit, monday), isFalse);
    });

    test('recurring: ignores time-of-day (true even if time already passed)', () {
      final mondayLate = DateTime(2024, 6, 10, 23, 0); // 23:00, past 09:00
      expect(ringsToday(nineAm, monBit, mondayLate), isTrue);
    });

    test('one-off: true when the time-of-day is still ahead today', () {
      final date = DateTime(2024, 6, 10, 7, 0); // 07:00, before 09:00
      expect(ringsToday(nineAm, 0, date), isTrue);
    });

    test('one-off: false when the time-of-day has already passed today', () {
      final date = DateTime(2024, 6, 10, 10, 0); // 10:00, after 09:00
      expect(ringsToday(nineAm, 0, date), isFalse);
    });

    test('one-off: exactly-now is not ahead -> false', () {
      final date = DateTime(2024, 6, 10, 9, 0); // exactly 09:00
      expect(ringsToday(nineAm, 0, date), isFalse);
    });
  });

  group('weekdaySchedule', () {
    test('one pair per set bit, Monday->Sunday order, all at the time-of-day', () {
      final slots = weekdaySchedule(nineAm, monBit | wedBit | friBit);
      expect(slots, const [
        AlarmWeekdaySlot(dartWeekday: DateTime.monday, timeOfDayMinutes: nineAm),
        AlarmWeekdaySlot(dartWeekday: DateTime.wednesday, timeOfDayMinutes: nineAm),
        AlarmWeekdaySlot(dartWeekday: DateTime.friday, timeOfDayMinutes: nineAm),
      ]);
    });

    test('daily yields exactly 7 slots, one per weekday', () {
      final slots = weekdaySchedule(nineAm, everyDayMask);
      expect(slots.length, 7);
      expect(
        slots.map((s) => s.dartWeekday).toList(),
        [
          DateTime.monday,
          DateTime.tuesday,
          DateTime.wednesday,
          DateTime.thursday,
          DateTime.friday,
          DateTime.saturday,
          DateTime.sunday,
        ],
      );
      expect(slots.every((s) => s.timeOfDayMinutes == nineAm), isTrue);
    });

    test('single weekday yields one slot', () {
      final slots = weekdaySchedule(nineAm, sunBit);
      expect(slots, const [
        AlarmWeekdaySlot(dartWeekday: DateTime.sunday, timeOfDayMinutes: nineAm),
      ]);
    });

    test('one-off (mask 0) yields no slots', () {
      expect(weekdaySchedule(nineAm, 0), isEmpty);
    });

    test('count of slots equals the set-bit count for every mask', () {
      for (var mask = 0; mask <= everyDayMask; mask++) {
        final setBits = mask.toRadixString(2).split('').where((c) => c == '1').length;
        expect(weekdaySchedule(nineAm, mask).length, setBits, reason: 'mask=$mask');
      }
    });
  });

  group('AlarmWeekdaySlot value semantics', () {
    test('equality and hashCode by (weekday, minutes)', () {
      const a = AlarmWeekdaySlot(dartWeekday: DateTime.monday, timeOfDayMinutes: nineAm);
      const b = AlarmWeekdaySlot(dartWeekday: DateTime.monday, timeOfDayMinutes: nineAm);
      const c = AlarmWeekdaySlot(dartWeekday: DateTime.tuesday, timeOfDayMinutes: nineAm);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a == c, isFalse);
    });
  });

  group('isValidTimeOfDay', () {
    test('accepts [0, 1440) and rejects out-of-range', () {
      expect(isValidTimeOfDay(0), isTrue);
      expect(isValidTimeOfDay(1439), isTrue);
      expect(isValidTimeOfDay(1440), isFalse);
      expect(isValidTimeOfDay(-1), isFalse);
    });
  });
}
