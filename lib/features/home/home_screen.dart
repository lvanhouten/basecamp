import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/bar_destination_placeholder.dart';

/// The **Brief** — the launcher shell's first bar destination (ADR-0005). This
/// is a **minimal placeholder**: brief `05-brief-screen` replaces it with the
/// real daily-digest content (today's progress, Resume affordances, the
/// top-right Profile avatar). It no longer hosts a navigation drawer or the
/// module grid (both moved/retired in ADR-0005), and it carries no Scaffold
/// chrome of its own — it is a bar-destination body inside the launcher shell.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const BarDestinationPlaceholder(
      icon: Icons.dashboard_outlined,
      title: 'Brief',
      subtitle: 'Your daily digest will live here.',
    );
  }
}
