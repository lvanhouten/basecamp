import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// The OS-scheduling seam the Clock repository depends on. Abstracts
/// `flutter_local_notifications` so the repository's scheduling coordination is
/// testable with a fake (see `FakeNotificationScheduler` in tests). Per ADR-0003
/// the OS — not a Dart ticker — holds the schedule, so notifications fire while
/// the app is backgrounded or its process is dead.
///
/// EXTENSION POINT (07-alarm-data): Alarms need a *full-screen intent* ring that
/// takes over the lock screen (not a heads-up notification) plus reboot
/// rescheduling of recurring alarms. Brief 07 should:
///   - add a sibling method here, e.g. `scheduleAlarm(id, at, payload)`, that
///     builds its `AndroidNotificationDetails` with `fullScreenIntent: true` on
///     a dedicated high-importance channel (this Timer impl deliberately uses a
///     *heads-up* notification, `fullScreenIntent: false` — Timers must not take
///     over the screen, ADR-0003);
///   - extend the boot-reschedule path (see `RECEIVE_BOOT_COMPLETED` in the
///     manifest + the plugin's `ScheduledNotificationBootReceiver`): the plugin
///     already re-registers pending `zonedSchedule`d notifications across reboot,
///     so a one-off timer survives a restart for free; recurring alarms that
///     compute their *next* fire need 07 to recompute and re-`zonedSchedule` on
///     boot.
/// Keep this interface additive — Timer's `schedule`/`cancel` stay as-is.
abstract interface class NotificationScheduler {
  /// Requests the runtime POST_NOTIFICATIONS permission (Android 13+) if not
  /// already granted. Called contextually on first timer creation. Returns true
  /// if notifications may be posted. A `false` result does NOT stop the timer —
  /// the repository surfaces an in-app warning and the timer still runs.
  Future<bool> ensurePermission();

  /// Schedules a one-shot, heads-up completion notification with [id] at the
  /// absolute wall-clock time [at], carrying [payload] (used to route the tap
  /// back into the timer). Scheduled exact-while-idle so it fires when the app
  /// is backgrounded or dead.
  Future<void> schedule({
    required int id,
    required DateTime at,
    String? payload,
  });

  /// Cancels a previously-scheduled notification by [id] (no-op if none).
  Future<void> cancel(int id);

  /// Schedules a **full-screen-intent ALARM** with [id] at the absolute
  /// wall-clock time [at], carrying [payload] (the firing alarm's id, so brief
  /// 08's launch routing can read which alarm rang — see the `alarm:<id>`
  /// payload convention used by [ClockRepository]). Unlike [schedule] (a
  /// heads-up timer notification), this builds its details with
  /// `fullScreenIntent: true` on a dedicated high-importance channel so it takes
  /// over the lock screen (ADR-0003). Recurring alarms register one of these per
  /// selected weekday (distinct [id]s); a one-off registers one. Scheduled
  /// exact-while-idle so it fires while the app is dead.
  ///
  /// IMPORTANT: alarm notification ids are NOT the bare alarm row id (which a
  /// timer might also use) — the repository derives a stable per-weekday id
  /// (`alarmNotificationId`) so a recurring alarm's seven slots don't collide
  /// and so [cancel] can tear them down. [payload] still carries the bare row
  /// id for 08's routing.
  Future<void> scheduleAlarm({
    required int id,
    required DateTime at,
    String? payload,
  });

  /// Re-registers all enabled alarms' scheduled notifications. The Android boot
  /// receiver (`ScheduledNotificationBootReceiver`, RECEIVE_BOOT_COMPLETED in
  /// the manifest) re-registers pending `zonedSchedule`d notifications across a
  /// reboot for free — so a one-off survives. Recurring alarms whose *next*
  /// fire must be recomputed are re-registered by the repository calling its own
  /// reschedule-all (`rescheduleEnabledAlarmsOnBoot`) on app launch / boot,
  /// which delegates here per-slot via [scheduleAlarm]. [slots] is the flat list
  /// of (notification id, fire instant, payload) the repository computed from
  /// the enabled alarms via brief 06's `nextOccurrence` / `weekdaySchedule`.
  Future<void> rescheduleAlarms(List<ScheduledAlarm> slots);
}

/// One concrete alarm notification the scheduler should (re)register: a stable
/// notification [id], its absolute fire instant [at], and the routing [payload]
/// (the firing alarm row's id). The repository builds these from the enabled
/// alarms + brief 06's recurrence math; [NotificationScheduler.rescheduleAlarms]
/// registers one full-screen-intent notification per entry.
class ScheduledAlarm {
  const ScheduledAlarm({
    required this.id,
    required this.at,
    this.payload,
  });

  final int id;
  final DateTime at;
  final String? payload;

  @override
  bool operator ==(Object other) =>
      other is ScheduledAlarm &&
      other.id == id &&
      other.at == at &&
      other.payload == payload;

