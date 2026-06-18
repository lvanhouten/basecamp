import 'package:flutter/material.dart';

import 'tokens.dart';

// Single source of truth for Basecamp's look. The palette and type are
// transcribed verbatim from the design system's token files
// (`_docs/design-system/project/tokens/`) — explicit, hand-picked values, NOT
// a seed-derived scheme. Coral is the brand/primary, grounded by deep-navy ink
// on a cool navy-leaning neutral ramp; the design system's red is the error
// role. Everything Material has no role for lives in [BasecampTokens] (see
// `tokens.dart`).
//
// Widgets read colours from `Theme.of(context)` / `ColorScheme` and the
// extension — never hardcode (CLAUDE.md).

// ===========================================================================
// Raw palette — base scales (colors.css), transcribed.
// ===========================================================================

// Neutrals — cool, navy-leaning grey ramp.
const _neutral0 = Color(0xFFFFFFFF);
const _neutral50 = Color(0xFFF6F7F9);
const _neutral100 = Color(0xFFEDEEF2);
const _neutral200 = Color(0xFFE0E2E9);
const _neutral300 = Color(0xFFC9CCD6);
const _neutral600 = Color(0xFF5B6072);
const _neutral900 = Color(0xFF1A1A2E); // brand navy — primary ink

// Coral — the brand.
const _coral50 = Color(0xFFFFF0EC);
const _coral300 = Color(0xFFFF9D83);
const _coral500 = Color(0xFFFF5A3C); // brand
const _coral600 = Color(0xFFED4426);

// Joy — sunshine yellow.
const _sun50 = Color(0xFFFFF7E0);
const _sun500 = Color(0xFFFFC844);
const _sun900 = Color(0xFF99690A);

// Status red — the error role.
const _red50 = Color(0xFFFCE7E8);
const _red500 = Color(0xFFE5343B);

// Dark-theme surfaces (colors.css `[data-theme="dark"]`).
const _darkAppBg = Color(0xFF131326);
const _darkCard = Color(0xFF1E1E36);
const _darkRaised = Color(0xFF262642);
const _darkSunken = Color(0xFF0E0E1E);
const _darkTextPrimary = Color(0xFFF4F3F8);
const _darkTextSecondary = Color(0xFFADB0C2);

// ===========================================================================
// Theme builder.
// ===========================================================================

ThemeData basecampTheme(Brightness brightness) {
  final isLight = brightness == Brightness.light;
  final scheme = isLight ? _lightScheme : _darkScheme;
  final tokens = isLight ? _lightTokens : _darkTokens;
  final textTheme = _textTheme(scheme.onSurface, scheme.onSurfaceVariant);

  final pill = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(tokens.radii.full),
  );
  final inputRadius = BorderRadius.circular(tokens.radii.md);
  final cardRadius = BorderRadius.circular(tokens.radii.lg);

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    fontFamily: _fontFamily,
    textTheme: textTheme,
    extensions: [tokens],

    // --- Buttons: pills (radii-full). Press uses a subtle shrink elsewhere; ---
    // here we theme shape + the disabled state (40-45% opacity per the
    // interaction-states guidance).
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: pill,
        textStyle: textTheme.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: pill,
        side: BorderSide(color: scheme.outline),
        textStyle: textTheme.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: pill,
        textStyle: textTheme.labelLarge,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(shape: pill),
    ),

    // --- Inputs: soft (radius-md) filled fields, hairline border, brand focus.
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isLight ? _neutral50 : _darkSunken,
      border: OutlineInputBorder(
        borderRadius: inputRadius,
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: inputRadius,
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: inputRadius,
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: inputRadius,
        borderSide: BorderSide(color: scheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: inputRadius,
        borderSide: BorderSide(color: scheme.error, width: 2),
      ),
    ),

    // --- Card: soft radius + navy-tinted soft shadow (elevated) / hairline
    // border. We expose the layered shadow scale via BasecampTokens; the
    // CardTheme keeps Material's single-elevation shadow modest and gives the
    // soft radius + a hairline so outlined cards read as the design language.
    cardTheme: CardThemeData(
      color: scheme.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      elevation: 1,
      shadowColor: tokens.shadows.md.first.color,
      shape: RoundedRectangleBorder(
        borderRadius: cardRadius,
        side: BorderSide(color: scheme.outlineVariant),
      ),
      margin: EdgeInsets.zero,
    ),

    // --- Switch: brand when on (selected adopts the accent), spring-y thumb.
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return scheme.onSurface.withValues(alpha: 0.40);
        }
        return states.contains(WidgetState.selected) ? scheme.onPrimary : null;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return scheme.onSurface.withValues(alpha: 0.12);
        }
        return states.contains(WidgetState.selected) ? scheme.primary : null;
      }),
    ),

    // --- Checkbox: brand fill when checked (selected adopts the accent),
    // soft-radius box.
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radii.xs),
      ),
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return scheme.onSurface.withValues(alpha: 0.40);
        }
        return states.contains(WidgetState.selected) ? scheme.primary : null;
      }),
      checkColor: WidgetStatePropertyAll(scheme.onPrimary),
    ),
  );
}

