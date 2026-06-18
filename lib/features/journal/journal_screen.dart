import 'package:flutter/material.dart';

import '../../core/widgets/stub_module_body.dart';

/// Journal — a **stub module** (CONTEXT.md): a real Modules-grid tile that
/// pushes this placeholder, with no data layer yet (built as its own feature
/// later). As a pushed route it gets a back arrow automatically; no drawer
/// (ADR-0005).
class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Journal')),
      body: const StubModuleBody(icon: Icons.book_outlined, name: 'Journal'),
    );
  }
}
