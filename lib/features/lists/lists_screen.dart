import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/widgets/app_drawer.dart';
import 'list_detail_screen.dart';

class ListsScreen extends ConsumerWidget {
  const ListsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(listsProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Lists')),
      body: listsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (lists) {
          if (lists.isEmpty) {
            return const Center(
              child: Text('No lists yet — tap + to create one.'),
            );
          }
          return ListView.builder(
            itemCount: lists.length,
            itemBuilder: (context, i) {
              final row = lists[i];
              return Dismissible(
                key: ValueKey(row.list.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Theme.of(context).colorScheme.errorContainer,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  child: const Icon(Icons.delete),
                ),
                onDismissed: (_) =>
                    ref.read(listsRepositoryProvider).deleteList(row.list.id),
                child: ListTile(
                  leading: const Icon(Icons.checklist),
                  title: Text(row.list.name),
                  trailing: Chip(label: Text('${row.openCount}')),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ListDetailScreen(
                        listId: row.list.id,
                        title: row.list.name,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createList(context, ref),
        tooltip: 'New list',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _createList(BuildContext context, WidgetRef ref) async {
    final name = await promptForText(context, title: 'New list', hint: 'List name');
    if (name != null && name.isNotEmpty) {
      await ref.read(listsRepositoryProvider).createList(name);
    }
  }
}

/// Small reusable single-field text dialog.
///
/// Serves both "add" and "rename": pass [initialValue] to pre-fill the field
/// (the text is pre-selected so typing replaces it) and [actionLabel] to label
/// the confirm button (defaults to `'Add'`; rename callers pass `'Save'`).
/// Returns the trimmed text on confirm, or `null` on cancel.
Future<String?> promptForText(
  BuildContext context, {
  required String title,
  required String hint,
  String? initialValue,
  String actionLabel = 'Add',
}) {
  final controller = TextEditingController(text: initialValue);
  // Pre-select the seeded text so confirming a rename can replace it in one keystroke.
  if (initialValue != null && initialValue.isNotEmpty) {
    controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: initialValue.length,
    );
  }
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(hintText: hint),
        onSubmitted: (v) => Navigator.of(context).pop(v.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(controller.text.trim()),
          child: Text(actionLabel),
        ),
      ],
    ),
  );
}
