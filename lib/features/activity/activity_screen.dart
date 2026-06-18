import 'package:flutter/material.dart';

import '../../core/widgets/stub_destination.dart';

/// **Activity** — a launcher bar destination, currently a **stub** (CONTEXT.md /
/// ADR-0005). Reserved for a future completion feed plus insights (finished
/// things — distinct from an In-progress activity). Ships as a styled
/// placeholder so the bar is honest (brief 07): a heading plus one calm empty
/// line, with **no completion feed, no insights, and no Friends/social** (social
/// is dropped permanently). A bar-destination body (no Scaffold chrome).
class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StubDestinationBody(
      title: 'Activity',
      emptyLine: 'Nothing here yet.',
    );
  }
}
