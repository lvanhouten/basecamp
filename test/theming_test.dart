import 'dart:async';

import 'package:basecamp/core/db/app_db.dart';
import 'package:basecamp/core/providers.dart';
import 'package:basecamp/core/settings.dart';
import 'package:basecamp/core/theme.dart';
import 'package:basecamp/core/tokens.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('basecampTheme — ColorScheme', () {
    test('light: coral brand, navy ink, navy-neutral surface, red error', () {
      final scheme = basecampTheme(Brightness.light).colorScheme;
      expect(scheme.brightness, Brightness.light);
      expect(scheme.primary, const Color(0xFFFF5A3C)); // coral brand
      expect(scheme.onSurface, const Color(0xFF1A1A2E)); // navy ink
      expect(scheme.surface, const Color(0xFFF6F7F9)); // neutral-50, not cream
      expect(scheme.error, const Color(0xFFE5343B)); // design-system red
    });

    test('dark: design-system brand + its own near-black navy surfaces', () {
      final scheme = basecampTheme(Brightness.dark).colorScheme;
      expect(scheme.brightness, Brightness.dark);
      expect(scheme.primary, const Color(0xFFFF5A3C)); // coral brand
      expect(scheme.surface, const Color(0xFF131326)); // dark surface-app
      expect(scheme.error, const Color(0xFFE5343B));
    });
  });

  group('basecampTheme — BasecampTokens extension', () {
    for (final brightness in Brightness.values) {
      test('registered for $brightness with joy/shadows/radii/spacing/motion',
          () {
        final theme = basecampTheme(brightness);
        final tokens = theme.extension<BasecampTokens>();
        expect(tokens, isNotNull);

        // Joy accent.
        expect(tokens!.joy, const Color(0xFFFFC844)); // sun-500
        expect(tokens.joyInk, const Color(0xFF99690A)); // sun-900

        // 5-step shadow scale.
        expect(tokens.shadows.xs, isNotEmpty);
        expect(tokens.shadows.sm, isNotEmpty);
        expect(tokens.shadows.md, isNotEmpty);
        expect(tokens.shadows.lg, isNotEmpty);
        expect(tokens.shadows.xl, isNotEmpty);

        // Radii ramp: 6 / 10 / 14 / 20 / 28 / 36 / full.
        expect(tokens.radii.xs, 6);
        expect(tokens.radii.sm, 10);
        expect(tokens.radii.md, 14);
        expect(tokens.radii.lg, 20);
        expect(tokens.radii.xl, 28);
        expect(tokens.radii.xxl, 36);
        expect(tokens.radii.full, 999);

        // Spacing 4px grid.
        expect(tokens.spacing.s2, 4);
        expect(tokens.spacing.s5, 16);
        expect(tokens.spacing.gutter, 16);
        expect(tokens.spacing.tapMin, 44);

        // Motion durations + easings.
        expect(tokens.motion.instant, const Duration(milliseconds: 80));
        expect(tokens.motion.fast, const Duration(milliseconds: 140));
        expect(tokens.motion.base, const Duration(milliseconds: 220));
        expect(tokens.motion.slow, const Duration(milliseconds: 340));
        expect(tokens.motion.slower, const Duration(milliseconds: 520));
        expect(tokens.motion.standard, const Cubic(0.2, 0, 0, 1));
        expect(tokens.motion.spring, const Cubic(0.34, 1.4, 0.5, 1));
      });
    }

    test('copyWith/lerp implemented and stable', () {
      final t = basecampTheme(Brightness.light).extension<BasecampTokens>()!;
      expect(t.copyWith(joy: const Color(0xFF000000)).joy,
          const Color(0xFF000000));
      // lerp(self, 1.0) returns the other end unchanged.
      final lerped = t.lerp(t, 1.0);
      expect(lerped.joy, t.joy);
      expect(lerped.radii.full, t.radii.full);
      // lerp against a non-BasecampTokens returns self.
      expect(t.lerp(null, 0.5), same(t));
    });
  });

  group('basecampTheme — TextTheme (Hanken Grotesk)', () {
    test('roles map to the design-system sizes/weights/line-heights', () {
      final tt = basecampTheme(Brightness.light).textTheme;

      // display: 800 / 38 / 1.12
      expect(tt.displaySmall!.fontFamily, 'Hanken Grotesk');
      expect(tt.displaySmall!.fontSize, 38);
      expect(tt.displaySmall!.fontWeight, FontWeight.w800);
      expect(tt.displaySmall!.height, 1.12);

      // title: 700 / 30 / 1.12
      expect(tt.titleLarge!.fontSize, 30);
      expect(tt.titleLarge!.fontWeight, FontWeight.w700);

      // heading: 700 / 20 / 1.28
      expect(tt.titleMedium!.fontSize, 20);
      expect(tt.titleMedium!.fontWeight, FontWeight.w700);

      // subhead: 600 / 17
      expect(tt.titleSmall!.fontSize, 17);
      expect(tt.titleSmall!.fontWeight, FontWeight.w600);

      // body: 400 / 15 / 1.5
      expect(tt.bodyLarge!.fontSize, 15);
      expect(tt.bodyLarge!.fontWeight, FontWeight.w400);
      expect(tt.bodyLarge!.height, 1.5);

      // label: 600 / 13
      expect(tt.labelLarge!.fontSize, 13);
      expect(tt.labelLarge!.fontWeight, FontWeight.w600);

      // caption: 500 / 12
      expect(tt.bodySmall!.fontSize, 12);
      expect(tt.bodySmall!.fontWeight, FontWeight.w500);

      // display tracking is tight (negative).
      expect(tt.displaySmall!.letterSpacing! < 0, isTrue);
    });

    test('numericTextStyle enables tabular figures', () {
      final s = numericTextStyle();
      expect(s.fontFamily, 'Hanken Grotesk');
      expect(s.fontFeatures, contains(const FontFeature.tabularFigures()));
      // configurable size for the full-screen timer (--text-5xl = 64).
      expect(numericTextStyle(fontSize: 64).fontSize, 64);
    });
  });

  group('basecampTheme — themed Material components', () {
    test('buttons are pills (full radius), inputs/checkbox/card/switch themed',
        () {
      final theme = basecampTheme(Brightness.light);
      final full = theme.extension<BasecampTokens>()!.radii.full;

      RoundedRectangleBorder shapeOf(ButtonStyle? style) =>
          style!.shape!.resolve({}) as RoundedRectangleBorder;

      for (final shape in [
        shapeOf(theme.filledButtonTheme.style),
        shapeOf(theme.outlinedButtonTheme.style),
        shapeOf(theme.textButtonTheme.style),
      ]) {
        final r = shape.borderRadius as BorderRadius;
        expect(r.topLeft.x, full);
      }

      // Input: filled with the soft (md) radius.
      expect(theme.inputDecorationTheme.filled, isTrue);

      // Card: soft radius + hairline border, no surface tint.
      final cardShape = theme.cardTheme.shape as RoundedRectangleBorder;
      expect((cardShape.borderRadius as BorderRadius).topLeft.x,
          theme.extension<BasecampTokens>()!.radii.lg);
      expect(cardShape.side.color, theme.colorScheme.outlineVariant);

      // Switch + Checkbox adopt the brand when selected.
      expect(
        theme.switchTheme.trackColor!.resolve({WidgetState.selected}),
        theme.colorScheme.primary,
      );
      expect(
        theme.checkboxTheme.fillColor!.resolve({WidgetState.selected}),
        theme.colorScheme.primary,
      );
    });
  });

  group('theme-mode persistence', () {
    test('a chosen mode survives a simulated cold start', () async {
      // One in-memory database, shared across two provider containers — this is
      // the "same on-disk Drift file" stand-in. Drift is the source of truth,
      // so a mode written in container A must be readable by a freshly-built
      // container B (a cold start re-hydrates the provider from Drift).
      final db = AppDb.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      final containerA = ProviderContainer(
        overrides: [dbProvider.overrideWithValue(db)],
      );
      // Default before any choice: system.
      expect(containerA.read(themeModeProvider), ThemeMode.system);

      await containerA.read(themeModeProvider.notifier).set(ThemeMode.dark);
      expect(containerA.read(themeModeProvider), ThemeMode.dark);
      containerA.dispose();

      // Simulate cold start: brand-new container over the SAME db.
      final containerB = ProviderContainer(
        overrides: [dbProvider.overrideWithValue(db)],
      );
      addTearDown(containerB.dispose);

      // The store reads the persisted choice back directly — the durable copy.
      expect(
        await containerB.read(settingsStoreProvider).readThemeMode(),
        ThemeMode.dark,
      );

      // And the provider re-hydrates from Drift on first build: it returns
      // `system` synchronously, then flips to the persisted mode once the async
      // hydrate resolves. Await that transition deterministically.
      final hydrated = Completer<ThemeMode>();
      final sub = containerB.listen<ThemeMode>(themeModeProvider, (_, next) {
        if (next != ThemeMode.system && !hydrated.isCompleted) {
          hydrated.complete(next);
        }
      }, fireImmediately: true);
      addTearDown(sub.close);

      expect(await hydrated.future.timeout(const Duration(seconds: 2)),
          ThemeMode.dark);
      expect(containerB.read(themeModeProvider), ThemeMode.dark);
    });
  });
}
