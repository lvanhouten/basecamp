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
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_timerChannel);
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
}
