import 'package:flutter/material.dart';

import '../tokens.dart';

/// A single option in a [SegmentedControl].
class SegmentOption<T> {
  const SegmentOption({required this.value, required this.label});

  final T value;
  final String label;
}

/// A pill-track single-select control for 2–4 short, mutually-exclusive options
/// — the design system's `SegmentedControl` (e.g. the Clock module's
/// Timer / Stopwatch / Alarm switch, or a list filter).
///
/// Built bespoke rather than via Material's `SegmentedButton` so the selected
/// segment reads as a raised brand-accented pill on a sunken track, per the
/// design system spec. The selected segment adopts the brand accent; tapping a
/// segment fires [onChanged] with that segment's value.
class SegmentedControl<T> extends StatelessWidget {
  const SegmentedControl({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  /// The selectable options (2+).
  final List<SegmentOption<T>> options;

  /// The currently selected value.
  final T value;

  /// Called with the newly selected value when a segment is tapped.
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tokens = theme.extension<BasecampTokens>()!;

    return Container(
      padding: EdgeInsets.all(tokens.spacing.s1 + 1), // ~3px track padding
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(tokens.radii.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final option in options)
            _Segment<T>(
              option: option,
              selected: option.value == value,
              onTap: () => onChanged(option.value),
              scheme: scheme,
              tokens: tokens,
              textStyle: theme.textTheme.labelLarge,
            ),
        ],
      ),
    );
  }
}

class _Segment<T> extends StatelessWidget {
  const _Segment({
    required this.option,
    required this.selected,
    required this.onTap,
    required this.scheme,
    required this.tokens,
    required this.textStyle,
  });

  final SegmentOption<T> option;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme scheme;
  final BasecampTokens tokens;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    // Selected segment adopts the brand accent (raised pill); unselected is a
    // transparent tap target with secondary-coloured text.
    return AnimatedContainer(
      duration: tokens.motion.fast,
      curve: tokens.motion.standard,
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.s5,
        vertical: tokens.spacing.s2 + 3, // ~7px
      ),
      decoration: BoxDecoration(
        color: selected ? scheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(tokens.radii.full),
        boxShadow: selected ? tokens.shadows.sm : null,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.radii.full),
        child: Text(
          option.label,
          style: textStyle?.copyWith(
            color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
