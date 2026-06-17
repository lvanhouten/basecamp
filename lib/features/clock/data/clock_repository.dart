import '../../../core/contracts/clock_api.dart';
import '../../../core/db/app_db.dart';
import '../clock_math.dart' as clock_math;
import 'alarm_recurrence.dart' as recur;
import 'clock_dao.dart';
import 'notification_scheduler.dart';
import 'stopwatch_state.dart';

/// The Clock module's own data access. It IMPLEMENTS [ClockApi] (the narrow
/// cross-module contract) and also exposes richer methods used only by the
/// Clock UI (mirroring `ListsRepository`'s repository/api split).
///
/// As of `04-timer-data` it coordinates the [ClockDao], the
/// [NotificationScheduler] seam, and the pure `clock_math` helpers for the Timer
/// tool, and [watchRunningTimerCount] is now a REAL Drift query. `03-stopwatch`
/// adds the Stopwatch methods and makes [watchStopwatchRunning] real.
/// `07-alarm-data` adds the Alarm tool (create/update/setEnabled/snooze/dismiss)
/// over the same DAO + scheduler, and makes [watchTodaysAlarmCount] real via
/// brief 06's `ringsToday`. All three counts are now real.
///
/// Later briefs widen the constructor with their own deps (03 reuses the same
/// DAO; 07 reuses the DAO + scheduler) — keep injection additive.
class ClockRepository implements ClockApi {
  ClockRepository(this._dao, this._scheduler);

  final ClockDao _dao;
  final NotificationScheduler _scheduler;

  /// Set false once the user denies POST_NOTIFICATIONS so the UI can surface a
  /// one-time in-app warning (the timer still runs — denial never blocks it).
  /// Read-only to callers; flipped only inside [createTimer].
  bool get notificationsAllowed => _notificationsAllowed;
  bool _notificationsAllowed = true;

  // --- ClockApi (visible to other modules via clockApiProvider) ---

  @override
  Stream<int> watchTodaysAlarmCount() {
    // Count of ENABLED alarms due to ring today: recurring with today's bit
    // set, or a one-off whose time-of-day is still ahead of now (an alarm
    // earlier today has already rung). Reactive over the alarms table; the
    // due-today predicate is brief 06's pure `ringsToday`. `now` is read per
    // emission so the count re-evaluates against the current day/time — it does
    // NOT tick on its own (no write = no re-emit), which is fine for a Brief
    // summary that settles on the next alarm mutation.
    return _dao.watchAlarms().map((alarms) {
      final now = DateTime.now();
      return alarms
          .where((a) =>
              a.enabled &&
              recur.ringsToday(a.timeOfDayMinutes, a.repeatDays, now))
          .length;
    });
  }

  @override
  Stream<int> watchRunningTimerCount() =>
      _dao.watchRunningTimerCount(DateTime.now());

  @override
  Stream<bool> watchStopwatchRunning() =>
      _dao.watchStopwatch().map((p) => StopwatchState.fromPayload(p).isRunning);

  // --- Timer tool (internal to the Clock module) ---

  /// Running timers (incl. just-finished, until dismissed), soonest `endsAt`
  /// first then creation order. Backs the TimerPane (05-timer-ui) running list.
  Stream<List<TimerRow>> watchRunningTimers() => _dao.watchRunningTimers();

  /// Every timer regardless of state (running / paused / finished).
  Stream<List<TimerRow>> watchAllTimers() => _dao.watchAllTimers();

  /// Create-and-start a timer from a [duration]: insert with
  /// `endsAt = now + duration` and schedule the OS completion notification at
  /// `endsAt`. POST_NOTIFICATIONS is requested contextually here (first timer);
  /// a denial flips [notificationsAllowed] but the timer still runs. Returns the
  /// new timer id (== its notification id).
  ///
  /// [now] is injected for deterministic tests; production callers omit it and
  /// the wall clock is used.
  Future<int> createTimer(
    Duration duration, {
    String? label,
    DateTime? now,
  }) async {
    final start = now ?? DateTime.now();
    final endsAt = start.add(duration);
    final id = await _dao.insertRunningTimer(
      label: label,
      durationMs: duration.inMilliseconds,
      endsAt: endsAt,
    );
    _notificationsAllowed = await _scheduler.ensurePermission();
    await _scheduler.schedule(id: id, at: endsAt, payload: 'timer:$id');
    return id;
  }

