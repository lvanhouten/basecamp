import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import 'lists_screen.dart' show promptForText;

class ListDetailScreen extends ConsumerWidget {
  const ListDetailScreen({super.key, required this.listId, required this.title});

  final int listId;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(listItemsProvider(listId));

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Empty — tap + to add an item.'));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, i) {
              final item = items[i];
              return Dismissible(
                key: ValueKey(item.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Theme.of(context).colorScheme.errorContainer,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  child: const Icon(Icons.delete),
                ),
                onDismissed: (_) =>
                    ref.read(listsRepositoryProvider).deleteItem(item.id),
                child: CheckboxListTile(
                  value: item.done,
                  title: Text(
                    item.label,
                    style: item.done
                        ? const TextStyle(
                            decoration: TextDecoration.lineThrough)
                        : null,
                  ),
                  onChanged: (_) =>
                      ref.read(listsRepositoryProvider).toggleItem(item),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addItem(context, ref),
        tooltip: 'Add item',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _addItem(BuildContext context, WidgetRef ref) async {
    final label = await promptForText(context, title: 'Add item', hint: 'Item');
    if (label != null && label.isNotEmpty) {
      await ref.read(listsRepositoryProvider).addItem(listId, label);
    }
  }
}
