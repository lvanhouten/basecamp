import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_module.dart';
import '../providers.dart';

/// The hub's navigation drawer. Lives on every module root (see ADR-0001), so a
/// drawer-hop switches modules instantly — selecting a destination just writes
/// [selectedModuleProvider], which the shell's IndexedStack reads.
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedModuleProvider);
    final theme = Theme.of(context);

    return NavigationDrawer(
      selectedIndex: selected.index,
      onDestinationSelected: (i) {
        Navigator.of(context).pop(); // close the drawer first
        ref.read(selectedModuleProvider.notifier).select(AppModule.values[i]);
      },
      children: [
        DrawerHeader(
          decoration: BoxDecoration(color: theme.colorScheme.primaryContainer),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              'Basecamp',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(color: theme.colorScheme.onPrimaryContainer),
            ),
          ),
        ),
        for (final m in AppModule.values)
          NavigationDrawerDestination(
            icon: Icon(m.icon),
            selectedIcon: Icon(m.selectedIcon),
            label: Text(m.label),
          ),
      ],
    );
  }
}
