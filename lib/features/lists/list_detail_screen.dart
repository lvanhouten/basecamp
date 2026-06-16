import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/app_db.dart';
import '../../core/providers.dart';
import 'data/apply_reorder.dart';
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
          // watchItems already emits unchecked-first (done ASC) then position
          // ASC, so we partition by walking it in order — never re-sort
          // (handoff 01). The unchecked group are the reorderable children; the
          // checked group lives in the header so a drag can't cross the done
          // boundary and checked-sink stays primary (ADR-0002).
          final unchecked = items.where((i) => !i.done).toList();
          final checked = items.where((i) => i.done).toList();

          return ReorderableListView(
            buildDefaultDragHandles: false,
            footer: checked.isEmpty
                ? null
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final item in checked)
                        _ItemRow(
                          key: ValueKey('item-${item.id}'),
                          item: item,
                        ),
                    ],
                  ),
            // Classic onReorder convention (raw oldIndex/newIndex): applyReorder
            // (brief 01) owns the move-down off-by-one, so we must NOT switch to
            // onReorderItem, which pre-adjusts newIndex and would double-correct
            // (handoff 03). Deprecation is info-level only.
            // ignore: deprecated_member_use
            onReorder: (oldIndex, newIndex) {
              // Reorder is scoped to the unchecked group only: build the new id
              // order for THAT group and persist it (handoff 01 / ADR-0002).
              final ids = unchecked.map((i) => i.id).toList();
              final reordered = applyReorder(ids, oldIndex, newIndex);
              ref.read(listsRepositoryProvider).reorderItems(reordered);
            },
            children: [
              for (var i = 0; i < unchecked.length; i++)
                _ItemRow(
                  // Stable per-row key keyed by id so Dismissible/reorder track
                  // the right row across rebuilds.
                  key: ValueKey('item-${unchecked[i].id}'),
                  item: unchecked[i],
                  dragIndex: i,
                ),
            ],
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
    // addItem appends to the bottom of the unchecked group (handoff 01).
    if (label != null && label.isNotEmpty) {
      await ref.read(listsRepositoryProvider).addItem(listId, label);
    }
  }
}

/// A single item row. Tap toggles `done` (struck-through when checked), swipe
/// deletes (with undo), long-press opens the Rename/Delete menu. When
/// [dragIndex] is non-null the row is a reorderable child and renders a drag
/// handle; checked rows omit it (they live in the footer and are not
/// reorderable, per ADR-0002).
class _ItemRow extends ConsumerWidget {
  const _ItemRow({super.key, required this.item, this.dragIndex});

  final ListItem item;
  final int? dragIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // A plain ListTile (not CheckboxListTile) so tap-to-toggle and long-press
    // are both first-class onTap/onLongPress handlers, matching 03's row. The
    // checkbox is the leading control; the drag handle the trailing one.
    final tile = ListTile(
      leading: Checkbox(
        value: item.done,
        onChanged: (_) => ref.read(listsRepositoryProvider).toggleItem(item),
      ),
      title: Text(
        item.label,
        style: item.done
            ? const TextStyle(decoration: TextDecoration.lineThrough)
            : null,
      ),
      // Tap anywhere on the row toggles done; long-press opens the menu.
      onTap: () => ref.read(listsRepositoryProvider).toggleItem(item),
      onLongPress: () => _showActions(context, ref),
      // The drag handle is a separate control; only it starts a reorder, so the
      // row's tap-to-toggle, swipe and long-press gestures stay free.
      trailing: dragIndex != null
          ? ReorderableDragStartListener(
              index: dragIndex!,
              child: const Icon(Icons.drag_handle),
            )
          : null,
    );

    return Dismissible(
      key: ValueKey('dismiss-${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Theme.of(context).colorScheme.errorContainer,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete),
      ),
      onDismissed: (_) => _deleteWithUndo(context, ref),
      child: tile,
    );
  }

  /// Opens the Rename/Delete bottom-sheet menu.
  Future<void> _showActions(BuildContext context, WidgetRef ref) async {
    final action = await showModalBottomSheet<_ItemAction>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Rename'),
              onTap: () => Navigator.of(sheetContext).pop(_ItemAction.rename),
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () => Navigator.of(sheetContext).pop(_ItemAction.delete),
            ),
          ],
        ),
      ),
    );
    if (action == null || !context.mounted) return;

    switch (action) {
      case _ItemAction.rename:
        final label = await promptForText(
          context,
          title: 'Rename item',
          hint: 'Item',
          initialValue: item.label,
          actionLabel: 'Save',
        );
        // Empty-after-trim returns '' (not null) — guard isNotEmpty (handoff 02).
        if (label != null && label.isNotEmpty) {
          await ref.read(listsRepositoryProvider).renameItem(item.id, label);
        }
      case _ItemAction.delete:
        await _deleteWithUndo(context, ref);
    }
  }

  /// Snapshots the item BEFORE deleting (the old id is gone after delete, and
  /// restore re-inserts with a fresh id — handoff 01), deletes it, then offers
  /// a SnackBar UNDO that restores it. If the SnackBar times out the delete
  /// stands.
  Future<void> _deleteWithUndo(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(listsRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    final snapshot = await repo.snapshotItem(item.id);
    await repo.deleteItem(item.id);

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text('Deleted "${item.label}"'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => repo.restoreItem(snapshot),
        ),
      ),
    );
  }
}

enum _ItemAction { rename, delete }