// ===========================================================================
// Color schemes — semantic roles populated from the design system's aliases.
// ===========================================================================

/// Light: surfaces on the navy-neutral ramp, coral brand, navy ink, red error.
const _lightScheme = ColorScheme(
  brightness: Brightness.light,
  primary: _coral500, // --brand
  onPrimary: _neutral0, // --on-brand
  primaryContainer: _coral50, // --brand-tint
  onPrimaryContainer: _neutral900,
  secondary: _coral600, // --brand-hover
  onSecondary: _neutral0,
  secondaryContainer: _coral50,
  onSecondaryContainer: _neutral900,
  tertiary: _sun500, // joy accent surfaced as tertiary
  onTertiary: _sun900,
  tertiaryContainer: _sun50,
  onTertiaryContainer: _sun900,
  error: _red500, // --danger
  onError: _neutral0,
  errorContainer: _red50, // --danger-tint
  onErrorContainer: Color(0xFFB4242A), // --red-700
  surface: _neutral50, // --surface-app
  onSurface: _neutral900, // --text-primary
  onSurfaceVariant: _neutral600, // --text-secondary
  surfaceContainerLowest: _neutral0, // --surface-card / --surface-raised
  surfaceContainerLow: _neutral50,
  surfaceContainer: _neutral100, // --surface-sunken
  surfaceContainerHigh: _neutral100,
  surfaceContainerHighest: _neutral200,
  surfaceDim: _neutral100,
  surfaceBright: _neutral0,
  inverseSurface: _neutral900, // --surface-inverse
  onInverseSurface: _neutral0, // --text-inverse
  inversePrimary: _coral300,
  outline: _neutral300, // --border-default
  outlineVariant: _neutral200, // --border-subtle
  shadow: Color(0xFF1B1F26), // navy-tinted (rgb 27,31,38)
  scrim: Color(0x6B111120), // --surface-scrim ~ rgba(17,17,32,.42)
);

/// Dark: near-black navy surfaces with their own ramp and a lightened brand.
const _darkScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: _coral500, // --brand (dark keeps coral-500)
  onPrimary: _neutral0, // --on-brand
  primaryContainer: Color(0x2EFF5A3C), // --brand-tint rgba(255,90,60,.18)
  onPrimaryContainer: Color(0xFFFFC0AE),
  secondary: _coral300, // --brand-active (dark)
  onSecondary: _neutral900,
  secondaryContainer: Color(0x2EFF5A3C),
  onSecondaryContainer: Color(0xFFFFC0AE),
  tertiary: _sun500,
  onTertiary: _sun900,
  tertiaryContainer: Color(0x2EFFC844), // --joy-tint dark
  onTertiaryContainer: _sun50,
  error: _red500,
  onError: _neutral0,
  errorContainer: Color(0x2EE5343B), // --danger-tint dark
  onErrorContainer: _red50,
  surface: _darkAppBg, // --surface-app (dark)
  onSurface: _darkTextPrimary, // --text-primary (dark)
  onSurfaceVariant: _darkTextSecondary, // --text-secondary (dark)
  surfaceContainerLowest: _darkSunken, // --surface-sunken (dark)
  surfaceContainerLow: _darkCard, // --surface-card (dark)
  surfaceContainer: _darkCard,
  surfaceContainerHigh: _darkRaised, // --surface-raised (dark)
  surfaceContainerHighest: _darkRaised,
  surfaceDim: _darkSunken,
  surfaceBright: _darkRaised,
  inverseSurface: _neutral50,
  onInverseSurface: _neutral900,
  inversePrimary: _coral600,
  outline: Color(0x24FFFFFF), // --border-strong rgba(255,255,255,.24)
  outlineVariant: Color(0x14FFFFFF), // --border-default rgba(255,255,255,.08-.14)
  shadow: Color(0xFF000000),
  scrim: Color(0x94000000), // --surface-scrim dark rgba(0,0,0,.58)
);

