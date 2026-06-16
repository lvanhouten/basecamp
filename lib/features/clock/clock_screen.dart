import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/widgets/app_drawer.dart';
import 'clock_tab.dart';

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

    // Resume-time recompute scaffold (ADR-0004). No tool state exists yet, so
    // this is a deliberate no-op the later panes (03/04/07) hang behavior on —
    // e.g. recomputing live counts / re-deriving the entry tab when the app
    // returns from background. Wired now so the hook point is stable.
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

  /// No-op scaffold. Later briefs recompute live tool state here on resume.
  void _onResume() {}

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
        children: const [
          // Placeholder panes — replaced by later briefs (08 alarms, 05 timer,
          // 03 stopwatch). Each later pane drops in here for its tab.
          _Placeholder(label: 'No alarms set'),
          _Placeholder(label: 'Set a countdown'),
          _Placeholder(label: '00:00.00'),
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
