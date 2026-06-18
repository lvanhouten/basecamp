import 'package:flutter/material.dart';

import '../tokens.dart';

/// A single destination in a [LauncherTabBar].
class LauncherTabItem<T> {
  const LauncherTabItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  /// The value this destination carries; compared against [LauncherTabBar.value]
  /// to decide the selected state, and passed to `onChange` when tapped.
  final T value;

  /// Short caption shown beneath the icon.
  final String label;

  /// The destination's glyph.
  final IconData icon;
}

/// The raised center action of a [LauncherTabBar] — the "Quick add" (⊕) FAB.
///
/// It is an **action, never a selectable destination**: tapping it fires
/// [onClick] and it never carries the selected state, regardless of the bar's
/// `value` (see ADR-0005 / CONTEXT.md "Quick add").
class LauncherCenterAction {
  const LauncherCenterAction({
    required this.icon,
    required this.label,
    required this.onClick,
  });

  /// The FAB's glyph (e.g. a plus).
  final IconData icon;

  /// Accessible label for the action (also the tooltip).
  final String label;

  /// Fired when the FAB is tapped. The bar never mutates selection for this.
  final VoidCallback onClick;
}

/// The launcher bottom bar — the app shell's primary navigation, matching the
/// design system's `TabBar` (`_docs/design-system/project/components/navigation/`).
///
/// Renders a fixed row of [items] (each a [LauncherTabItem]: value/label/icon).
/// It is **controlled**: [value] marks the selected destination and [onChange]
/// fires with a destination's value on tap. The selected item adopts the brand
/// accent (`colorScheme.primary`); unselected items use the tertiary text colour
/// (`colorScheme.onSurfaceVariant`).
///
/// With a [centerAction] the items split at their midpoint — `ceil(n/2)` on the
/// left, the rest on the right — with the raised center FAB between, so an even
/// count sits symmetrically around it (4 → 2 left / 2 right). The FAB is an
/// action, not a destination: it fires its own callback and never renders as
/// selected even if its conceptual value collides with [value].
///
/// Without a [centerAction] it degrades to a plain N-tab bar (no FAB).
///
/// Colours, radii, shadows and type come from the theme — nothing is hardcoded.
class LauncherTabBar<T> extends StatelessWidget {
  const LauncherTabBar({
    super.key,
    required this.items,
    required this.value,
    required this.onChange,
    this.centerAction,
  });

  /// The destinations, rendered left-to-right (split around the FAB if a
  /// [centerAction] is present).
  final List<LauncherTabItem<T>> items;

  /// The currently selected destination's value.
  final T value;

  /// Fired with a destination's value when that destination is tapped.
  final ValueChanged<T> onChange;

  /// The optional raised center action (Quick add). When null the bar is a
  /// plain N-tab bar.
  final LauncherCenterAction? centerAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tokens = theme.extension<BasecampTokens>()!;

    // Midpoint split, identical to the design-system component: ceil(n/2) left,
    // the rest right, FAB between. Without a centerAction everything is "left".
    final mid = (items.length / 2).ceil();
    final left = centerAction != null ? items.sublist(0, mid) : items;
    final right = centerAction != null ? items.sublist(mid) : const [];

    Widget tab(LauncherTabItem<T> item) => _LauncherTab<T>(
          item: item,
          selected: item.value == value,
          onTap: () => onChange(item.value),
          scheme: scheme,
          tokens: tokens,
          labelStyle: theme.textTheme.labelSmall,
        );

    return SafeArea(
      top: false,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          border: Border(top: BorderSide(color: scheme.outlineVariant)),
        ),
        child: Padding(
          padding: EdgeInsets.all(tokens.spacing.s3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (final item in left) Expanded(child: tab(item)),
              if (centerAction != null)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: tokens.spacing.s4),
                  child: _CenterFab(
                    action: centerAction!,
                    scheme: scheme,
                    tokens: tokens,
                  ),
                ),
              for (final item in right) Expanded(child: tab(item)),
            ],
          ),
        ),
      ),
    );
  }
}

/// One destination cell: stacked icon + caption, brand-accented when selected.
class _LauncherTab<T> extends StatelessWidget {
  const _LauncherTab({
    required this.item,
    required this.selected,
    required this.onTap,
    required this.scheme,
    required this.tokens,
    required this.labelStyle,
  });

  final LauncherTabItem<T> item;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme scheme;
  final BasecampTokens tokens;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    // Selected adopts the brand accent; unselected uses the tertiary/secondary
    // text colour. Both share one colour so icon + label stay in sync.
    final color = selected ? scheme.primary : scheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.radii.md),
        child: ConstrainedBox(
          // Touch target meets the minimum tap size.
          constraints: BoxConstraints(minHeight: tokens.spacing.tapMin),
          child: AnimatedDefaultTextStyle(
            duration: tokens.motion.fast,
            curve: tokens.motion.standard,
            style: (labelStyle ?? const TextStyle()).copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, size: 24, color: color),
                SizedBox(height: tokens.spacing.s1),
                Text(item.label),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The raised brand FAB between the split items. An action, never selectable.
class _CenterFab extends StatelessWidget {
  const _CenterFab({
    required this.action,
    required this.scheme,
    required this.tokens,
  });

  final LauncherCenterAction action;
  final ColorScheme scheme;
  final BasecampTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      // Explicitly NOT selected — the FAB never carries selection state.
      selected: false,
      label: action.label,
      child: Tooltip(
        message: action.label,
        child: Material(
          color: scheme.primary,
          shape: const CircleBorder(),
          // Coral-tinted lift, sourced from the token shadow scale.
          elevation: 0,
          child: Ink(
            decoration: BoxDecoration(
              color: scheme.primary,
              shape: BoxShape.circle,
              boxShadow: tokens.shadows.lg,
            ),
            child: InkWell(
              onTap: action.onClick,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: 58,
                height: 58,
                child: Icon(action.icon, size: 28, color: scheme.onPrimary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
