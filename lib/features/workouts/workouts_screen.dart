import 'package:flutter/material.dart';

import '../../core/widgets/stub_module_body.dart';

/// Workout log — the "Strong" replacement. A **stub module** today
/// (CONTEXT.md): a real Modules-grid tile that pushes this placeholder, with no
/// data layer yet. The real build adds exercises, sets/reps/weight, and an
/// active-session screen. As a pushed route it gets a back arrow automatically;
/// no drawer (ADR-0005).
class WorkoutsScreen extends StatelessWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workouts')),
      body: const StubModuleBody(
        icon: Icons.fitness_center_outlined,
        name: 'Workouts',
      ),
    );
  }
}
