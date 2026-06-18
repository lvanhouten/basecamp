import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/tokens.dart';
import '../../core/widgets/components.dart';
import 'data/apply_reorder.dart';
import 'data/lists_dao.dart';
import 'list_detail_screen.dart';

/// Lists overview — every tracked list as a grouped hairline row, pinned ones
/// floated to a top section. A **pushed module route** (brief 04): it keeps its
/// own Scaffold + AppBar and gets a back arrow automatically; there is no drawer.
///
/// Purely presentational over the read model — the partitioning, reorder scope,
/// CRUD and undo behaviour are unchanged (ADR-0002 / handoff 01).
class ListsScreen extends ConsumerWidget {
  const ListsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(listsProvider);
    final tokens = Theme.of(context).extension<BasecampTokens>()!;

    return Scaffold(
      appBar: AppBar(title: const Text('Lists')),
      body: listsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (lists) {
          if (lists.isEmpty) {
            return const _EmptyState('No lists yet. Start one to keep track.');
          }
          // The read model already emits pinned-first then position-asc, so we
          // partition by walking it in order — never re-sort (handoff 01).
          final pinned = lists.where((r) => r.list.pinned).toList();
          final unpinned = lists.where((r) => !r.list.pinned).toList();

          // Pinned rows + their header live in the ReorderableListView's header
          // slot, so they are NOT reorderable children: a drag can't cross the
          // pinned/unpinned boundary, and pinning stays the only way across.
          // Each section is its own hairline-grouped surface (handoff 02).
          return ReorderableListView(
            buildDefaultDragHandles: false,
            padding: EdgeInsets.all(tokens.spacing.gutter),
            header: pinned.isEmpty
                ? null
                : Padding(
                    padding: EdgeInsets.only(bottom: tokens.spacing.s6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _SectionHeader('Pinned'),
                        _ListGroupSurface(
                          children: [
                            for (final row in pinned)
                              _ListRow(
                                key: ValueKey('pinned-${row.list.id}'),
                                row: row,
                              ),
                          ],
                        ),
                      ],
                    ),
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
            // proxyDecorator keeps the dragged row on a clean raised surface
            // (the default Material elevation tint would clash with the brand
            // cards), with the design system's lg shadow.
            proxyDecorator: (child, index, animation) => _DragProxy(child: child),
            children: [
              for (var i = 0; i < unpinned.length; i++)
                _ListRow(
                  // Stable per-row key keyed by id so Dismissible/reorder track
                  // the right row across rebuilds.
                  key: ValueKey('list-${unpinned[i].list.id}'),
                  row: unpinned[i],
                  dragIndex: i,
                  // Grouped surface treatment: rounded ends + hairlines between.
                  isFirst: i == 0,
                  isLast: i == unpinned.length - 1,
                  grouped: true,
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
///
/// [grouped] rows render the hairline-grouped surface treatment directly (the
/// reorderable children can't be wrapped in a single container, so each carries
/// its own surface + position-aware corner radii); pinned rows are wrapped by
/// [_ListGroupSurface] instead and pass [grouped] false.
class _ListRow extends ConsumerWidget {
  const _ListRow({
    super.key,
    required this.row,
    this.dragIndex,
    this.grouped = false,
    this.isFirst = false,
    this.isLast = false,
  });

  final TrackedListWithCount row;
  final int? dragIndex;
  final bool grouped;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tokens = theme.extension<BasecampTokens>()!;

    final item = BcListItem(
      leading: BcListItemIcon(
        row.list.pinned ? Icons.push_pin : Icons.checklist,
      ),
      title: row.list.name,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tabular-figure count of open items (handoff 01 / 02).
          BcBadge(label: '${row.openCount}'),
          if (dragIndex != null) ...[
            SizedBox(width: tokens.spacing.s3),
            // Explicit drag handle: only this widget starts a reorder, so the
            // row's own swipe (Dismissible) and long-press gestures are free.
            ReorderableDragStartListener(
              index: dragIndex!,
              child: Icon(Icons.drag_handle, color: scheme.onSurfaceVariant),
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
    );

    // Long-press isn't a BcListItem affordance, so it's layered on with a
    // GestureDetector wrapping the tappable row.
    final row0 = GestureDetector(
      onLongPress: () => _showActions(context, ref),
      child: item,
    );

    // For grouped reorderable children, each row is its own surface with
    // position-aware corner radii and a hairline below all but the last row, so
    // the section reads as one grouped card (matching BcListGroup) even though
    // ReorderableListView requires flat siblings.
    final content = grouped
        ? DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(isFirst ? tokens.radii.lg : 0),
                bottom: Radius.circular(isLast ? tokens.radii.lg : 0),
              ),
              border: Border(
                left: BorderSide(color: scheme.outlineVariant),
                right: BorderSide(color: scheme.outlineVariant),
                top: BorderSide(color: scheme.outlineVariant),
                bottom: isLast
                    ? BorderSide(color: scheme.outlineVariant)
                    : BorderSide(color: scheme.outlineVariant, width: 0.5),
              ),
            ),
            child: row0,
          )
        : row0;

    return Dismissible(
      key: ValueKey('dismiss-${row.list.id}'),
      direction: DismissDirection.endToStart,
      background: _DismissBackground(scheme: scheme, tokens: tokens),
      onDismissed: (_) => _deleteWithUndo(context, ref),
      child: content,
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

/// Wraps the pinned section's rows in a single hairline-grouped surface, mirroring
/// [BcListGroup] (handoff 02). Used only for the non-reorderable pinned block;
/// the unpinned reorderable children render their own per-row surface instead.
class _ListGroupSurface extends StatelessWidget {
  const _ListGroupSurface({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tokens = theme.extension<BasecampTokens>()!;

    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        rows.add(Divider(
          height: 1,
          thickness: 1,
          color: scheme.outlineVariant,
          indent: tokens.spacing.s5,
          endIndent: 0,
        ));
      }
      rows.add(children[i]);
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(tokens.radii.lg),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: rows),
    );
  }
}

/// The red swipe-to-delete affordance behind a [Dismissible] row, in the design
/// system's danger tint with a soft radius.
class _DismissBackground extends StatelessWidget {
  const _DismissBackground({required this.scheme, required this.tokens});

  final ColorScheme scheme;
  final BasecampTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(tokens.radii.lg),
      ),
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: tokens.spacing.s7),
      child: Icon(Icons.delete, color: scheme.onErrorContainer),
    );
  }
}

/// Raised surface for the row currently being dragged in a ReorderableListView,
/// using the design system's lg shadow instead of Material's elevation tint.
class _DragProxy extends StatelessWidget {
  const _DragProxy({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<BasecampTokens>()!;
    return Material(
      color: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(tokens.radii.lg),
          boxShadow: tokens.shadows.lg,
        ),
        child: child,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<BasecampTokens>()!;
    return Padding(
      padding: EdgeInsets.only(
        left: tokens.spacing.s2,
        bottom: tokens.spacing.s3,
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge
            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
    );
  }
}

/// A single calm brand-voice line for an empty surface — sentence case,
/// emoji-free, centred.
class _EmptyState extends StatelessWidget {
  const _EmptyState(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<BasecampTokens>()!;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.s8),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
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
