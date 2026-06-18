import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/settings.dart';
import '../../core/tokens.dart';
import '../../core/widgets/components.dart';

/// **Profile** — the settings surface, reached from the Brief's top-right avatar
/// (CONTEXT.md; the avatar wiring is brief 05). A pushed route with its own
/// Scaffold + AppBar/back; not a bottom-bar destination.
///
/// For now it hosts only the **appearance** control: a light / dark / system
/// choice wired to [themeModeProvider] (brief 01) — reading the current mode via
/// `ref.watch` and persisting a change via `ref.read(themeModeProvider.notifier)
/// .set(...)`, which flips the app theme immediately and survives cold start
/// (persistence + its test are owned by brief 01). Built to grow (notification
/// prefs, etc.); only the theme control is required now.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = theme.extension<BasecampTokens>()!;
    final mode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(tokens.spacing.gutter),
          children: [
            _SectionLabel('Appearance'),
            SizedBox(height: tokens.spacing.s3),
            BcListGroup(
              children: [
                BcListItem(
                  leading: const BcListItemIcon(Icons.brightness_6_outlined),
                  title: 'Theme',
                  subtitle: _subtitleFor(mode),
                ),
              ],
            ),
            SizedBox(height: tokens.spacing.s4),
            Align(
              alignment: Alignment.centerLeft,
              child: SegmentedControl<ThemeMode>(
                value: mode,
                onChanged: (next) =>
                    ref.read(themeModeProvider.notifier).set(next),
                options: const [
                  SegmentOption(value: ThemeMode.light, label: 'Light'),
                  SegmentOption(value: ThemeMode.dark, label: 'Dark'),
                  SegmentOption(value: ThemeMode.system, label: 'System'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _subtitleFor(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'Match your device';
    }
  }
}

/// A small uppercase eyebrow label (the design system's letter-spaced section
/// label — a visual device, not sentence content).
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text.toUpperCase(),
      style: theme.textTheme.labelMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
