/// Pure alarm-recurrence math for the Clock module's Alarms tool.
///
/// Everything here is a pure function of its arguments plus an **injected**
/// `from`/`now`/`date` — nothing reads the wall clock. That keeps the math
/// deterministic, exhaustively unit-testable, and correct across
/// backgrounding / cold start by construction (the same principle the PRD
/// applies to stopwatch/timer state: derive from persisted values + an
/// injected clock, never tick).
///
/// This module imports neither Flutter nor Drift; it is plain Dart so the
/// Alarms data layer (brief 07) can call it without dragging the storage or
/// UI stack into the math.
///
/// ## Weekday-bit convention (fixed — do not reinterpret elsewhere)
///
/// `repeatDays` is a 7-bit mask. The bit for a given weekday is `1 << bitIndex`:
///
/// ```text
///   bit 0 = Monday
///   bit 1 = Tuesday
///   bit 2 = Wednesday
///   bit 3 = Thursday
///   bit 4 = Friday
///   bit 5 = Saturday
///   bit 6 = Sunday
/// ```
///
/// This lines up with Dart's [DateTime.weekday] (1 = Monday … 7 = Sunday) via
/// `bitIndex = DateTime.weekday - 1`. Use [weekdayBit] / [maskHasWeekday]
/// rather than hand-rolling the shift so the convention stays in one place.
///
/// ## One-off vs recurring
///
/// * `repeatDays == 0` → **one-off**: the alarm fires once, at the next
///   occurrence of its time-of-day.
/// * `repeatDays != 0` → **recurring**: the alarm fires on every selected
///   weekday at its time-of-day, forever.
library;

/// Number of minutes in a day; a time-of-day is `[0, 1440)` minutes since
/// local midnight.
const int _minutesPerDay = 24 * 60;

/// The bit for [dartWeekday], where `dartWeekday` is a [DateTime.weekday]
/// value (1 = Monday … 7 = Sunday). Bit 0 = Monday … bit 6 = Sunday.
int weekdayBit(int dartWeekday) => 1 << (dartWeekday - 1);

/// Whether [repeatDaysMask] selects [dartWeekday] (a [DateTime.weekday] value,
/// 1 = Monday … 7 = Sunday).
bool maskHasWeekday(int repeatDaysMask, int dartWeekday) =>
    (repeatDaysMask & weekdayBit(dartWeekday)) != 0;

/// Whether [repeatDaysMask] is a recurring mask (at least one weekday set).
/// A mask of `0` is a one-off alarm.
bool isRecurring(int repeatDaysMask) => repeatDaysMask != 0;

/// The local [DateTime] for [timeOfDayMinutes] on the calendar day of [day].
/// Builds from the calendar parts so it lands on the correct local wall-clock
/// instant even across a DST boundary (no minute arithmetic on an instant).
DateTime _atTimeOfDay(DateTime day, int timeOfDayMinutes) => DateTime(
      day.year,
      day.month,
      day.day,
      timeOfDayMinutes ~/ 60,
      timeOfDayMinutes % 60,
    );

/// The next [DateTime] the alarm should fire, at or after [from].
///
/// * **One-off** (`repeatDaysMask == 0`): today at [timeOfDayMinutes] if that
///   instant is still strictly ahead of [from], otherwise tomorrow at the same
///   time-of-day. An exactly-now time-of-day (equal to [from] to the minute)
///   is treated as already passed and rolls to tomorrow.
/// * **Recurring** (`repeatDaysMask != 0`): the soonest selected weekday at
///   [timeOfDayMinutes] that is strictly ahead of [from]. Today counts only if
///   today's bit is set **and** its time-of-day is still ahead; otherwise it
///   scans forward day by day, wrapping across the week end. Because at least
///   one bit is set, a match is found within 7 days (within 24h for a daily
///   all-bits mask).
///
/// "Strictly ahead" means an alarm whose time-of-day equals [from] exactly
/// fires on the next eligible day, never zero seconds in the future.
DateTime nextOccurrence(
  int timeOfDayMinutes,
  int repeatDaysMask,
  DateTime from,
) {
  final todayAtTime = _atTimeOfDay(from, timeOfDayMinutes);

  if (!isRecurring(repeatDaysMask)) {
    // One-off: today if still strictly ahead, else tomorrow.
    if (todayAtTime.isAfter(from)) return todayAtTime;
    return _atTimeOfDay(from.add(const Duration(days: 1)), timeOfDayMinutes);
  }

  // Recurring: today counts only if its bit is set and the time is still ahead.
  if (maskHasWeekday(repeatDaysMask, from.weekday) &&
      todayAtTime.isAfter(from)) {
    return todayAtTime;
  }

  // Scan the next 7 days for the soonest selected weekday. Start at +1 so
  // today (already handled above) is never re-considered, which correctly
  // skips a today-but-already-passed selected weekday to next week.
  for (var offset = 1; offset <= 7; offset++) {
    final candidate = from.add(Duration(days: offset));
    if (maskHasWeekday(repeatDaysMask, candidate.weekday)) {
      return _atTimeOfDay(candidate, timeOfDayMinutes);
    }
  }

  // Unreachable: a non-zero mask always matches within 7 days. Guard so the
  // function is total rather than relying on the loop's control flow.
  throw StateError('repeatDaysMask $repeatDaysMask matched no weekday');
}

