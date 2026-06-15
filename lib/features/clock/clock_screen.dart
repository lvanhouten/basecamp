import 'package:flutter/material.dart';

import '../../core/widgets/app_drawer.dart';

/// Clock — time tools grouped under one module: alarms, a countdown Timer, and
/// a stopwatch. Each tab is a stub pane for now.
class ClockScreen extends StatelessWidget {
  const ClockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        drawer: const AppDrawer(),
        appBar: AppBar(
          title: const Text('Clock'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Alarms', icon: Icon(Icons.alarm)),
              Tab(text: 'Timer', icon: Icon(Icons.hourglass_empty)),
              Tab(text: 'Stopwatch', icon: Icon(Icons.timer)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _Placeholder(label: 'No alarms set'),
            _Placeholder(label: 'Set a countdown'),
            _Placeholder(label: '00:00.00'),
          ],
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(label, style: Theme.of(context).textTheme.headlineSmall),
    );
  }
}
