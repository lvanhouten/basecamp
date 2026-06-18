import 'package:flutter/material.dart';

import '../../core/widgets/bar_destination_placeholder.dart';

/// **Calendar** — a launcher bar destination, currently a **stub** (CONTEXT.md /
/// ADR-0005). Reserved for a future cross-module schedule view; shipped as a
/// placeholder so the bar is complete. Brief `07-stub-and-profile-screens`
/// fills in the real stub content. A bar-destination body (no Scaffold chrome).
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BarDestinationPlaceholder(
      icon: Icons.calendar_month_outlined,
      title: 'Calendar',
      subtitle: 'A cross-module schedule view is coming.',
    );
  }
}
