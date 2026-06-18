import 'package:flutter/material.dart';

/// The design-system token surface that Material has no semantic role for.
///
/// Material's [ColorScheme] / [TextTheme] / component themes cover the brand,
/// surfaces, text, borders, error, shapes and the like — those live in
/// `theme.dart`. Everything the design system defines that Material *can't*
/// express (the joy/sun accent, the navy-tinted shadow scale, the radii ramp,
/// the 4px spacing grid, motion durations/easings, and the dormant module tint)
/// is carried here and read via `Theme.of(context).extension<BasecampTokens>()`.
///
/// Widgets MUST read these from the theme rather than hardcoding — that's what
/// makes the light/dark swap and any future module theming free. See the token
/// files under `_docs/design-system/project/tokens/`.
@immutable
class BasecampTokens extends ThemeExtension<BasecampTokens> {
  const BasecampTokens({
    required this.joy,
    required this.joyTint,
    required this.joyInk,
    required this.moduleTint,
    required this.shadows,
    required this.radii,
    required this.spacing,
    required this.motion,
  });

  /// The sunshine-yellow joy accent — highlights, streaks, celebration
  /// (`--joy` / `--sun-500`). Distinct from the brand coral.
  final Color joy;

  /// Soft wash behind the joy accent (`--joy-tint`).
  final Color joyTint;

  /// Readable ink on a joy-tint surface (`--joy-ink` / `--sun-900`).
  final Color joyInk;

  /// The module accent tint. Brand-unified for now (coral tint) — the hook stays
  /// dormant; per-module accents are out of scope (`--module-tint`).
  final Color moduleTint;

  /// The 5-step navy-tinted soft shadow scale (`--shadow-xs`..`--shadow-xl`).
  final BasecampShadows shadows;

  /// The radii ramp (`--radius-xs`..`--radius-2xl` + full).
  final BasecampRadii radii;

  /// The 4px spacing grid + layout tokens (`--space-*`, `--gutter`, ...).
  final BasecampSpacing spacing;

  /// Motion durations + easing curves (`--dur-*`, `--ease-*`).
  final BasecampMotion motion;

  @override
  BasecampTokens copyWith({
    Color? joy,
    Color? joyTint,
    Color? joyInk,
    Color? moduleTint,
    BasecampShadows? shadows,
    BasecampRadii? radii,
    BasecampSpacing? spacing,
    BasecampMotion? motion,
  }) {
    return BasecampTokens(
      joy: joy ?? this.joy,
      joyTint: joyTint ?? this.joyTint,
      joyInk: joyInk ?? this.joyInk,
      moduleTint: moduleTint ?? this.moduleTint,
      shadows: shadows ?? this.shadows,
      radii: radii ?? this.radii,
      spacing: spacing ?? this.spacing,
      motion: motion ?? this.motion,
    );
  }

  @override
  BasecampTokens lerp(ThemeExtension<BasecampTokens>? other, double t) {
    if (other is! BasecampTokens) return this;
    return BasecampTokens(
      joy: Color.lerp(joy, other.joy, t)!,
      joyTint: Color.lerp(joyTint, other.joyTint, t)!,
      joyInk: Color.lerp(joyInk, other.joyInk, t)!,
      moduleTint: Color.lerp(moduleTint, other.moduleTint, t)!,
      shadows: shadows.lerp(other.shadows, t),
      radii: radii.lerp(other.radii, t),
      spacing: spacing, // a fixed grid — not animated
      motion: motion, // durations/curves don't lerp
    );
  }
}

/// The navy-tinted soft shadow scale (`shadows.css`). Each step is a list of
/// [BoxShadow] so cards/sheets can apply the design system's layered elevation
/// directly: `decoration: BoxDecoration(boxShadow: tokens.shadows.md)`.
@immutable
class BasecampShadows {
  const BasecampShadows({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
  });

  final List<BoxShadow> xs;
  final List<BoxShadow> sm;
  final List<BoxShadow> md;
  final List<BoxShadow> lg;
  final List<BoxShadow> xl;

  /// Light theme — `0 .. rgba(27,31,38,a)` navy-tinted shadows.
  factory BasecampShadows.light() {
    const ink = Color(0xFF1B1F26); // rgb(27, 31, 38)
    return BasecampShadows(
      xs: [_s(ink, 0.06, 0, 1, 2)],
      sm: [_s(ink, 0.07, 0, 1, 3), _s(ink, 0.05, 0, 1, 2)],
      md: [_s(ink, 0.08, 0, 4, 12), _s(ink, 0.05, 0, 1, 3)],
      lg: [_s(ink, 0.12, 0, 12, 28), _s(ink, 0.06, 0, 4, 10)],
      xl: [_s(ink, 0.18, 0, 24, 56), _s(ink, 0.08, 0, 8, 20)],
    );
  }

