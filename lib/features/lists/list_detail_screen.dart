import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/app_db.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../core/tokens.dart';
import '../../core/widgets/components.dart';
import 'data/apply_reorder.dart';
import 'lists_screen.dart' show promptForText;

/// List detail — a list's items as checkable hairline rows, checked ones sunk to
/// a footer group (ADR-0002). A **pushed module route** (brief 04): it keeps its
/// own Scaffold + AppBar and gets a back arrow automatically; there is no drawer.
///
/// Purely presentational over the read model — partitioning, reorder scope,
/// checked-sink, CRUD and undo are unchanged (handoff 01 / ADR-0002).
class ListDetailScreen extends ConsumerWidget {
  const ListDetailScreen({super.key, required this.listId, required this.title});

  final int listId;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(listItemsProvider(listId));
    final tokens = Theme.of(context).extension<BasecampTokens>()!;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          if (items.isEmpty) {
            return const _EmptyState('Nothing here yet. Add the first item.');
          }
          // watchItems already emits unchecked-first (done ASC) then position
          // ASC, so we partition by walking it in order — never re-sort
          // (handoff 01). The unchecked group are the reorderable children; the
          // checked group lives in the footer so a drag can't cross the done
          // boundary and checked-sink stays primary (ADR-0002).
          final unchecked = items.where((i) => !i.done).toList();
          final checked = items.where((i) => i.done).toList();
          final doneCount = checked.length;

          return ReorderableListView(
            buildDefaultDragHandles: false,
            padding: EdgeInsets.all(tokens.spacing.gutter),
            header: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ProgressSummary(done: doneCount, total: items.length),
                SizedBox(height: tokens.spacing.s6),
              ],
            ),
            footer: checked.isEmpty
                ? null
                : Padding(
                    padding: EdgeInsets.only(top: tokens.spacing.s2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < checked.length; i++)
                          _ItemRow(
                            key: ValueKey('item-${checked[i].id}'),
                            item: checked[i],
                            isFirst: i == 0,
                            isLast: i == checked.length - 1,
                          ),
                      ],
                    ),
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
            proxyDecorator: (child, index, animation) => _DragProxy(child: child),
            children: [
              for (var i = 0; i < unchecked.length; i++)
                _ItemRow(
                  // Stable per-row key keyed by id so Dismissible/reorder track
                  // the right row across rebuilds.
                  key: ValueKey('item-${unchecked[i].id}'),
                  item: unchecked[i],
                  dragIndex: i,
                  isFirst: i == 0,
                  isLast: i == unchecked.length - 1,
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
///
/// Each row carries its own hairline-grouped surface with position-aware corner
/// radii (the reorderable children can't share one container, so the section
/// reads as a grouped card the way [BcListGroup] does — handoff 02).
class _ItemRow extends ConsumerWidget {
  const _ItemRow({
    super.key,
    required this.item,
    this.dragIndex,
    this.isFirst = false,
    this.isLast = false,
  });

  final ListItem item;
  final int? dragIndex;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tokens = theme.extension<BasecampTokens>()!;

    // The themed Checkbox (brand fill when checked — handoff 01) is the leading
    // control; tapping the row anywhere toggles done (matching prior behaviour),
    // and BcListItem's `done` flag strikes through the title.
    final row = BcListItem(
      leading: Checkbox(
        value: item.done,
        onChanged: (_) => ref.read(listsRepositoryProvider).toggleItem(item),
      ),
      title: item.label,
      done: item.done,
      onTap: () => ref.read(listsRepositoryProvider).toggleItem(item),
      // The drag handle is a separate control; only it starts a reorder, so the
      // row's tap-to-toggle, swipe and long-press gestures stay free.
      trailing: dragIndex != null
          ? ReorderableDragStartListener(
              index: dragIndex!,
              child: Icon(Icons.drag_handle, color: scheme.onSurfaceVariant),
            )
          : null,
    );

    // Long-press isn't a BcListItem affordance, so it's layered on with a
    // GestureDetector wrapping the tappable row.
    final gestured = GestureDetector(
      onLongPress: () => _showActions(context, ref),
      child: row,
    );

    final surfaced = DecoratedBox(
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
      child: gestured,
    );

    return Dismissible(
      key: ValueKey('dismiss-${item.id}'),
      direction: DismissDirection.endToStart,
      background: _DismissBackground(scheme: scheme, tokens: tokens),
      onDismissed: (_) => _deleteWithUndo(context, ref),
      child: surfaced,
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

/// The list-detail summary card: a [ProgressRing] of completion plus a calm
/// brand-voice line of how many remain. Counts use tabular figures (handoff 01).
class _ProgressSummary extends StatelessWidget {
  const _ProgressSummary({required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tokens = theme.extension<BasecampTokens>()!;
    final remaining = total - done;
    final fraction = total == 0 ? 0.0 : done / total;

    final caption = remaining == 0
        ? 'All done'
        : '$remaining ${remaining == 1 ? 'item' : 'items'} left';

    return Container(
      padding: EdgeInsets.all(tokens.spacing.s5),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(tokens.radii.lg),
        border: Border.all(color: scheme.outlineVariant),
        boxShadow: tokens.shadows.sm,
      ),
      child: Row(
        children: [
          ProgressRing(
            value: fraction,
            size: 56,
            label: Text(
              '$done/$total',
              style: numericTextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
          ),
          SizedBox(width: tokens.spacing.s5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(caption, style: theme.textTheme.titleSmall),
                SizedBox(height: tokens.spacing.s1),
                Text(
                  '$done of $total done',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
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
