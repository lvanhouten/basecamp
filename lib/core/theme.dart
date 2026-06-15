import 'package:flutter/material.dart';

/// Single source of truth for Basecamp's look. One terracotta brand seed drives
/// the accent colours; the surface/neutral family is overridden to warm-neutral
/// so the background reads cream/charcoal rather than pink.
const Color _seed = Color(0xFFBF5B3F); // terracotta

ThemeData basecampTheme(Brightness brightness) {
  // `fidelity` keeps the ACCENT roles (primary/secondary/tertiary + containers)
  // true to the terracotta seed; the default `tonalSpot` washes them to pink.
  final base = ColorScheme.fromSeed(
    seedColor: _seed,
    brightness: brightness,
    dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
  );

  // ...but fidelity also tints the SURFACE/neutral family pink. Override just
  // those roles with warm-neutral tones, leaving the clay accents intact.
  final scheme = brightness == Brightness.light
      ? _withLightNeutrals(base)
      : _withDarkNeutrals(base);

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
  );
}

/// Warm off-white surfaces (a hint of warmth, no pink). `surfaceTint` is set to
/// the surface colour so M3's elevation overlay can't re-introduce a pink cast.
ColorScheme _withLightNeutrals(ColorScheme base) => base.copyWith(
      surface: const Color(0xFFFAF8F5),
      onSurface: const Color(0xFF1D1B1A),
      surfaceDim: const Color(0xFFE0DDD7),
      surfaceBright: const Color(0xFFFAF8F5),
      surfaceContainerLowest: const Color(0xFFFFFFFF),
      surfaceContainerLow: const Color(0xFFF5F2ED),
      surfaceContainer: const Color(0xFFEFECE6),
      surfaceContainerHigh: const Color(0xFFE9E6E0),
      surfaceContainerHighest: const Color(0xFFE3E0DA),
      onSurfaceVariant: const Color(0xFF4C4845),
      outline: const Color(0xFF7D7973),
      outlineVariant: const Color(0xFFCFC9C2),
      surfaceTint: const Color(0xFFFAF8F5),
    );

/// Warm near-black surfaces.
ColorScheme _withDarkNeutrals(ColorScheme base) => base.copyWith(
      surface: const Color(0xFF15140F),
      onSurface: const Color(0xFFE8E2D9),
      surfaceDim: const Color(0xFF15140F),
      surfaceBright: const Color(0xFF3B3833),
      surfaceContainerLowest: const Color(0xFF100F0B),
      surfaceContainerLow: const Color(0xFF1D1B17),
      surfaceContainer: const Color(0xFF21201B),
      surfaceContainerHigh: const Color(0xFF2C2A25),
      surfaceContainerHighest: const Color(0xFF373530),
      onSurfaceVariant: const Color(0xFFCBC5BC),
      outline: const Color(0xFF948E85),
      outlineVariant: const Color(0xFF4A453F),
      surfaceTint: const Color(0xFF15140F),
    );
