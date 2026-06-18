import 'package:flutter/material.dart';

import '../../core/widgets/bar_destination_placeholder.dart';

/// **Activity** — a launcher bar destination, currently a **stub** (CONTEXT.md /
/// ADR-0005). Reserved for a future completion feed plus insights (finished
/// things — distinct from an In-progress activity). Shipped as a placeholder so
/// the bar is honest; brief `07-stub-and-profile-screens` fills in the real stub
/// content. A bar-destination body (no Scaffold chrome).
class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BarDestinationPlaceholder(
      icon: Icons.insights_outlined,
      title: 'Activity',
      subtitle: 'A feed of what you have finished is coming.',
    );
  }
}
