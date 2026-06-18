import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tokens.dart';

/// A circular arc that fills proportionally to [value], with an optional center
/// [label] slot.
///
/// Faithful to the design system's `ProgressRing` (data-display): a hairline
/// track ring with a brand-coloured fill arc starting at 12 o'clock and sweeping
/// clockwise, rounded end caps. The fill eases over the design system's `slow`
/// duration with `easeOut` and respects reduced motion — under
/// `MediaQuery.disableAnimations` it paints at the final value with no tween.
///
/// [value] accepts either a fraction in `[0, 1]` or a percentage in `[0, 100]`
/// (anything `> 1` is treated as a percentage). Out-of-range values clamp.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    this.size = 64,
    this.thickness = 6,
    this.label,
  });

  /// Progress as a fraction `[0, 1]` or a percentage `[0, 100]`.
  final double value;

  /// Diameter in logical pixels.
  final double size;

  /// Stroke width in logical pixels.
  final double thickness;

  /// Optional center child. When null, no label is shown (ring only).
  final Widget? label;

  /// Normalises [value] to a clamped `[0, 1]` fraction.
  static double normalize(double value) {
    final fraction = value > 1 ? value / 100 : value;
    return fraction.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = Theme.of(context).extension<BasecampTokens>()!;
    final fraction = normalize(value);

    final ring = SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _AnimatedRing(
            fraction: fraction,
            size: size,
            thickness: thickness,
            trackColor: scheme.outlineVariant,
            fillColor: scheme.primary,
            duration: tokens.motion.slow,
            curve: tokens.motion.easeOut,
          ),
          ?label,
        ],
      ),
    );

    return Semantics(
      label: '${(fraction * 100).round()} percent',
      child: ring,
    );
  }
}

class _AnimatedRing extends StatelessWidget {
  const _AnimatedRing({
    required this.fraction,
    required this.size,
    required this.thickness,
    required this.trackColor,
    required this.fillColor,
    required this.duration,
    required this.curve,
  });

  final double fraction;
  final double size;
  final double thickness;
  final Color trackColor;
  final Color fillColor;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    Widget painter(double f) => CustomPaint(
          size: Size.square(size),
          painter: _RingPainter(
            fraction: f,
            thickness: thickness,
            trackColor: trackColor,
            fillColor: fillColor,
          ),
        );

    // Reduced motion: paint at the final value, no tween.
    if (reduceMotion) return painter(fraction);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: fraction),
      duration: duration,
      curve: curve,
      builder: (context, animated, _) => painter(animated),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.fraction,
    required this.thickness,
    required this.trackColor,
    required this.fillColor,
  });

  final double fraction;
  final double thickness;
  final Color trackColor;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - thickness) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..color = trackColor;
    canvas.drawCircle(center, radius, track);

    if (fraction <= 0) return;

    final fill = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..color = fillColor;

    // Start at 12 o'clock, sweep clockwise.
    const start = -math.pi / 2;
    final sweep = 2 * math.pi * fraction;
    canvas.drawArc(rect, start, sweep, false, fill);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.fraction != fraction ||
      old.thickness != thickness ||
      old.trackColor != trackColor ||
      old.fillColor != fillColor;
}