// ===========================================================================
// Tokens (the ThemeExtension instances) per brightness.
// ===========================================================================

final _lightTokens = BasecampTokens(
  joy: _sun500,
  joyTint: _sun50,
  joyInk: _sun900,
  moduleTint: _coral50, // --module-tint (brand-unified, dormant)
  shadows: BasecampShadows.light(),
  radii: const BasecampRadii(),
  spacing: const BasecampSpacing(),
  motion: const BasecampMotion(),
);

final _darkTokens = BasecampTokens(
  joy: _sun500,
  joyTint: const Color(0x2EFFC844), // --joy-tint dark (rgba(255,200,68,.18))
  joyInk: _sun900, // dark theme leaves --joy-ink at --sun-900 (colors.css)
  moduleTint: const Color(0x2EFF5A3C), // --module-tint dark
  shadows: BasecampShadows.dark(),
  radii: const BasecampRadii(),
  spacing: const BasecampSpacing(),
  motion: const BasecampMotion(),
);

// ===========================================================================
// Typography — Hanken Grotesk, from the design system's type roles.
// ===========================================================================

const _fontFamily = 'Hanken Grotesk';

/// Tabular-figure feature, shared by [numericTextStyle] and any caller that
/// wants lining/monospaced digits (timers/stopwatch/stats/durations/alarm
/// times/counts) — the brand sans carries numerics, there is no mono product
/// font (the design system dropped Spline Sans Mono).
const _tabularFigures = FontFeature.tabularFigures();

/// A reusable numeric text style with tabular figures, for timers, the
/// stopwatch, stats, durations, alarm times, and counts. Pass [fontSize] /
/// [fontWeight] / [color] to size it for the context (e.g. the full-screen
/// timer at `--text-5xl` = 64). Defaults to a large display weight.
TextStyle numericTextStyle({
  double fontSize = 48,
  FontWeight fontWeight = FontWeight.w700,
  double height = 1.0,
  Color? color,
}) {
  return TextStyle(
    fontFamily: _fontFamily,
    fontSize: fontSize,
    fontWeight: fontWeight,
    height: height,
    letterSpacing: 0,
    color: color,
    fontFeatures: const [_tabularFigures],
  );
}

/// Maps the design system's 7 type roles to Flutter's [TextTheme] slots, using
/// each role's size / weight / line-height / tracking (typography.css).
///
/// Role → slot:
///   display (800 / 38 / 1.12 / -0.02em) → displaySmall + headlineLarge
///   title   (700 / 30 / 1.12 / -0.02em) → headlineMedium + titleLarge
///   heading (700 / 20 / 1.28 / -0.01em) → titleMedium
///   subhead (600 / 17 / 1.28 / -0.01em) → titleSmall
///   body    (400 / 15 / 1.5)            → bodyLarge/Medium
///   label   (600 / 13 / 1.28)           → labelLarge/Medium
///   caption (500 / 12 / 1.28)           → bodySmall + labelSmall
TextTheme _textTheme(Color onSurface, Color onSurfaceVariant) {
  TextStyle role({
    required double size,
    required FontWeight weight,
    required double leading,
    double trackingEm = 0,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: size,
      fontWeight: weight,
      height: leading,
      letterSpacing: size * trackingEm,
      color: color ?? onSurface,
    );
  }

  final display = role(
    size: 38,
    weight: FontWeight.w800,
    leading: 1.12,
    trackingEm: -0.02,
  );
  final title = role(
    size: 30,
    weight: FontWeight.w700,
    leading: 1.12,
    trackingEm: -0.02,
  );
  final heading = role(
    size: 20,
    weight: FontWeight.w700,
    leading: 1.28,
    trackingEm: -0.01,
  );
  final subhead = role(
    size: 17,
    weight: FontWeight.w600,
    leading: 1.28,
    trackingEm: -0.01,
  );
  final body = role(size: 15, weight: FontWeight.w400, leading: 1.5);
  final label = role(size: 13, weight: FontWeight.w600, leading: 1.28);
  final caption =
      role(size: 12, weight: FontWeight.w500, leading: 1.28, color: onSurfaceVariant);

  return TextTheme(
    displayLarge: display,
    displayMedium: display,
    displaySmall: display,
    headlineLarge: display,
    headlineMedium: title,
    headlineSmall: title,
    titleLarge: title,
    titleMedium: heading,
    titleSmall: subhead,
    bodyLarge: body,
    bodyMedium: body,
    bodySmall: caption,
    labelLarge: label,
    labelMedium: label,
    labelSmall: caption,
  );
}
