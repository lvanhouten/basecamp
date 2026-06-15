import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_module.dart';
import 'providers.dart';

/// The hub. Keeps every module alive in an [IndexedStack] and shows the one
/// selected via [selectedModuleProvider] (driven by the drawer and the Brief's
/// cards). No bottom bar — each module root carries the navigation drawer.
///
/// Android back returns to the Brief from any other module; from the Brief it
/// pops the app. Deep pushes (e.g. a list's detail) sit above this on the root
/// navigator and pop normally before this ever fires.
class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedModuleProvider);

    return PopScope(
      canPop: selected == AppModule.brief,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          ref.read(selectedModuleProvider.notifier).select(AppModule.brief);
        }
      },
      child: IndexedStack(
        index: selected.index,
        children: [for (final m in AppModule.values) m.screen],
      ),
    );
  }
}
