import 'package:flutter/material.dart';

/// Shared centered placeholder for the four launcher bar destinations (Brief /
/// Calendar / Activity / Modules) so the shell compiles and reads honestly
/// before the content briefs (05/06/07) replace each one with real content.
///
/// A plain body (no Scaffold/AppBar): the bar destinations are persistent tab
/// bodies hosted inside the launcher shell's single Scaffold, not pushed routes.
class BarDestinationPlaceholder extends StatelessWidget {
  const BarDestinationPlaceholder({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}
