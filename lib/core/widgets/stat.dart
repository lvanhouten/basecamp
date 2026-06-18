import 'package:flutter/material.dart';

import '../theme.dart';
import '../tokens.dart';

/// A large tabular-numeric readout with an optional [unit] and an uppercase
/// caption [label] — the design system's `Stat` block for dashboard insights
/// (steps, streaks, totals).
///
/// The value renders with tabular figures via [numericTextStyle]; the unit is a
/// small de-emphasised suffix and the label is an uppercase caption below.
class Stat extends StatelessWidget {
  const Stat({
    super.key,
    required this.value,
    this.unit,
    this.label,
  });

  /// The number / readout, rendered in tabular figures.
  final String value;

  /// Optional small unit suffix (e.g. "kg", "min", "day").
  final String? unit;

  /// Optional uppercase caption below the value.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tokens = theme.extension<BasecampTokens>()!;

    final valueStyle = numericTextStyle(
      fontSize: 30,
      fontWeight: FontWeight.w700,
      color: scheme.onSurface,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: value,
            style: valueStyle,
            children: unit == null
                ? null
                : [
                    TextSpan(
                      text: ' $unit',
                      style: numericTextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
          ),
        ),
        if (label != null) ...[
          SizedBox(height: tokens.spacing.s1),
          Text(
            label!.toUpperCase(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ],
    );
  }
}
