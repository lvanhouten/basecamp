import 'package:flutter/material.dart';

import '../features/clock/clock_screen.dart';
import '../features/goals/goals_screen.dart';
import '../features/journal/journal_screen.dart';
import '../features/lists/lists_screen.dart';
import '../features/workouts/workouts_screen.dart';

/// The grid **modules** — the single source of truth for the Modules
/// destination's launcher grid and the push-target type (ADR-0005). Each member
/// is a self-contained feature area opened as a pushed view from the Modules
/// grid (and Brief affordances), returning via a back arrow.
///
/// This no longer enumerates the bottom-bar destinations: the bar is a fixed,
/// separate set (Brief / Calendar / Activity / Modules — see [home_shell.dart]),
/// and the **Brief is a bar destination, not a module**, so it is absent here.
/// Adding a module is one entry here plus its screen; the Modules grid picks it
/// up automatically and the bar never grows.
enum AppModule {
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
  ),
  goals(
    label: 'Goals',
    icon: Icons.adjust_outlined,
    selectedIcon: Icons.adjust,
  ),
  journal(
    label: 'Journal',
    icon: Icons.book_outlined,
    selectedIcon: Icons.book,
  );

  const AppModule({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;

  /// The screen for this module, built fresh each time it is pushed. Unlike the
  /// retired IndexedStack-peers model (ADR-0001), modules are no longer kept
  /// alive: where you land on entry is derived from persisted Drift state, not
  /// from a remembered route (ADR-0005). Clock's entry tab is computed on push
  /// in `home_shell.dart` before this screen mounts.
  Widget get screen => switch (this) {
        AppModule.lists => const ListsScreen(),
        AppModule.workouts => const WorkoutsScreen(),
        AppModule.clock => const ClockScreen(),
        AppModule.goals => const GoalsScreen(),
        AppModule.journal => const JournalScreen(),
      };
}
