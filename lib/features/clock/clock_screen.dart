import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/widgets/app_drawer.dart';
import 'clock_tab.dart';
import 'stopwatch_pane.dart';
import 'timer_pane.dart';

/// Clock — time tools grouped under one module: Alarms, a countdown Timer, and
/// a Stopwatch, presented as three tabs. Carries the hub navigation drawer (the
/// established module-screen shape).
///
/// The active tab is shared hub state ([selectedClockTabProvider]): the Brief
/// card writes it via the `entryTab` precedence on tap, and a manual switch here
/// writes it back. Because the module is kept alive in the hub IndexedStack,
/// that choice persists for the session — drawer-hop away and back lands on the
/// same tab (ADR-0004).
///
/// A [ConsumerStatefulWidget] rather than a bare ConsumerWidget because it owns
/// a [TabController] and the resume-time [AppLifecycleListener] — both need
/// State lifecycle. The resting default tab is Alarms.
class ClockScreen extends ConsumerStatefulWidget {
  const ClockScreen({super.key});

  @override
  ConsumerState<ClockScreen> createState() => _ClockScreenState();
}

class _ClockScreenState extends ConsumerState<ClockScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  late final AppLifecycleListener _lifecycle;

  /// Lets the resume hook re-sync the Stopwatch pane's display ticker to the
  /// wall clock (it kept persisted-timestamp truth across background, but its
  /// in-memory `_now` froze while the process was paused).
  final _stopwatchKey = GlobalKey<StopwatchPaneState>();

  /// Lets the resume hook re-sync the Timer pane's display ticker to the wall
  /// clock — same rationale as the stopwatch key. Remaining truth lives in each
  /// timer's persisted `endsAt`, so this only snaps the displayed countdown the
  /// instant the app returns (before the next ticker frame), not the data.
  final _timerKey = GlobalKey<TimerPaneState>();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(
      length: ClockTab.values.length,
      vsync: this,
      // Seed from the shared tab state so an entry tab chosen on the Brief
      // (before this screen mounts) is honored on first build.
      initialIndex: ref.read(selectedClockTabProvider).index,
    )..addListener(_onTabChanged);

    // Resume-time recompute hook (ADR-0004): the Stopwatch pane kept its
    // persisted-timestamp truth across background, but its in-memory display
    // clock froze while the process was paused — re-sync it to the wall clock
    // on return so the readout jumps straight to the correct elapsed. Later
    // panes (07 alarms) can hang their own resume recompute here too.
    _lifecycle = AppLifecycleListener(onResume: _onResume);
  }

  /// Persist a manual tab switch (tap or swipe) into the shared tab state.
  /// `indexIsChanging` filters the mid-animation callbacks so we write once.
  void _onTabChanged() {
    if (_tabs.indexIsChanging) return;
    final tab = ClockTab.values[_tabs.index];
    if (ref.read(selectedClockTabProvider) != tab) {
      ref.read(selectedClockTabProvider.notifier).select(tab);
    }
  }

  /// On resume, re-sync the Stopwatch display ticker to the wall clock. The
  /// persisted record is unchanged (timestamps, not ticking state); this only
  /// snaps the displayed value so it doesn't briefly show the stale pre-pause
  /// elapsed before the next ticker frame.
  void _onResume() {
    _stopwatchKey.currentState?.resync();
    _timerKey.currentState?.resync();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _tabs.removeListener(_onTabChanged);
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // When the Brief card (or any external write) changes the entry tab while
    // this screen is alive in the IndexedStack, move the controller to match.
    ref.listen<ClockTab>(selectedClockTabProvider, (_, next) {
      if (_tabs.index != next.index) {
        _tabs.animateTo(next.index);
      }
    });

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Clock'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Alarms', icon: Icon(Icons.alarm)),
            Tab(text: 'Timer', icon: Icon(Icons.hourglass_empty)),
            Tab(text: 'Stopwatch', icon: Icon(Icons.timer)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          // Index 0 (Alarms) is still a placeholder — replaced by 08.
          const _Placeholder(label: 'No alarms set'),
          // Index 1 (Timer) — the live countdown pane (05-timer-ui).
          TimerPane(key: _timerKey),
          // Index 2 (Stopwatch) — 03-stopwatch.
          StopwatchPane(key: _stopwatchKey),
        ],
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(label, style: Theme.of(context).textTheme.headlineSmall),
    );
  }
}
