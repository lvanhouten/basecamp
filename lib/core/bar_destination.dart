import 'package:flutter/material.dart';

/// The fixed launcher bar destinations (ADR-0005). A separate, closed set from
/// [AppModule] (the grid modules): the bar never grows as modules are added,
/// because modules live behind the [BarDestination.modules] tab. Order is the
/// bar's left-to-right order; the center ⊕ FAB splits it 2/2 (Brief · Calendar
/// | ⊕ | Activity · Modules). The Brief is a bar destination here, not a module.
enum BarDestination {
  brief(label: 'Brief', icon: Icons.dashboard_outlined),
  calendar(label: 'Calendar', icon: Icons.calendar_month_outlined),
  activity(label: 'Activity', icon: Icons.insights_outlined),
  modules(label: 'Modules', icon: Icons.widgets_outlined);

  const BarDestination({required this.label, required this.icon});

  final String label;
  final IconData icon;
}
