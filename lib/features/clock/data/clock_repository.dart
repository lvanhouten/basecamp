import '../../../core/contracts/clock_api.dart';
import '../../../core/db/app_db.dart';
import '../clock_math.dart' as clock_math;
import 'clock_dao.dart';
import 'notification_scheduler.dart';

/// The Clock module's own data access. It IMPLEMENTS [ClockApi] (the narrow
/// cross-module contract) and also exposes richer methods used only by the
/// Clock UI (mirroring `ListsRepository`'s repository/api split).
///
/// As of `04-timer-data` it coordinates the [ClockDao], the
/// [NotificationScheduler] seam, and the pure `clock_math` helpers for the Timer
/// tool, and [watchRunningTimerCount] is now a REAL Drift query. The other two
/// counts remain placeholders until their briefs land:
///   - [watchStopwatchRunning]  → 03-stopwatch
///   - [watchTodaysAlarmCount]  → 07-alarm-data
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
  Stream<int> watchTodaysAlarmCount() => Stream.value(0); // 07-alarm-data

  @override
  Stream<int> watchRunningTimerCount() =>
      _dao.watchRunningTimerCount(DateTime.now());

  @override
  Stream<bool> watchStopwatchRunning() => Stream.value(false); // 03-stopwatch

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
}