  /// Dark theme — denser, pure-black shadows.
  factory BasecampShadows.dark() {
    const ink = Color(0xFF000000);
    return BasecampShadows(
      xs: [_s(ink, 0.40, 0, 1, 2)],
      sm: [_s(ink, 0.45, 0, 1, 3), _s(ink, 0.35, 0, 1, 2)],
      md: [_s(ink, 0.50, 0, 4, 12), _s(ink, 0.35, 0, 1, 3)],
      lg: [_s(ink, 0.55, 0, 12, 28), _s(ink, 0.40, 0, 4, 10)],
      xl: [_s(ink, 0.62, 0, 24, 56), _s(ink, 0.45, 0, 8, 20)],
    );
  }

  static BoxShadow _s(Color c, double a, double dx, double dy, double blur) =>
      BoxShadow(
        color: c.withValues(alpha: a),
        offset: Offset(dx, dy),
        blurRadius: blur,
      );

  BasecampShadows lerp(BasecampShadows other, double t) => BasecampShadows(
        xs: BoxShadow.lerpList(xs, other.xs, t)!,
        sm: BoxShadow.lerpList(sm, other.sm, t)!,
        md: BoxShadow.lerpList(md, other.md, t)!,
        lg: BoxShadow.lerpList(lg, other.lg, t)!,
        xl: BoxShadow.lerpList(xl, other.xl, t)!,
      );
}

/// The radii ramp (`radii.css`). `full` is the pill radius (buttons, chips,
/// FABs, avatars). `md` is the default control/input radius; `lg` is cards/tiles.
@immutable
class BasecampRadii {
  const BasecampRadii({
    this.xs = 6,
    this.sm = 10,
    this.md = 14,
    this.lg = 20,
    this.xl = 28,
    this.xxl = 36,
    this.full = 999,
  });

  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;
  final double full;

  BasecampRadii lerp(BasecampRadii other, double t) => BasecampRadii(
        xs: _l(xs, other.xs, t),
        sm: _l(sm, other.sm, t),
        md: _l(md, other.md, t),
        lg: _l(lg, other.lg, t),
        xl: _l(xl, other.xl, t),
        xxl: _l(xxl, other.xxl, t),
        full: _l(full, other.full, t),
      );

  static double _l(double a, double b, double t) => a + (b - a) * t;
}

/// The 4px spacing grid + layout tokens (`spacing.css`). The numbered steps map
/// the CSS `--space-N` ladder 1:1.
@immutable
class BasecampSpacing {
  const BasecampSpacing({
    this.s0 = 0,
    this.s1 = 2,
    this.s2 = 4,
    this.s3 = 8,
    this.s4 = 12,
    this.s5 = 16,
    this.s6 = 20,
    this.s7 = 24,
    this.s8 = 32,
    this.s9 = 40,
    this.s10 = 48,
    this.s11 = 64,
    this.s12 = 80,
    this.gutter = 16,
    this.gutterTight = 12,
    this.contentMax = 480,
    this.tapMin = 44,
  });

  final double s0;
  final double s1;
  final double s2;
  final double s3;
  final double s4;
  final double s5;
  final double s6;
  final double s7;
  final double s8;
  final double s9;
  final double s10;
  final double s11;
  final double s12;

  /// Default screen-edge padding (mobile).
  final double gutter;
  final double gutterTight;

  /// Max app content width on larger viewports.
  final double contentMax;

  /// Minimum touch target.
  final double tapMin;
}

/// Motion durations + easing curves (`motion.css`). Calm, quick, gentle;
/// [spring] is the soft overshoot for playful affordances (toggles, FAB).
@immutable
class BasecampMotion {
  const BasecampMotion({
    this.instant = const Duration(milliseconds: 80),
    this.fast = const Duration(milliseconds: 140),
    this.base = const Duration(milliseconds: 220),
    this.slow = const Duration(milliseconds: 340),
    this.slower = const Duration(milliseconds: 520),
    this.standard = const Cubic(0.2, 0, 0, 1),
    this.easeOut = const Cubic(0.16, 1, 0.3, 1),
    this.easeIn = const Cubic(0.4, 0, 1, 1),
    this.spring = const Cubic(0.34, 1.4, 0.5, 1),
  });

  final Duration instant;
  final Duration fast;
  final Duration base;
  final Duration slow;
  final Duration slower;

  /// Default in/out easing.
  final Curve standard;

  /// Enter / reveal easing.
  final Curve easeOut;

  /// Exit easing.
  final Curve easeIn;

  /// Soft spring for toggles, pops, the FAB.
  final Curve spring;
}
