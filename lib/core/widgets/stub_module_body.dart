import 'package:flutter/material.dart';

import '../tokens.dart';
import 'bc_list_item.dart';

/// The centred body of a **stub module** screen (Goals / Journal) — a real
/// Modules-grid tile that pushes a placeholder with no data layer yet
/// (CONTEXT.md). A module-tinted leading [icon] tile (the design system's
/// `ListItem` leading style), the module [name], and one calm line in the brand
/// voice. Lives under the screen's own Scaffold + AppBar (a pushed route).
class StubModuleBody extends StatelessWidget {
  const StubModuleBody({
    super.key,
    required this.icon,
    required this.name,
    this.line = 'Coming soon.',
  });

  /// The module's icon (shown in a tinted rounded tile).
  final IconData icon;

  /// The module name (e.g. "Goals").
  final String name;

  /// The single calm line beneath the name.
  final String line;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tokens = theme.extension<BasecampTokens>()!;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.s8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BcListItemIcon(icon),
            SizedBox(height: tokens.spacing.s5),
            Text(name, style: theme.textTheme.titleLarge),
            SizedBox(height: tokens.spacing.s3),
            Text(
              line,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
