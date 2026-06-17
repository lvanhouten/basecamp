import 'package:flutter/material.dart';

import 'core/home_shell.dart';
import 'core/theme.dart';
import 'features/clock/alarm_launch_host.dart';

/// The app root. The hub ([HomeShell]) is wrapped in an [AlarmLaunchHost] so a
/// full-screen alarm notification that launches/resumes the app routes to the
/// ring screen (08-alarm-ui) — the host reads the firing alarm's `alarm:<id>`
/// payload and pushes `AlarmRingingScreen` onto the root navigator (ADR-0003/
/// 0004: Snooze/Dismiss runs in the foreground once the full-screen intent
/// opens the app).
class BasecampApp extends StatelessWidget {
  const BasecampApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Basecamp',
      debugShowCheckedModeBanner: false,
      theme: basecampTheme(Brightness.light),
      darkTheme: basecampTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      home: const AlarmLaunchHost(child: HomeShell()),
    );
  }
}
