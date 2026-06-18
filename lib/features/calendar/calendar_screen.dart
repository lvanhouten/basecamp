import 'package:flutter/material.dart';

import '../../core/widgets/stub_destination.dart';

/// **Calendar** — a launcher bar destination, currently a **stub** (CONTEXT.md /
/// ADR-0005). Reserved for a future cross-module schedule/agenda view; no
/// scheduling data model exists yet, so this ships as a styled placeholder so
/// the bar is honest (brief 07). A heading plus one calm empty line — no grid,
/// no fabricated agenda. A bar-destination body (no Scaffold chrome).
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StubDestinationBody(
      title: 'Calendar',
      emptyLine: 'Nothing here yet.',
    );
  }
}
