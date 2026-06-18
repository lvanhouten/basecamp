import 'package:flutter/material.dart';

/// Goals — a **stub module** (CONTEXT.md): a real Modules-grid tile that pushes
/// this placeholder, with no data layer yet (built as its own feature later).
/// As a pushed route it gets a back arrow automatically; no drawer (ADR-0005).
class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.adjust, size: 64, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text('Goals', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Coming soon.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.outline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