  /// Pause a running timer: capture remaining via clock-math at this instant,
  /// store it as `remainingMs`, clear `endsAt`, and cancel the scheduled
  /// notification. No-op if the timer was dismissed or is already paused
  /// (`endsAt` null).
  Future<void> pauseTimer(int id, {DateTime? now}) async {
    final timer = await _dao.findTimer(id);
    final endsAt = timer?.endsAt;
    if (endsAt == null) return; // dismissed or already paused.
    final remaining = clock_math.pausedRemaining(
      endsAt: endsAt,
      now: now ?? DateTime.now(),
    );
    await _dao.setPaused(id, remaining.inMilliseconds);
    await _scheduler.cancel(id);
  }

  /// Resume a paused timer: `endsAt = now + remainingMs`, clear `remainingMs`,
  /// and reschedule the completion notification. No-op if the timer was
  /// dismissed or is already running (`remainingMs` null).
  Future<void> resumeTimer(int id, {DateTime? now}) async {
    final timer = await _dao.findTimer(id);
    final remainingMs = timer?.remainingMs;
    if (remainingMs == null) return; // dismissed or already running.
    final endsAt =
        (now ?? DateTime.now()).add(Duration(milliseconds: remainingMs));
    await _dao.setRunning(id, endsAt);
    await _scheduler.schedule(id: id, at: endsAt, payload: 'timer:$id');
  }

  /// Cancel / dismiss a timer: delete the row and cancel its notification.
  /// Used both to abort a running/paused timer and to clear a finished one.
  Future<void> cancelTimer(int id) async {
    await _dao.deleteTimer(id);
    await _scheduler.cancel(id);
  }

  // --- Stopwatch tool (internal to the Clock module) ---

  /// The single stopwatch's persisted state, parsed into [StopwatchState].
  /// Reactive — re-emits on every transition write. Before the first
  /// interaction the record doesn't exist and this emits [StopwatchState.idle]
  /// (`accumulatedMs` 0, not running): a fresh install and an explicit reset
  /// look identical, which is correct. Backs the StopwatchPane's state.
  Stream<StopwatchState> watchStopwatch() =>
      _dao.watchStopwatch().map(StopwatchState.fromPayload);

  /// One-shot read of the current persisted state (no record ⇒ [idle]). Used by
  /// the pause/lap transitions to compute against the live `startedAt`, and by
  /// the pane's resume hook to re-sync its display ticker.
  Future<StopwatchState> readStopwatch() async =>
      StopwatchState.fromPayload(await _dao.watchStopwatch().first);

  /// Start (from idle or paused): stamp `startedAt = now`, set `isRunning`,
  /// preserving the banked `accumulatedMs` and any laps. No-op if already
  /// running (re-starting would discard the live segment's elapsed). [now] is
  /// injected for deterministic tests.
  Future<void> startStopwatch({DateTime? now}) async {
    final s = await readStopwatch();
    if (s.isRunning) return;
    await _dao.writeStopwatch(
      StopwatchState(
        startedAt: now ?? DateTime.now(),
        accumulatedMs: s.accumulatedMs,
        isRunning: true,
        laps: s.laps,
      ).toPayload(),
    );
  }

  /// Pause: bank the current live segment into `accumulatedMs` via clock-math,
  /// clear `startedAt`, set `isRunning = false`, keep laps. No-op if already
  /// paused (no live segment to bank).
  Future<void> pauseStopwatch({DateTime? now}) async {
    final s = await readStopwatch();
    if (!s.isRunning || s.startedAt == null) return;
    final elapsed = s.elapsedAt(now ?? DateTime.now());
    await _dao.writeStopwatch(
      StopwatchState(
        startedAt: null,
        accumulatedMs: elapsed.inMilliseconds,
        isRunning: false,
        laps: s.laps,
      ).toPayload(),
    );
  }

  /// Lap: append the current total elapsed (via clock-math) to `laps`, leaving
  /// the run state untouched. A lap while paused records the banked total.
  Future<void> lapStopwatch({DateTime? now}) async {
    final s = await readStopwatch();
    final elapsed = s.elapsedAt(now ?? DateTime.now());
    await _dao.writeStopwatch(
      StopwatchState(
        startedAt: s.startedAt,
        accumulatedMs: s.accumulatedMs,
        isRunning: s.isRunning,
        laps: [...s.laps, elapsed],
      ).toPayload(),
    );
  }

  /// Reset to zero: clear `accumulatedMs`, `startedAt`, laps, stop. Persists the
  /// idle record (rather than deleting it) so the stream emits the zeroed state.
  Future<void> resetStopwatch() async {
    await _dao.writeStopwatch(StopwatchState.idle.toPayload());
  }

