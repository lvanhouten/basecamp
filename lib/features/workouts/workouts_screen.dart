import 'package:flutter/material.dart';

/// Workout log — the "Strong" replacement. Starts as a history feed; the real
/// build adds exercises, sets/reps/weight, and an active-session screen. A
/// pushed module route (ADR-0005): back arrow is automatic, no drawer.
class WorkoutsScreen extends StatelessWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Workouts')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.fitness_center,
                  size: 64, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text('No workouts yet', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Start a session to begin logging sets, reps, and weight.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.outline),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.play_arrow),
        label: const Text('Start workout'),
      ),
    );
  }
}
