import 'package:flutter/material.dart';

import '../features/clock/clock_screen.dart';
import '../features/home/home_screen.dart';
import '../features/lists/lists_screen.dart';
import '../features/workouts/workouts_screen.dart';

/// The hub's navigation destinations — the single source of truth for both the
/// drawer and the [IndexedStack] in `home_shell.dart`. Adding a module is one
/// entry here plus its screen; the shell and drawer pick it up automatically.
enum AppModule {
  brief(
    label: 'Brief',
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard,
  ),
  lists(
    label: 'Lists',
    icon: Icons.checklist_outlined,
    selectedIcon: Icons.checklist,
  ),
  workouts(
    label: 'Workouts',
    icon: Icons.fitness_center_outlined,
    selectedIcon: Icons.fitness_center,
  ),
  clock(
    label: 'Clock',
    icon: Icons.schedule_outlined,
    selectedIcon: Icons.schedule,
  );

  const AppModule({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;

  /// The screen for this module. Const so the [IndexedStack] keeps every module
  /// alive at once — a drawer-hop away and back lands you where you were.
  Widget get screen => switch (this) {
        AppModule.brief => const HomeScreen(),
        AppModule.lists => const ListsScreen(),
        AppModule.workouts => const WorkoutsScreen(),
        AppModule.clock => const ClockScreen(),
      };
}
