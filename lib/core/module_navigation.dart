import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_module.dart';
import 'providers.dart';
import '../features/clock/clock_tab.dart';

/// Pushes [module]'s screen over the launcher shell as a returnable view
/// (ADR-0005). Modules are no longer kept alive as IndexedStack peers; they are
/// launched here and popped via the back arrow.
///
/// **Domain-state landing (ADR-0004):** where you land is derived from persisted
/// Drift state, computed on module ENTRY (this push) — never from a remembered
/// route. For Clock that means the entry-precedence tab (Stopwatch > Timer >
/// Alarms) is computed from the live counts and written to
/// [selectedClockTabProvider] *before* `ClockScreen` mounts, so the screen seeds
/// its TabController from it. With nothing in progress it resolves to the
/// resting default (Alarms).
///
/// Exposed as a free function (not buried in the shell) so the Modules grid
/// (brief 06) and any Brief affordance (brief 05) launch modules identically.
void pushModule(BuildContext context, WidgetRef ref, AppModule module) {
  if (module == AppModule.clock) {
    // Read the live counts through the Clock contract and pick the entry tab
    // via the existing pure precedence (ADR-0004). `.asData?.value` because the
    // counts are async; absent → resting default (Alarms) falls out naturally.
    final stopwatchRunning =
        ref.read(stopwatchRunningProvider).asData?.value ?? false;
    final runningTimerCount =
        ref.read(runningTimerCountProvider).asData?.value ?? 0;
    final todaysAlarmCount =
        ref.read(todaysAlarmCountProvider).asData?.value ?? 0;

    ref.read(selectedClockTabProvider.notifier).select(
          entryTab(
            stopwatchRunning: stopwatchRunning,
            runningTimerCount: runningTimerCount,
            todaysAlarmCount: todaysAlarmCount,
          ),
        );
  }

  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => module.screen),
  );
}
