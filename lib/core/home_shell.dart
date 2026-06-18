import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/activity/activity_screen.dart';
import '../features/calendar/calendar_screen.dart';
import '../features/home/home_screen.dart';
import '../features/modules/modules_screen.dart';
import 'bar_destination.dart';
import 'providers.dart';
import 'widgets/components.dart';

/// The launcher shell (ADR-0005, superseding ADR-0001's drawer + module-peers
/// IndexedStack). A [Scaffold] whose [Scaffold.bottomNavigationBar] is the
/// design-system [LauncherTabBar] — four fixed destinations split 2/2 around a
/// raised center **⊕ Quick add** FAB — and whose body is the selected
/// destination.
///
/// The four bar destinations remain a lightweight [IndexedStack] (they are
/// persistent, cheap tabs that should not unmount when you switch among them).
/// What ADR-0005 retires is keeping the heavy **module** screens alive as peers:
/// modules are now pushed views (see `module_navigation.dart`), launched from
/// the Modules grid, returning via a back arrow — never bar destinations.
///
/// The ⊕ FAB is a **no-op / "coming soon"** here (quick-capture is deferred); it
/// is an action, never a selected destination, so the bar never renders it as
/// selected. There is no navigation drawer anywhere.
class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedBarProvider);

    return Scaffold(
      body: IndexedStack(
        index: selected.index,
        children: const [
          HomeScreen(), // Brief
          CalendarScreen(),
          ActivityScreen(),
          ModulesScreen(),
        ],
      ),
      bottomNavigationBar: LauncherTabBar<BarDestination>(
        value: selected,
        onChange: (d) => ref.read(selectedBarProvider.notifier).select(d),
        items: [
          for (final d in BarDestination.values)
            LauncherTabItem(value: d, label: d.label, icon: d.icon),
        ],
        centerAction: LauncherCenterAction(
          icon: Icons.add,
          label: 'Quick add',
          // Deferred (ADR-0005): button only, capture sheet not built. A gentle
          // "coming soon" acknowledgement — never mutates the selected tab.
          onClick: () {
            final messenger = ScaffoldMessenger.maybeOf(context);
            messenger
              ?..clearSnackBars()
              ..showSnackBar(
                const SnackBar(content: Text('Quick add — coming soon')),
              );
          },
        ),
      ),
    );
  }
}
