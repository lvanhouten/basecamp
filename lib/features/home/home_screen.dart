import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_module.dart';
import '../../core/providers.dart';
import '../../core/widgets/app_drawer.dart';
import '../clock/clock_tab.dart';

/// The daily Brief — the hub's home and launcher. Summarizes each module and
/// taps through to it (same destination as the drawer). The Lists card is LIVE
/// via the `ListsApi` contract; Workouts/Clock are placeholders until those
/// modules land (then they'll surface any in-progress activity to Resume).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final theme = Theme.of(context);

    final listCount = ref.watch(listCountProvider).asData?.value;
    final openItems = ref.watch(openItemCountProvider).asData?.value;

    // Clock summarizes as three counts, not a single Resume banner (ADR-0004).
    final alarmsToday = ref.watch(todaysAlarmCountProvider).asData?.value;
    final timersRunning = ref.watch(runningTimerCountProvider).asData?.value;
    final stopwatchRunning = ref.watch(stopwatchRunningProvider).asData?.value;

    void go(AppModule m) =>
        ref.read(selectedModuleProvider.notifier).select(m);

    /// Open Clock to the precedence-selected tab (ADR-0004): a running
    /// Stopwatch wins, else a running Timer, else Alarms.
    void goClock() {
      ref.read(selectedClockTabProvider.notifier).select(
            entryTab(
              stopwatchRunning: stopwatchRunning ?? false,
              runningTimerCount: timersRunning ?? 0,
              todaysAlarmCount: alarmsToday ?? 0,
            ),
          );
      go(AppModule.clock);
    }

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Basecamp')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        children: [
          Text(_greeting(now.hour), style: theme.textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(
            _formatDate(now),
            style: theme.textTheme.titleMedium
                ?.copyWith(color: theme.colorScheme.outline),
          ),
          const SizedBox(height: 24),
          _BriefCard(
            icon: Icons.checklist,
            title: 'Lists',
            line: _listsLine(listCount, openItems),
            onTap: () => go(AppModule.lists),
          ),
          _BriefCard(
            icon: Icons.fitness_center,
            title: 'Workouts',
            line: 'Last: Push day · 2 days ago',
            onTap: () => go(AppModule.workouts),
          ),
          _BriefCard(
            icon: Icons.schedule,
            title: 'Clock',
            line: _clockLine(alarmsToday, timersRunning, stopwatchRunning),
            onTap: goClock,
          ),
        ],
      ),
    );
  }

  String _listsLine(int? lists, int? open) {
    if (lists == null || open == null) return 'Loading…';
    final l = lists == 1 ? '1 list' : '$lists lists';
    final o = open == 1 ? '1 open item' : '$open open items';
    return '$l · $o';
  }

  /// The Clock summary phrase (ADR-0004): three counts, each phrased for what it
  /// is — no uniform "Active N" label. Alarms are a future-state summary line so
  /// they always show ("Enabled" is the alarm term; "active" is avoided per the
  /// glossary); a running Timer/Stopwatch only appears when actually live, so
  /// the all-placeholder state reads naturally as just "No alarms today".
  String _clockLine(int? alarms, int? timers, bool? stopwatch) {
    if (alarms == null || timers == null || stopwatch == null) return 'Loading…';

    final segments = <String>[
      switch (alarms) {
        0 => 'No alarms today',
        1 => '1 alarm today',
        _ => '$alarms alarms today',
      },
      if (timers == 1) '1 timer running',
      if (timers > 1) '$timers timers running',
      if (stopwatch) 'stopwatch running',
    ];
    return segments.join(' · ');
  }

  String _greeting(int hour) {
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  String _formatDate(DateTime d) {
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June', 'July',
      'August', 'September', 'October', 'November', 'December',
    ];
    return '${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}';
  }
}

class _BriefCard extends StatelessWidget {
  const _BriefCard({
    required this.icon,
    required this.title,
    required this.line,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String line;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          foregroundColor: theme.colorScheme.onPrimaryContainer,
          child: Icon(icon),
        ),
        title: Text(title, style: theme.textTheme.titleMedium),
        subtitle: Text(line),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
