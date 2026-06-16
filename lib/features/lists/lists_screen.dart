import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/widgets/app_drawer.dart';
import 'data/apply_reorder.dart';
import 'data/lists_dao.dart';
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
          // The read model already emits pinned-first then position-asc, so we
          // partition by walking it in order — never re-sort (handoff 01).
          final pinned = lists.where((r) => r.list.pinned).toList();
          final unpinned = lists.where((r) => !r.list.pinned).toList();

          // Pinned rows + their header live in the ReorderableListView's header
          // slot, so they are NOT reorderable children: a drag can't cross the
          // pinned/unpinned boundary, and pinning stays the only way across.
          return ReorderableListView(
            buildDefaultDragHandles: false,
            header: pinned.isEmpty
                ? null
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _SectionHeader('Pinned'),
                      for (final row in pinned)
                        _ListRow(
                          key: ValueKey('pinned-${row.list.id}'),
                          row: row,
                        ),
                      const Divider(height: 1),
                    ],
                  ),
            // Uses the classic onReorder convention (raw oldIndex/newIndex):
            // applyReorder (brief 01) owns the move-down off-by-one, so we must
            // NOT switch to onReorderItem, which pre-adjusts newIndex and would
            // double-correct. Deprecation is info-level only.
            // ignore: deprecated_member_use
            onReorder: (oldIndex, newIndex) {
              // Reorder is scoped to the unpinned section only: build the new
              // id order for THAT section and persist it (handoff 01).
              final ids = unpinned.map((r) => r.list.id).toList();
              final reordered = applyReorder(ids, oldIndex, newIndex);
              ref.read(listsRepositoryProvider).reorderLists(reordered);
            },
            children: [
              for (var i = 0; i < unpinned.length; i++)
                _ListRow(
                  // Stable per-row key keyed by id so Dismissible/reorder track
                  // the right row across rebuilds.
                  key: ValueKey('list-${unpinned[i].list.id}'),
                  row: unpinned[i],
                  dragIndex: i,
                ),
            ],
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
    final name =
        await promptForText(context, title: 'New list', hint: 'List name');
    if (name != null && name.isNotEmpty) {
      // createList places the new list at the top of the unpinned block.
      await ref.read(listsRepositoryProvider).createList(name);
    }
  }
}

/// A single list row. Swipe deletes (with undo), tap opens the detail,
/// long-press opens the action menu. When [dragIndex] is non-null the row is a
/// reorderable child and renders a drag handle; pinned rows omit it (they live
/// in the header and are not reorderable).
class _ListRow extends ConsumerWidget {
  const _ListRow({super.key, required this.row, this.dragIndex});

  final TrackedListWithCount row;
  final int? dragIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tile = ListTile(
      leading: row.list.pinned
          ? const Icon(Icons.push_pin)
          : const Icon(Icons.checklist),
      title: Text(row.list.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Chip(label: Text('${row.openCount}')),
          if (dragIndex != null) ...[
            const SizedBox(width: 8),
            // Explicit drag handle: only this widget starts a reorder, so the
            // row's own swipe (Dismissible) and long-press gestures are free.
            ReorderableDragStartListener(
              index: dragIndex!,
              child: const Icon(Icons.drag_handle),
            ),
          ],
        ],
      ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ListDetailScreen(
            listId: row.list.id,
            title: row.list.name,
          ),
        ),
      ),
      onLongPress: () => _showActions(context, ref),
    );

    return Dismissible(
      key: ValueKey('dismiss-${row.list.id}'),
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

  /// Opens the Pin/Rename/Delete bottom-sheet menu.
  Future<void> _showActions(BuildContext context, WidgetRef ref) async {
    final pinned = row.list.pinned;
    final action = await showModalBottomSheet<_ListAction>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(pinned ? Icons.push_pin_outlined : Icons.push_pin),
              title: Text(pinned ? 'Unpin' : 'Pin'),
              onTap: () =>
                  Navigator.of(sheetContext).pop(_ListAction.togglePin),
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Rename'),
              onTap: () => Navigator.of(sheetContext).pop(_ListAction.rename),
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () => Navigator.of(sheetContext).pop(_ListAction.delete),
            ),
          ],
        ),
      ),
    );
    if (action == null || !context.mounted) return;

    switch (action) {
      case _ListAction.togglePin:
        await ref.read(listsRepositoryProvider).setPinned(row.list.id, !pinned);
      case _ListAction.rename:
        if (!context.mounted) return;
        final name = await promptForText(
          context,
          title: 'Rename list',
          hint: 'List name',
          initialValue: row.list.name,
          actionLabel: 'Save',
        );
        // Empty-after-trim returns '' (not null) — guard isNotEmpty (handoff 02).
        if (name != null && name.isNotEmpty) {
          await ref.read(listsRepositoryProvider).renameList(row.list.id, name);
        }
      case _ListAction.delete:
        await _deleteWithUndo(context, ref);
    }
  }

  /// Snapshots the list BEFORE deleting (the old id is gone after delete —
  /// handoff 01), deletes it, then offers a SnackBar UNDO that restores the
  /// list and all its items. If the SnackBar times out the delete stands.
  Future<void> _deleteWithUndo(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(listsRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    final snapshot = await repo.snapshotList(row.list.id);
    await repo.deleteList(row.list.id);

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text('Deleted "${row.list.name}"'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => repo.restoreList(snapshot),
        ),
      ),
    );
  }
}

enum _ListAction { togglePin, rename, delete }

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        label,
        style: theme.textTheme.labelLarge
            ?.copyWith(color: theme.colorScheme.primary),
      ),
    );
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