/// Whether the alarm is due to ring on the calendar day of [date].
///
/// * **Recurring**: true iff [date]'s weekday bit is set in [repeatDaysMask].
///   Time-of-day is irrelevant here — recurrence is a per-day property; the
///   scheduler uses [nextOccurrence] for the exact instant.
/// * **One-off**: true iff [timeOfDayMinutes] is still strictly ahead of
///   [date] on [date]'s own calendar day (an alarm earlier today has already
///   rung and is no longer "due today").
bool ringsToday(int timeOfDayMinutes, int repeatDaysMask, DateTime date) {
  if (isRecurring(repeatDaysMask)) {
    return maskHasWeekday(repeatDaysMask, date.weekday);
  }
  return _atTimeOfDay(date, timeOfDayMinutes).isAfter(date);
}

/// One scheduled occurrence of a recurring alarm: the [dartWeekday]
/// ([DateTime.weekday], 1 = Monday … 7 = Sunday) it fires on and its
/// [timeOfDayMinutes]. The scheduler registers exactly one repeating OS
/// notification per pair.
class AlarmWeekdaySlot {
  const AlarmWeekdaySlot({
    required this.dartWeekday,
    required this.timeOfDayMinutes,
  });

  /// [DateTime.weekday] value: 1 = Monday … 7 = Sunday.
  final int dartWeekday;

  /// Minutes since midnight the alarm fires at on [dartWeekday].
  final int timeOfDayMinutes;

  @override
  bool operator ==(Object other) =>
      other is AlarmWeekdaySlot &&
      other.dartWeekday == dartWeekday &&
      other.timeOfDayMinutes == timeOfDayMinutes;

  @override
  int get hashCode => Object.hash(dartWeekday, timeOfDayMinutes);

  @override
  String toString() =>
      'AlarmWeekdaySlot(weekday: $dartWeekday, minutes: $timeOfDayMinutes)';
}

/// The per-weekday schedule for a **recurring** alarm: exactly one
/// [AlarmWeekdaySlot] for each set bit in [repeatDaysMask], in Monday→Sunday
/// order, each at [timeOfDayMinutes]. The scheduler (brief 07) registers one
/// repeating OS notification per returned slot.
///
/// A one-off (`repeatDaysMask == 0`) has no weekday schedule and returns an
/// empty list — its single firing instant comes from [nextOccurrence], not
/// from this helper.
List<AlarmWeekdaySlot> weekdaySchedule(
  int timeOfDayMinutes,
  int repeatDaysMask,
) {
  final slots = <AlarmWeekdaySlot>[];
  // dartWeekday 1..7 = Monday..Sunday, matching bit 0..6.
  for (var dartWeekday = 1; dartWeekday <= 7; dartWeekday++) {
    if (maskHasWeekday(repeatDaysMask, dartWeekday)) {
      slots.add(
        AlarmWeekdaySlot(
          dartWeekday: dartWeekday,
          timeOfDayMinutes: timeOfDayMinutes,
        ),
      );
    }
  }
  return slots;
}

/// Convenience: a mask with all seven weekday bits set (daily). Exposed so the
/// data layer and tests share one definition of "every day".
const int everyDayMask = (1 << 7) - 1; // 0x7F == 127

/// Sanity guard for callers: a valid time-of-day is `[0, 1440)`.
bool isValidTimeOfDay(int timeOfDayMinutes) =>
    timeOfDayMinutes >= 0 && timeOfDayMinutes < _minutesPerDay;
