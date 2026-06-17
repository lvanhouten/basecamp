import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'alarm_ringing_screen.dart';
import 'data/alarm_launch_router.dart';

/// Wraps the hub and routes full-screen alarm launches to the
/// [AlarmRingingScreen] (08-alarm-ui). When a full-screen alarm notification
/// launches the app from a dead process (cold) or is acted on while it's alive
/// (warm), the firing alarm's id (decoded from its `alarm:<id>` payload by the
/// [AlarmLaunchRouter]) is pushed as a ring screen onto the navigator above this
/// host (ADR-0003/0004: Snooze/Dismiss logic runs in the foreground once the
/// full-screen intent opens the app).
///
/// It sits as the [MaterialApp.home] (so its context is under the root
/// [Navigator]) and renders [child] (the hub) underneath. Factored out of
/// `app.dart` so the routing is unit-testable with a trivial [child] and a fake
/// router — the full hub isn't needed and brings Hero/settle noise that has
/// nothing to do with the routing under test. Real OS full-screen launch over
/// the lock screen is verified manually on the emulator (out of scope here).
class AlarmLaunchHost extends ConsumerStatefulWidget {
  const AlarmLaunchHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AlarmLaunchHost> createState() => _AlarmLaunchHostState();
}

class _AlarmLaunchHostState extends ConsumerState<AlarmLaunchHost> {
  StreamSubscription<int>? _warmSub;

  @override
  void initState() {
    super.initState();
    // Wire after the first frame so the Navigator above this host exists.
    WidgetsBinding.instance.addPostFrameCallback((_) => _wire());
  }

  Future<void> _wire() async {
    if (!mounted) return;
    final router = ref.read(alarmLaunchRouterProvider);

    // Warm: a full-screen alarm notification acted on while the app is alive.
    _warmSub = router.warmAlarmIds.listen(_openRing);

    // Cold: the app was launched by a firing alarm from a dead process.
    final coldId = await router.coldLaunchAlarmId();
    if (coldId != null) _openRing(coldId);
  }

  /// Push the ring screen for [alarmId] onto the root navigator above this host.
  void _openRing(int alarmId) {
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (_) => AlarmRingingScreen(alarmId: alarmId),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  void dispose() {
    _warmSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