  @override
  int get hashCode => Object.hash(id, at, payload);

  @override
  String toString() => 'ScheduledAlarm(id: $id, at: $at, payload: $payload)';
}

/// Real implementation over `flutter_local_notifications` + `timezone`.
///
/// Lazily initializes the plugin and the timezone database on first use, so
/// constructing it (e.g. in a provider) is cheap and side-effect-free.
class LocalNotificationScheduler implements NotificationScheduler {
  LocalNotificationScheduler([FlutterLocalNotificationsPlugin? plugin])
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  /// Heads-up channel for Timer completions — high importance so it pops over
  /// the current app, but NOT a full-screen takeover (ADR-0003). 07 adds a
  /// separate channel for the alarm full-screen intent.
  static const _timerChannel = AndroidNotificationChannel(
    'clock_timer',
    'Timers',
    description: 'Countdown timer completion alerts',
    importance: Importance.high,
  );

  /// Dedicated MAX-importance channel for Alarm rings — distinct from the timer
  /// channel so the alarm can carry a full-screen intent (lock-screen takeover)
  /// and its own behaviour, per ADR-0003. The looping chime is played by the
  /// launched ring screen (08) via [ChimePlayer], not by this channel — a
  /// one-shot notification sound isn't a real alarm.
  static const _alarmChannel = AndroidNotificationChannel(
    'clock_alarm',
    'Alarms',
    description: 'Full-screen alarm rings',
    importance: Importance.max,
  );

  Future<void> _ensureInit() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    // The plugin resolves the device local zone at schedule time via
    // tz.local; initializeTimeZones populates the database it reads. Local
    // wall-clock scheduling is the contract (ADR-0003).
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(initSettings);
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(_timerChannel);
    await android?.createNotificationChannel(_alarmChannel);
    _initialized = true;
  }

  @override
  Future<bool> ensurePermission() async {
    await _ensureInit();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return true; // non-Android: assume allowed.
    final granted = await android.requestNotificationsPermission();
    return granted ?? true;
  }

  @override
  Future<void> schedule({
    required int id,
    required DateTime at,
    String? payload,
  }) async {
    await _ensureInit();
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _timerChannel.id,
        _timerChannel.name,
        channelDescription: _timerChannel.description,
        importance: Importance.high,
        priority: Priority.high,
        category: AndroidNotificationCategory.alarm,
        fullScreenIntent: false, // heads-up, not a takeover (ADR-0003).
        actions: const <AndroidNotificationAction>[
          AndroidNotificationAction('dismiss', 'Dismiss'),
          AndroidNotificationAction('plus_one', '+1 min'),
        ],
      ),
    );
    await _plugin.zonedSchedule(
      id,
      'Timer finished',
      'Your timer is up.',
      tz.TZDateTime.from(at, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  @override
  Future<void> cancel(int id) async {
    await _ensureInit();
    await _plugin.cancel(id);
  }

  @override
  Future<void> scheduleAlarm({
    required int id,
    required DateTime at,
    String? payload,
  }) async {
    await _ensureInit();
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _alarmChannel.id,
        _alarmChannel.name,
        channelDescription: _alarmChannel.description,
        importance: Importance.max,
        priority: Priority.max,
        category: AndroidNotificationCategory.alarm,
        // The alarm difference vs. the timer: take over the lock screen
        // (ADR-0003). The launched ring screen (08) plays the looping chime.
        fullScreenIntent: true,
        // The ring screen owns dismiss/snooze; the notification offers them too
        // so a user who only pulls the shade can act.
        actions: const <AndroidNotificationAction>[
          AndroidNotificationAction('dismiss', 'Dismiss'),
          AndroidNotificationAction('snooze', 'Snooze'),
        ],
      ),
    );
    await _plugin.zonedSchedule(
      id,
      'Alarm',
      'Your alarm is ringing.',
      tz.TZDateTime.from(at, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  @override
  Future<void> rescheduleAlarms(List<ScheduledAlarm> slots) async {
    await _ensureInit();
    for (final slot in slots) {
      await scheduleAlarm(id: slot.id, at: slot.at, payload: slot.payload);
    }
  }
}

/// A scheduler that records nothing and does nothing — used by the repository
/// provider's default in non-mobile/test contexts where the plugin isn't wired,
/// and as a safe fallback. Tests inject their own recording fake instead.
@visibleForTesting
class NoopNotificationScheduler implements NotificationScheduler {
  const NoopNotificationScheduler();

  @override
  Future<bool> ensurePermission() async => true;

  @override
  Future<void> schedule({
    required int id,
    required DateTime at,
    String? payload,
  }) async {}

  @override
  Future<void> cancel(int id) async {}

  @override
  Future<void> scheduleAlarm({
    required int id,
    required DateTime at,
    String? payload,
  }) async {}

  @override
  Future<void> rescheduleAlarms(List<ScheduledAlarm> slots) async {}
}
