import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import 'alarms_pane.dart';
import 'clock_tab.dart';
import 'stopwatch_pane.dart';
import 'timer_pane.dart';

/// Clock — time tools grouped under one module: Alarms, a countdown Timer, and
/// a Stopwatch, presented as three tabs. A **pushed module route** (ADR-0005):
/// the back arrow is automatic, there is no navigation drawer.
///
/// The active tab is shared state ([selectedClockTabProvider]): the entry tab is
/// computed from live Drift state on module ENTRY (the `pushModule` precedence
/// in `module_navigation.dart`, ADR-0004 — Stopwatch > Timer > Alarms) and
/// written before this screen mounts, so the TabController seeds from it. A
/// manual switch here writes it back, persisting within this pushed session.
/// (Correcting ADR-0001's "kept alive in the IndexedStack" note: modules are no
/// longer peers — landing is derived on entry, not remembered across a hop.)
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
    // If an external write changes the entry tab while this screen is alive,
    // move the controller to match (the entry tab is normally set on push,
    // before mount; this keeps a live-screen write in sync too).
    ref.listen<ClockTab>(selectedClockTabProvider, (_, next) {
      if (_tabs.index != next.index) {
        _tabs.animateTo(next.index);
      }
    });

    return Scaffold(
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
          // Index 0 (Alarms) — the alarms list + editor (08-alarm-ui). Alarms
          // are DB-streamed (alarmsProvider), so no resume-time recompute hook
          // is needed here (unlike the timer/stopwatch display tickers).
          const AlarmsPane(),
          // Index 1 (Timer) — the live countdown pane (05-timer-ui).
          TimerPane(key: _timerKey),
          // Index 2 (Stopwatch) — 03-stopwatch.
          StopwatchPane(key: _stopwatchKey),
        ],
      ),
    );
  }
}