  // --- Alarm tool (internal to the Clock module) ---
  //
  // An alarm's state that survives cold start is its row (time-of-day + weekday
  // mask + enabled). The *ring* is transient OS state: the full-screen-intent
  // notification(s) the scheduler holds (ADR-0003). Every create/update/enable/
  // disable/snooze/dismiss recomputes those notifications via brief 06's
  // recurrence math and the `scheduleAlarm`/`cancel` seam — so the coordination
  // is testable with a fake scheduler.

  /// Every alarm (enabled or not), soonest time-of-day first then creation
  /// order. Backs the AlarmsPane list (08-alarm-ui).
  Stream<List<AlarmRow>> watchAlarms() => _dao.watchAlarms();

  /// Derives the stable OS notification id for one scheduled occurrence of the
  /// alarm with [alarmId]. A recurring alarm registers up to seven distinct
  /// notifications (one per selected weekday); a one-off registers one. The id
  /// is `alarmId * 8 + weekdaySlot`, where `weekdaySlot` is the Dart weekday
  /// (1=Mon..7=Sun) for a recurring occurrence, or `0` for a one-off. Offset by
  /// [_alarmIdBase] so alarm notification ids never collide with timer ids
  /// (bare timer row ids). Exposed so `_cancelAlarm` can reconstruct exactly the
  /// ids it scheduled (cancel all 8 slots regardless of current mask).
  static int alarmNotificationId(int alarmId, int weekdaySlot) =>
      _alarmIdBase + alarmId * 8 + weekdaySlot;

  /// Floor for alarm notification ids, keeping them out of the timer id space
  /// (timer ids are small autoincrement row ids). 1,000,000 leaves room for
  /// ~125k alarms before overflow concerns — far beyond any real use.
  static const int _alarmIdBase = 1000000;

  /// The routing payload carried by an alarm notification: `alarm:<id>`. Brief
  /// 08 reads the firing alarm's id from this when the full-screen intent
  /// launches the ring screen.
  static String alarmPayload(int alarmId) => 'alarm:$alarmId';

  /// Computes the OS notifications for an enabled alarm and (re)schedules them:
  /// a recurring alarm schedules one full-screen notification per selected
  /// weekday at its next occurrence on that weekday; a one-off schedules a
  /// single notification at its next occurrence. Uses brief 06's
  /// `nextOccurrence` (one-off) / `weekdaySchedule` + per-weekday
  /// `nextOccurrence` (recurring). [from] is injected for deterministic tests.
  Future<void> _scheduleAlarm(AlarmRow alarm, DateTime from) async {
    _notificationsAllowed = await _scheduler.ensurePermission();
    final payload = alarmPayload(alarm.id);

    if (!recur.isRecurring(alarm.repeatDays)) {
      // One-off: a single notification at the next occurrence.
      final at = recur.nextOccurrence(alarm.timeOfDayMinutes, 0, from);
      await _scheduler.scheduleAlarm(
        id: alarmNotificationId(alarm.id, 0),
        at: at,
        payload: payload,
      );
      return;
    }

    // Recurring: one notification per selected weekday at that weekday's next
    // occurrence. We compute the next occurrence of a SINGLE-weekday mask so
    // each slot lands on its own day.
    for (final slot in recur.weekdaySchedule(
      alarm.timeOfDayMinutes,
      alarm.repeatDays,
    )) {
      final singleDayMask = recur.weekdayBit(slot.dartWeekday);
      final at = recur.nextOccurrence(slot.timeOfDayMinutes, singleDayMask, from);
      await _scheduler.scheduleAlarm(
        id: alarmNotificationId(alarm.id, slot.dartWeekday),
        at: at,
        payload: payload,
      );
    }
  }

  /// Cancels every OS notification an alarm may have scheduled (all weekday
  /// slots + the one-off slot), so it is safe regardless of whether the alarm
  /// is currently one-off or recurring (e.g. after an edit changed the mask).
  Future<void> _cancelAlarm(int alarmId) async {
    // Cancel the one-off slot AND all seven weekday slots unconditionally —
    // cancel is a no-op for ids that were never scheduled, and this stays
    // correct across a recurring↔one-off edit without tracking the prior mask.
    await _scheduler.cancel(alarmNotificationId(alarmId, 0));
    for (var weekday = 1; weekday <= 7; weekday++) {
      await _scheduler.cancel(alarmNotificationId(alarmId, weekday));
    }
  }

