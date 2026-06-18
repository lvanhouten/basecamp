import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_module.dart';
import '../../core/module_navigation.dart';
import '../../core/providers.dart';

/// **Modules** — the launcher bar destination that indexes every [AppModule] as
/// a launcher grid; tapping a tile pushes that module's screen over the shell
/// (ADR-0005 / CONTEXT.md). Modules is a destination, not itself a Module.
///
/// This is a **minimal placeholder**: brief `06-modules-screen` replaces it with
/// the real styled grid (and the "add a module" affordances). It is kept
/// functional — real tiles that push via [pushModule] — so the push/back
/// navigation is verifiable now (the acceptance criterion). A bar-destination
/// body (no Scaffold chrome): the launcher shell owns the Scaffold.
class ModulesScreen extends ConsumerWidget {
  const ModulesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keep the Clock count read-models warm so `pushModule`'s entry-precedence
    // (ADR-0004: Stopwatch > Timer > Alarms) has live, settled values to read
    // when a tile is tapped — landing must be derived from current Drift state,
    // not fall back to the resting default just because a stream hadn't emitted
    // yet. (Brief 06 surfaces these as Resume counts on the tiles themselves.)
    ref.watch(stopwatchRunningProvider);
    ref.watch(runningTimerCountProvider);
    ref.watch(todaysAlarmCountProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final m in AppModule.values)
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(m.icon),
              title: Text(m.label),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => pushModule(context, ref, m),
            ),
          ),
      ],
    );
  }
}
