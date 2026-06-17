import 'package:flutter/material.dart';

import 'data/alarm_recurrence.dart' as recur;

/// Presentation helpers for the Alarms tool (08-alarm-ui), shared by the pane
/// and the ring screen. Pure-ish: [repeatSummary] is a pure function of the mask
/// (unit-testable without a widget tree); [formatTimeOfDay] needs the ambient
/// locale/24h setting so it takes a [BuildContext].

/// A human repeat summary for a `repeatDays` 7-bit mask, matching the brief's
/// vocabulary:
///   - `0`            → "Once"   (one-off)
///   - all 7 bits     → "Daily"
///   - Mon–Fri only   → "Weekdays"
///   - Sat+Sun only   → "Weekends"
///   - any other set  → the selected day abbreviations, Mon→Sun
///     (e.g. "Mon, Wed, Fri").
///
/// Uses [recur.maskHasWeekday] / the brief-06 weekday-bit convention rather than
/// re-deriving the shift, so the summary can't disagree with the scheduler.
String repeatSummary(int repeatDaysMask) {
  if (!recur.isRecurring(repeatDaysMask)) return 'Once';
  if (repeatDaysMask == recur.everyDayMask) return 'Daily';
  if (repeatDaysMask == weekdaysMask) return 'Weekdays';
  if (repeatDaysMask == weekendsMask) return 'Weekends';

  // dartWeekday 1..7 == Mon..Sun; abbreviations in that order.
  const abbr = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final parts = <String>[];
  for (var dartWeekday = 1; dartWeekday <= 7; dartWeekday++) {
    if (recur.maskHasWeekday(repeatDaysMask, dartWeekday)) {
      parts.add(abbr[dartWeekday - 1]);
    }
  }
  return parts.join(', ');
}

/// Mon–Fri preset mask: bits 0..4 set (`1<<(weekday-1)` for Mon..Fri) = 0x1F.
/// Matches the binding-context preset; see `alarm_recurrence.dart` for the
/// weekday-bit convention.
const int weekdaysMask = 0x1F;

/// Sat+Sun preset mask: bits 5..6 set (Sat, Sun) = 0x60.
const int weekendsMask = 0x60;

/// Format [timeOfDayMinutes] (minutes since midnight) for display, honouring the
/// device's 12/24-hour setting via [MaterialLocalizations]. Falls back to a
/// padded `HH:mm` if localizations aren't available (e.g. a bare test pump).
String formatTimeOfDay(BuildContext context, int timeOfDayMinutes) {
  final tod = TimeOfDay(
    hour: timeOfDayMinutes ~/ 60,
    minute: timeOfDayMinutes % 60,
  );
  final loc = MaterialLocalizations.of(context);
  final use24h = MediaQuery.maybeOf(context)?.alwaysUse24HourFormat ?? false;
  return loc.formatTimeOfDay(tod, alwaysUse24HourFormat: use24h);
}