  /// Create a new alarm. When [enabled] (the default) its OS notification(s) are
  /// scheduled immediately via brief 06's recurrence. Returns the new alarm id.
  /// [now] is injected for deterministic tests.
  Future<int> createAlarm({
    required int timeOfDayMinutes,
    int repeatDays = 0,
    String? label,
    bool enabled = true,
    DateTime? now,
  }) async {
    final id = await _dao.insertAlarm(
      timeOfDayMinutes: timeOfDayMinutes,
      repeatDays: repeatDays,
      label: label,
      enabled: enabled,
    );
    if (enabled) {
      final alarm = await _dao.findAlarm(id);
      await _scheduleAlarm(alarm!, now ?? DateTime.now());
    }
    return id;
  }

  /// Edit an alarm's schedule/label. Cancels the old notification(s) and, if the
  /// alarm is enabled, reschedules from the new schedule. No-op if the alarm was
  /// deleted. [now] is injected for deterministic tests.
  Future<void> updateAlarm(
    int id, {
    required int timeOfDayMinutes,
    int repeatDays = 0,
    String? label,
    DateTime? now,
  }) async {
    await _cancelAlarm(id);
    await _dao.updateAlarm(
      id,
      timeOfDayMinutes: timeOfDayMinutes,
      repeatDays: repeatDays,
      label: label,
    );
    final alarm = await _dao.findAlarm(id);
    if (alarm == null) return; // deleted under us.
    if (alarm.enabled) {
      await _scheduleAlarm(alarm, now ?? DateTime.now());
    }
  }

  /// The true on/off. Enabling schedules the alarm's notification(s); disabling
  /// cancels them. No-op if the alarm was deleted. [now] injected for tests.
  Future<void> setAlarmEnabled(int id, bool enabled, {DateTime? now}) async {
    await _dao.setAlarmEnabled(id, enabled);
    final alarm = await _dao.findAlarm(id);
    if (alarm == null) return;
    if (enabled) {
      await _scheduleAlarm(alarm, now ?? DateTime.now());
    } else {
      await _cancelAlarm(id);
    }
  }

  /// Snooze the alarm with [id]: re-fire it [minutes] from now. v1 callers pass
  /// 9; the interval is a parameter so a later per-alarm / pick-list snooze is a
  /// caller-only change (the data layer already carries it). Schedules a single
  /// full-screen notification at `now + minutes` under the alarm's one-off slot
  /// id (the snooze is a one-shot re-ring, independent of the recurring
  /// schedule, which stays armed). No-op if the alarm was deleted.
  Future<void> snooze(int id, int minutes, {DateTime? now}) async {
    final alarm = await _dao.findAlarm(id);
    if (alarm == null) return;
    final at = (now ?? DateTime.now()).add(Duration(minutes: minutes));
    await _scheduler.scheduleAlarm(
      id: alarmNotificationId(id, 0),
      at: at,
      payload: alarmPayload(id),
    );
  }

  /// Dismiss the current ring of the alarm with [id]:
  ///   - **one-off** → disable it (`enabled = false`) and cancel its
  ///     notification — it has fired its one and only time.
  ///   - **recurring** → leave it enabled with its next occurrence still
  ///     scheduled; only the *current* ring is cleared (and any pending snooze).
  /// No-op if the alarm was deleted. [now] injected for tests (recurring needs
  /// it to recompute the next occurrence after clearing the snooze slot).
  Future<void> dismiss(int id, {DateTime? now}) async {
    final alarm = await _dao.findAlarm(id);
    if (alarm == null) return;

    if (!recur.isRecurring(alarm.repeatDays)) {
      // One-off: this was its single firing. Disable + cancel.
      await _dao.setAlarmEnabled(id, false);
      await _cancelAlarm(id);
      return;
    }

    // Recurring: cancel the one-off snooze slot (if a snooze was pending) but
    // keep the per-weekday schedule armed. Re-derive the weekday slots from the
    // current schedule so the next occurrences stay registered.
    await _scheduler.cancel(alarmNotificationId(id, 0));
    await _scheduleAlarm(alarm, now ?? DateTime.now());
  }

  /// Permanently remove the alarm with [id]: cancel every OS notification it may
  /// have registered (all weekday slots + the one-off/snooze slot), then delete
  /// the row. Cancelling FIRST is what keeps deletion leak-free — a row deleted
  /// without tearing down its scheduled full-screen notifications would still
  /// ring (the OS, not the row, holds the schedule — ADR-0003). Mirrors
  /// `cancelTimer`. No-op-safe if the alarm was already gone (`_cancelAlarm`
  /// cancels unconditionally; the delete simply affects no rows).
  Future<void> deleteAlarm(int id) async {
    await _cancelAlarm(id);
    await _dao.deleteAlarm(id);
  }
}
