import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'clock_repository.dart';

/// The launch-routing seam, overridable in tests/widget pumps with a
/// [NoopAlarmLaunchRouter] or a fake (a fixed cold-launch id / a controllable
/// warm stream) so the root's alarm routing is verifiable without the plugin.
/// Defined here (not in `core/providers.dart`) so brief 08 wires its own
/// routing without editing the shared providers file that 07 owns.
final alarmLaunchRouterProvider = Provider<AlarmLaunchRouter>((ref) {
  return LocalNotificationLaunchRouter();
});

/// Parses an alarm notification [payload] (the `alarm:<id>` convention from
/// [ClockRepository.alarmPayload]) into the firing alarm's id, or `null` if the
/// payload is absent / not an alarm payload (e.g. a `timer:<id>` payload, which
/// the timer routing — not this — owns). Pure so the routing decision is unit
/// tested without the plugin.
int? parseAlarmPayload(String? payload) {
  const prefix = 'alarm:';
  if (payload == null || !payload.startsWith(prefix)) return null;
  return int.tryParse(payload.substring(prefix.length));
}

/// The launch-routing seam the root app (08-alarm-ui) drives to open the
/// [AlarmRingingScreen] when a full-screen alarm notification launches or
/// resumes the app (ADR-0003 / ADR-0004: Snooze/Dismiss logic runs in the
/// foreground once the full-screen intent opens the app). Abstracted over
/// `flutter_local_notifications` so the routing is testable with a fake — the
/// real OS full-screen launch over the lock screen is verified manually on the
/// emulator (out of scope for automated tests).
///
/// Two channels, mirroring the plugin:
///   - [coldLaunchAlarmId]: if the app was launched *by* a firing alarm
///     notification (cold start from a dead process), the alarm id; else `null`.
///   - [warmAlarmIds]: a stream of alarm ids for notifications selected while
///     the app is already alive (warm).
///
/// Both already decode the `alarm:<id>` payload — non-alarm payloads (a tapped
/// timer notification) are filtered out and never emitted here.
abstract interface class AlarmLaunchRouter {
  /// The alarm id that cold-launched the app from a dead process via its
  /// full-screen notification, or `null` if the app started normally / from a
  /// non-alarm notification. Read once at startup.
  Future<int?> coldLaunchAlarmId();

  /// Alarm ids for full-screen alarm notifications acted on while the app is
  /// already running (warm). Broadcast so the root listener can subscribe for
  /// the app's lifetime.
  Stream<int> get warmAlarmIds;
}

/// Real [AlarmLaunchRouter] over `flutter_local_notifications`.
///
/// On construction it registers an `onDidReceiveNotificationResponse` callback
/// (via [initialize]) that decodes alarm payloads onto [warmAlarmIds]; reading
/// [coldLaunchAlarmId] consults `getNotificationAppLaunchDetails`. Initializing
/// here is idempotent with the scheduler's own init — the plugin's last
/// `initialize` wins for the response callback, and the root wires this router
/// once at startup, so the alarm response callback is the live one.
class LocalNotificationLaunchRouter implements AlarmLaunchRouter {
  LocalNotificationLaunchRouter([FlutterLocalNotificationsPlugin? plugin])
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  final _warm = StreamController<int>.broadcast();
  bool _initialized = false;

  Future<void> _ensureInit() async {
    if (_initialized) return;
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final id = parseAlarmPayload(response.payload);
        if (id != null) _warm.add(id);
      },
    );
    _initialized = true;
  }

  @override
  Future<int?> coldLaunchAlarmId() async {
    // Guard the platform-channel calls: on a non-mobile / test host the plugin
    // isn't wired and these throw. A failed launch-details read must NOT crash
    // app startup — it simply means "no alarm launched us" (the app boots into
    // the hub normally). Production callers on Android get the real result.
    try {
      await _ensureInit();
      final details = await _plugin.getNotificationAppLaunchDetails();
      if (details == null || !details.didNotificationLaunchApp) return null;
      return parseAlarmPayload(details.notificationResponse?.payload);
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<int> get warmAlarmIds => _warm.stream;
}

/// A router that cold-launches nothing and never emits — the safe default in
/// non-mobile/test contexts where the plugin isn't wired. Tests inject their own
/// fake (e.g. a fixed cold-launch id, or a controller for the warm stream).
///
/// [warmAlarmIds] is a non-completing controller stream rather than
/// `Stream.empty()` on purpose: an empty stream schedules a zero-duration Timer
/// to deliver its `onDone`, which trips flutter_test's "a Timer is still
/// pending" guard for a one-`pump` boot test. A never-closing controller emits
/// nothing AND schedules no timer.
@visibleForTesting
class NoopAlarmLaunchRouter implements AlarmLaunchRouter {
  NoopAlarmLaunchRouter();

  final _warm = StreamController<int>.broadcast();

  @override
  Future<int?> coldLaunchAlarmId() async => null;

  @override
  Stream<int> get warmAlarmIds => _warm.stream;
}
