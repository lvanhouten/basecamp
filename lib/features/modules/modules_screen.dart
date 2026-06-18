import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_module.dart';
import '../../core/module_navigation.dart';
import '../../core/providers.dart';
import '../../core/tokens.dart';

/// **Modules** — the launcher bar destination that indexes every [AppModule] as
/// a styled launcher grid; tapping a tile pushes that module's screen over the
/// shell (ADR-0005 / CONTEXT.md). Modules is a destination, not itself a Module.
///
/// Brief `06-modules-screen` fills this in as the real grid: a **"Your modules"**
/// section with a raised-card tile per module carrying a live summary meta line
/// (reusing the existing read models — never redefined), plus a generic
/// **"Add a module"** coming-soon affordance (no real add flow). A bar-destination
/// body (no Scaffold chrome): the launcher shell owns the Scaffold (so the
/// coming-soon snackbar goes to the shell's `ScaffoldMessenger`).
class ModulesScreen extends ConsumerWidget {
  const ModulesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = theme.extension<BasecampTokens>()!;

    // Keep the Clock count read-models warm so `pushModule`'s entry-precedence
    // (ADR-0004: Stopwatch > Timer > Alarms) has live, settled values to read
    // when a tile is tapped — landing must be derived from current Drift state,
    // not fall back to the resting default (Alarms) just because a stream hadn't
    // emitted yet (handoff 04). These same async values also feed the Clock
    // tile's summary meta below.
    final stopwatchRunning =
        ref.watch(stopwatchRunningProvider).asData?.value ?? false;
    final runningTimerCount =
        ref.watch(runningTimerCountProvider).asData?.value ?? 0;
    final todaysAlarmCount =
        ref.watch(todaysAlarmCountProvider).asData?.value ?? 0;

    // Lists summary read models (the lists contract) — reused from where the
    // Brief sourced them, not redefined.
    final listCount = ref.watch(listCountProvider).asData?.value ?? 0;
    final openItemCount = ref.watch(openItemCountProvider).asData?.value ?? 0;

    String metaFor(AppModule m) => switch (m) {
          AppModule.lists => _listsMeta(listCount, openItemCount),
          AppModule.clock => _clockMeta(
              stopwatchRunning: stopwatchRunning,
              runningTimerCount: runningTimerCount,
              todaysAlarmCount: todaysAlarmCount,
            ),
          // Workouts / Goals / Journal have no data layer yet — a quiet meta.
          AppModule.workouts ||
          AppModule.goals ||
          AppModule.journal =>
            'No activity yet',
        };

    // A SingleChildScrollView + Column (not a lazy ListView): every tile is laid
    // out at once, so all five are present and hit-testable regardless of
    // viewport height — the compact row tiles keep the whole grid within a phone
    // fold, and off-screen lazy children (which a ListView would skip) can't hide
    // a module tile from the launcher.
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        tokens.spacing.gutter,
        tokens.spacing.s6,
        tokens.spacing.gutter,
        tokens.spacing.s8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Modules', style: theme.textTheme.displaySmall),
          SizedBox(height: tokens.spacing.s7),
          const _SectionLabel('Your modules'),
          SizedBox(height: tokens.spacing.s4),
          for (final m in AppModule.values) ...[
            _ModuleTile(
              module: m,
              meta: metaFor(m),
              onOpen: () => pushModule(context, ref, m),
            ),
            SizedBox(height: tokens.spacing.s4),
          ],
          SizedBox(height: tokens.spacing.s4),
          const _SectionLabel('Add a module'),
          SizedBox(height: tokens.spacing.s4),
          _AddModuleTile(onTap: () => _showComingSoon(context)),
        ],
      ),
    );
  }

  static void _showComingSoon(BuildContext context) {
    // The shell owns the Scaffold (this is a bar-destination body), so the
    // acknowledgement goes to the shell's messenger. No real add flow exists.
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger
      ?..clearSnackBars()
      ..showSnackBar(
        const SnackBar(content: Text('Add a module — coming soon')),
      );
  }
}

/// Lists meta line, e.g. "3 lists · 12 open". Pluralised; "open" is dropped when
/// there are no open items (and "0 lists" still reads sensibly).
String _listsMeta(int listCount, int openItemCount) {
  final lists = '$listCount ${listCount == 1 ? 'list' : 'lists'}';
  if (openItemCount == 0) return lists;
  return '$lists · $openItemCount open';
}

/// Clock meta line summarising its three tools by entry-precedence emphasis
/// (Stopwatch > Timer > Alarms), the same counts the Brief surfaced. With
/// nothing in progress and no alarms enabled today it reads quietly.
String _clockMeta({
  required bool stopwatchRunning,
  required int runningTimerCount,
  required int todaysAlarmCount,
}) {
  final parts = <String>[
    if (stopwatchRunning) 'Stopwatch running',
    if (runningTimerCount > 0)
      '$runningTimerCount ${runningTimerCount == 1 ? 'timer' : 'timers'} running',
    if (todaysAlarmCount > 0) '$todaysAlarmCount today',
  ];
  if (parts.isEmpty) return 'No alarms today';
  return parts.join(' · ');
}

/// A small section label, matching the design system's `bc-section`.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      label,
      style: theme.textTheme.titleSmall?.copyWith(
        color: theme.colorScheme.onSurface,
      ),
    );
  }
}

/// A raised-card launcher tile in the design-system tile look: a module-tinted
/// leading icon tile, the module name + its summary meta line, and a trailing
/// chevron. Reads colours/radii/shadows from the theme; tapping pushes the
/// module. A compact single-row layout so the whole launcher fits a phone fold
/// (and the shell keeps every destination mounted without scrolling).
class _ModuleTile extends StatelessWidget {
  const _ModuleTile({
    required this.module,
    required this.meta,
    required this.onOpen,
  });

  final AppModule module;
  final String meta;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tokens = theme.extension<BasecampTokens>()!;

    return Card(
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(tokens.radii.lg),
        child: Padding(
          padding: EdgeInsets.all(tokens.spacing.s4),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: tokens.moduleTint,
                  borderRadius: BorderRadius.circular(tokens.radii.md),
                ),
                child: Icon(module.icon, size: 20, color: scheme.primary),
              ),
              SizedBox(width: tokens.spacing.s5),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(module.label, style: theme.textTheme.titleSmall),
                    SizedBox(height: tokens.spacing.s1),
                    Text(
                      meta,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: tokens.spacing.s4),
              Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

/// The "Add a module" affordance: a quiet bordered tile that shows a generic
/// coming-soon message and performs no real add (out of scope).
class _AddModuleTile extends StatelessWidget {
  const _AddModuleTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tokens = theme.extension<BasecampTokens>()!;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(tokens.radii.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.radii.lg),
        child: Container(
          padding: EdgeInsets.all(tokens.spacing.s5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(tokens.radii.lg),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(Icons.add, color: scheme.onSurfaceVariant),
              SizedBox(width: tokens.spacing.s4),
              Text(
                // Distinct from the "Add a module" section header above (a
                // duplicate string would make the affordance ambiguous to find
                // and read); the tile is the actionable "new module" entry.
                'New module',
                style: theme.textTheme.titleSmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
