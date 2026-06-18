import 'package:flutter/material.dart';

import '../tokens.dart';

/// Semantic tone for [BcBadge].
///
/// `success` and `warning` map to the design system's green / amber status
/// colours, which Material's [ColorScheme] has no role for; `danger` maps to the
/// error role, `brand` to primary, and `module` to the (currently brand-unified)
/// module accent tint.
enum BadgeTone { neutral, brand, module, success, warning, danger }

/// A pill label with a semantic [tone] and an optional leading status [dot] —
/// the design system's `Badge`. Use for status, counts, or short labels.
///
/// Named `BcBadge` to avoid colliding with Material's `Badge`.
class BcBadge extends StatelessWidget {
  const BcBadge({
    super.key,
    required this.label,
    this.tone = BadgeTone.neutral,
    this.dot = false,
  });

  /// The pill's text.
  final String label;

  /// The semantic colour tone.
  final BadgeTone tone;

  /// When true, renders a leading status dot in the tone's foreground colour.
  final bool dot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<BasecampTokens>()!;
    final colors = _resolve(theme, tokens, tone);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.s3 + 1, // ~9px per spec
        vertical: tokens.spacing.s1 + 1, // ~3px per spec
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(tokens.radii.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: colors.foreground,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: tokens.spacing.s2),
          ],
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colors.foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  static _BadgeColors _resolve(
    ThemeData theme,
    BasecampTokens tokens,
    BadgeTone tone,
  ) {
    final scheme = theme.colorScheme;
    switch (tone) {
      case BadgeTone.neutral:
        return _BadgeColors(
          background: scheme.surfaceContainer,
          foreground: scheme.onSurfaceVariant,
        );
      case BadgeTone.brand:
        return _BadgeColors(
          background: scheme.primaryContainer,
          foreground: scheme.secondary, // brand-hover (coral-600)
        );
      case BadgeTone.module:
        // Module accent is brand-unified (dormant); tint + brand foreground.
        return _BadgeColors(
          background: tokens.moduleTint,
          foreground: scheme.secondary,
        );
      case BadgeTone.success:
        return _BadgeColors(
          background: _kSuccessTint,
          foreground: _kSuccessInk,
        );
      case BadgeTone.warning:
        return _BadgeColors(
          background: _kWarningTint,
          foreground: _kWarningInk,
        );
      case BadgeTone.danger:
        return _BadgeColors(
          background: scheme.errorContainer,
          foreground: scheme.onErrorContainer,
        );
    }
  }
}

class _BadgeColors {
  const _BadgeColors({required this.background, required this.foreground});
  final Color background;
  final Color foreground;
}

// Design-system status colours that Material's ColorScheme has no role for and
// that 01-theming-foundation did not surface as tokens. Transcribed verbatim
// from `_docs/design-system/project/tokens/colors.css`:
//   --success-tint = --green-50 (#E7F6EF); --green-700 = #167F54
//   --warning-tint = --amber-50 (#FEF2DA); --amber-700 = #B5760C
const Color _kSuccessTint = Color(0xFFE7F6EF);
const Color _kSuccessInk = Color(0xFF167F54);
const Color _kWarningTint = Color(0xFFFEF2DA);
const Color _kWarningInk = Color(0xFFB5760C);
