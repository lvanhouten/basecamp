/// Pure helper that turns a single `ReorderableListView` drag into the new
/// display order of a section's ids.
///
/// It owns the `ReorderableListView.onReorder` index convention: when an item
/// is dragged *downward*, Flutter reports `newIndex` as one past the slot the
/// item will occupy (it counts the position before the dragged item is removed
/// from the list). This is the classic move-down off-by-one — adjust by
/// decrementing `newIndex` when it is greater than `oldIndex`.
///
/// Returns the ids in their new display order; the DAO writes `position = index`
/// for each. Kept pure (no Drift, no IO) so it can be unit-tested in isolation.
///
/// The caller passes only one section's ids (e.g. the unpinned lists, or the
/// unchecked items) — reorder never crosses the pinned/unpinned or done-group
/// boundary (ADR-0002).
List<int> applyReorder(List<int> orderedIds, int oldIndex, int newIndex) {
  // Defensive copy: never mutate the caller's list.
  final ids = List<int>.of(orderedIds);

  // Flutter's move-down off-by-one: dragging down reports newIndex as the slot
  // index *before* the dragged element is removed.
  if (newIndex > oldIndex) {
    newIndex -= 1;
  }

  if (oldIndex == newIndex) {
    return ids; // no-op (already a fresh copy)
  }

  final moved = ids.removeAt(oldIndex);
  ids.insert(newIndex, moved);
  return ids;
}
