import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/home_shell.dart';
import 'core/settings.dart';
import 'core/theme.dart';
import 'features/clock/alarm_launch_host.dart';

/// The app root. The hub ([HomeShell]) is wrapped in an [AlarmLaunchHost] so a
/// full-screen alarm notification that launches/resumes the app routes to the
/// ring screen (08-alarm-ui) — the host reads the firing alarm's `alarm:<id>`
/// payload and pushes `AlarmRingingScreen` onto the root navigator (ADR-0003/
/// 0004: Snooze/Dismiss runs in the foreground once the full-screen intent
/// opens the app).
class BasecampApp extends ConsumerWidget {
  const BasecampApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Basecamp',
      debugShowCheckedModeBanner: false,
      theme: basecampTheme(Brightness.light),
      darkTheme: basecampTheme(Brightness.dark),
      // User-selectable + persisted (01-theming-foundation). Profile (07)
      // writes it via ThemeModeController.set; the value survives cold start
      // because it's persisted in the generic JSON store and re-hydrated here.
      themeMode: ref.watch(themeModeProvider),
      home: const AlarmLaunchHost(child: HomeShell()),
    );
  }
}
