import 'package:flutter/material.dart';

import '../tokens.dart';

/// The workhorse content row — a leading slot (icon tile or avatar), a [title],
/// an optional [subtitle], an optional [trailing] slot (badge / chevron / time),
/// and optional [onTap] handling. The design system's `ListItem`.
///
/// With [onTap] the whole row becomes tappable (with a hover/press ink); without
/// it the row is static. [done] strikes through the title for completed items.
///
/// Use [BcListGroup] to render several rows separated by a single hairline
/// rather than each being boxed.
class BcListItem extends StatelessWidget {
  const BcListItem({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.done = false,
  });

  /// Leading node — an icon (typically in a tinted tile) or an avatar.
  final Widget? leading;

  /// Primary text.
  final String title;

  /// Optional secondary text below the title.
  final String? subtitle;

  /// Optional trailing node — chevron, badge, time, switch, etc.
  final Widget? trailing;

  /// When set, the row becomes tappable.
  final VoidCallback? onTap;

  /// Strike-through completed style on the title.
  final bool done;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tokens = theme.extension<BasecampTokens>()!;

    final titleStyle = theme.textTheme.titleSmall?.copyWith(
      color: done ? scheme.onSurfaceVariant : scheme.onSurface,
      decoration: done ? TextDecoration.lineThrough : null,
    );

    final row = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.s5,
        vertical: tokens.spacing.s4,
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            SizedBox(width: tokens.spacing.s5),
          ],
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: titleStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  SizedBox(height: tokens.spacing.s1),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: tokens.spacing.s4),
            DefaultTextStyle.merge(
              style: TextStyle(color: scheme.onSurfaceVariant),
              child: IconTheme.merge(
                data: IconThemeData(color: scheme.onSurfaceVariant),
                child: trailing!,
              ),
            ),
          ],
        ],
      ),
    );

    if (onTap == null) return row;

    return InkWell(
      onTap: onTap,
      child: row,
    );
  }
}

/// A convenience leading tile: an [icon] centred in a module-tinted rounded
/// square, matching the design system's `ListItem` leading slot.
class BcListItemIcon extends StatelessWidget {
  const BcListItemIcon(this.icon, {super.key});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tokens = theme.extension<BasecampTokens>()!;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: tokens.moduleTint,
        borderRadius: BorderRadius.circular(tokens.radii.md),
      ),
      child: Icon(icon, size: 20, color: scheme.primary),
    );
  }
}

/// Renders a list of [BcListItem]s as a grouped block: a single soft-radius
/// surface where rows are separated by exactly one hairline divider (no divider
/// before the first or after the last row), rather than each row being boxed.
class BcListGroup extends StatelessWidget {
  const BcListGroup({super.key, required this.children});

  final List<BcListItem> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tokens = theme.extension<BasecampTokens>()!;

    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        rows.add(
          Divider(
            height: 1,
            thickness: 1,
            color: scheme.outlineVariant,
            // Indent to align with the title, past the leading tile + gap.
            indent: tokens.spacing.s5,
            endIndent: 0,
          ),
        );
      }
      rows.add(children[i]);
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(tokens.radii.lg),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: rows,
      ),
    );
  }
}
