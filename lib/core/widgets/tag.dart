import 'package:flutter/material.dart';

import '../tokens.dart';

/// A small pill chip with a [label] and an optional leading [icon] — the design
/// system's `Tag`, for filters, labels, and selected tokens.
///
/// Optionally dismissible: when [onRemove] is supplied a trailing × button is
/// shown that fires it.
class Tag extends StatelessWidget {
  const Tag({
    super.key,
    required this.label,
    this.icon,
    this.onRemove,
  });

  /// The chip's text.
  final String label;

  /// Optional leading icon.
  final IconData? icon;

  /// When supplied, renders a trailing × button that fires this on tap.
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tokens = theme.extension<BasecampTokens>()!;

    return Container(
      padding: EdgeInsets.fromLTRB(
        tokens.spacing.s4, // left ~12
        tokens.spacing.s2 + 2, // ~6
        onRemove != null ? tokens.spacing.s2 : tokens.spacing.s4,
        tokens.spacing.s2 + 2,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(tokens.radii.full),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: scheme.onSurfaceVariant),
            SizedBox(width: tokens.spacing.s3),
          ],
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: scheme.onSurface,
            ),
          ),
          if (onRemove != null) ...[
            SizedBox(width: tokens.spacing.s2),
            InkResponse(
              onTap: onRemove,
              radius: 16,
              child: Icon(
                Icons.close,
                size: 16,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
