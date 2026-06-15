# PRD — Lists: Pin, Rearrange, Rename, Undo-delete

Feature slug: `lists-enhancements` · Designed 2026-06-15 (grilling session)
Related: [ADR-0002](../../adr/0002-item-ordering-checked-sink-primary.md) ·
[Lists README → Planned](../../features/lists/README.md)

## Problem Statement

The Lists module today does full CRUD but has no sense of *priority* or *order*.
Every list sits in fixed creation order, so the list I use daily (Groceries) is
buried under one-off lists. Items inside a list can only sort one way (unchecked
first, oldest first), which is wrong for a grocery run where I want items in the
order I'll walk the store. There's no way to rename a list or an item once
created — a typo means delete-and-recreate. And delete is a single swipe with no
safety net: one accidental swipe destroys a list and all its items with no way
back.

## Solution

Give the Lists module manual ordering and delete-safety, using the words the app
already uses (see CONTEXT.md: **Pin**, **Rearrange**, **Sort**):

- **Pin** the lists I care about so they float to a Pinned section at the top.
- **Rearrange** lists (and items) by dragging, persisting a manual order.
- **Rename** a list or an item in place.
- **Undo** an accidental delete via a few-second toast, on both screens.

For items, manual order coexists with the existing "checked sinks to the bottom"
behaviour: checked-ness stays the primary sort, manual order the secondary — so a
grocery list holds its aisle order among the items still to grab, while backlog
lists (movies, books) keep behaving exactly as they do today (ADR-0002).

## User Stories

1. As a list-keeper, I want to pin a list, so that the one I use most floats to a Pinned section at the top.
2. As a list-keeper, I want to unpin a list, so that it rejoins the ordinary lists below when it's no longer a priority.
3. As a list-keeper, I want pinned lists shown in a visually distinct section (a "Pinned" divider, a pin marker on the row), so that I can tell at a glance which lists are pinned.
4. As a list-keeper, I want the Pinned section to appear only when at least one list is pinned, so that the screen isn't cluttered with an empty header.
5. As a list-keeper, I want to drag a list into a chosen order, so that I can arrange my lists the way I think about them.
6. As a list-keeper, I want my manual list order to persist across app restarts, so that I don't have to re-arrange every launch.
7. As a list-keeper, I want reorder to work within a section only (I can't drag a list across the Pinned/unpinned boundary), so that pinning stays the single, deliberate way to promote a list.
8. As a list-keeper, I want a newly created list to appear at the top of the unpinned lists, so that the list I just made is immediately visible without scrolling.
9. As a list-keeper, I want to rename a list, so that I can fix a typo or repurpose it without losing its items.
10. As a list-keeper, I want the rename dialog pre-filled with the current name, so that I edit rather than retype.
11. As a list-keeper, I want to delete a list and get a brief "undo" option, so that an accidental delete is recoverable.
12. As a list-keeper, I want undoing a list delete to restore the list *and all its items* exactly as they were, so that undo is a true reversal, not a half-restore.
13. As a list-keeper, I want the delete to stand if I ignore the undo toast (or the app closes), so that undo is a safety net, not a confirmation I have to dismiss every time.
14. As a list user, I want to drag items into a chosen order, so that I can arrange a grocery list by store aisle.
15. As a list user, I want checked items to still sink to the bottom, so that the top of the list is always "what's left to do/grab."
16. As a list user, I want my manual item order preserved within the unchecked group, so that crossing items off doesn't scramble the aisle order of what remains.
17. As a list user, I want a list I never reorder to look exactly as it does today (unchecked first, oldest first), so that this feature doesn't disturb my existing lists.
18. As a list user, I want a newly added item to append at the bottom of the unchecked items, so that I add to my list in the order things occur to me.
19. As a list user, I want to rename an item, so that I can correct a typo without re-adding it.
20. As a list user, I want to delete an item with a brief undo option, so that an accidental swipe is recoverable.
21. As a list user, I want to keep checking/unchecking items by tapping the row, so that the most frequent action stays the simplest.
22. As a list-keeper, I want a long-press on a list or item to open a menu (Pin/Rename/Delete), so that the rarer actions are discoverable without crowding the row.
23. As a list-keeper, I want a clear drag handle on each row, so that reordering doesn't fight with swipe-to-delete or tap-to-open.
24. As a list-keeper, I want swipe-to-delete to keep working as the fast path, so that I'm not forced through a menu for the common delete.
25. As a list-keeper, I want all of this to survive a force-stop/cold-start (pins, order, renames), so that the app remembers my arrangement like the rest of the data does.

## Implementation Decisions

### Schema (Drift, v2 — additive)

- `TrackedLists` gains `pinned BOOL NOT NULL DEFAULT false` and `position INT NOT NULL`.
- `ListItems` gains `position INT NOT NULL`.
- `schemaVersion` 1 → 2; `onUpgrade` uses `m.addColumn(...)` for each new column, then backfills `position`:
  - **Lists:** ranked by `createdAt` globally → dense `0,1,2,…`.
  - **Items:** ranked by `createdAt` **partitioned by `listId`** → each list's items numbered `0,1,2,…` independently.
  - Backfill via a window function (`ROW_NUMBER() OVER (PARTITION BY list_id ORDER BY created_at, id)`) or a correlated count — either is fine at this data size.
- `pinned`/`position` are real columns (not the `ModuleData` JSON lane) because the DB sorts/filters by them (hard rule #4).
- `beforeOpen` `PRAGMA foreign_keys = ON` and the existing `onDelete: cascade` on `ListItems.listId` are unchanged.

### Sort keys

- Lists: `pinned DESC, position ASC`.
- Items: `done ASC, position ASC` (ADR-0002 — checked-sink primary, manual order secondary).

### Position assignment

- New list → `position = MIN(position) - 1` over all lists, `pinned = false` (sorts to top of the unpinned block; pinned still float above via `pinned DESC`).
- New item → `position = MAX(position) + 1` within its `listId` (appends to the bottom).
- Reorder → renumber the affected section to a contiguous `0..n` in a single transaction.

### Reorder positioning logic (pure module — extracted)

A pure helper owns the `ReorderableListView` index math (the move-down off-by-one
is the classic bug), so it's unit-testable with no DB. Decision-encoding shape:

```
// Given the section's row ids in current display order and a drag move,
// return the ids in their new order. Caller persists position = newIndex.
List<int> applyReorder(List<int> orderedIds, int oldIndex, int newIndex);
```

The DAO's `reorderLists`/`reorderItems` call this, then write `position` =
list index for each id in one transaction.

### ListsDao (deep module — the correctness core)

- Change `watchLists` sort to `pinned DESC, position ASC`; `watchItems` to `done ASC, position ASC`.
- Add `setPinned(int listId, bool pinned)`.
- `createList`/`addItem` compute `position` per the rules above (read MIN/MAX in the same transaction as the insert).
- Add `reorderLists(List<int> orderedIds)` and `reorderItems(int listId, List<int> orderedIds)` — renumber via `applyReorder` + transactional writes.
- Add `renameList(int id, String name)` and `renameItem(int id, String label)`.
- `deleteList`/`deleteItem` stay hard deletes (no soft-delete column).
- Add `snapshotList(int id)` → returns the `TrackedList` + its `ListItem`s for the undo buffer, and `restoreList(snapshot)` → re-inserts list + items in one transaction (new autoincrement ids are fine; nothing durable references the old ones). Add the trivial `snapshotItem`/`restoreItem` equivalents for item undo.

### ListsRepository (thin facade)

- Pass-throughs for `setPinned`, `reorderLists`, `reorderItems`, `renameList`, `renameItem`, `snapshotList`/`restoreList`, `snapshotItem`/`restoreItem`.
- Keep the existing `ListItemToggled` publish on `toggleItem` (a live signal only; the Drift write is the durable effect).
- `ListsApi` (`watchOpenItemCount`, `watchListCount`) is **unchanged** — pin/order are aggregate-invariant and stay internal to the module (no cross-module leakage; the Brief is untouched). The "surface the pinned list on the Brief" idea is recorded under Future Enhancements, out of scope here.

### UI — `promptForText`

- Add optional `String? initialValue` (pre-fills + selects the field) and `String actionLabel = 'Add'` (rename passes `'Save'`).

### UI — gesture model (both screens)

- **Tap** → open list (lists screen) / toggle done (detail screen) — unchanged.
- **Drag handle** (trailing grip) → reorder via `ReorderableListView`.
- **Long-press** row → bottom-sheet menu: lists = Pin/Unpin · Rename · Delete; items = Rename · Delete.
- **Swipe** end-to-start → delete (fast path), now followed by the undo SnackBar.
- Pinned state shown in the leading slot (pushpin icon when pinned, else the `checklist` icon) plus placement in the Pinned section.

### UI — undo delete (both screens)

- On delete (swipe or menu): capture the snapshot, perform the hard delete, show a Material `SnackBar` "List/Item deleted · UNDO" for ~4s.
- UNDO → `restoreList`/`restoreItem` from the captured snapshot.
- Ephemeral by design: if the toast times out or the app dies during the window, the delete stands (it's an accident safety-net, not a soft-delete/archive). No schema involvement.

## Testing Decisions

Good tests here assert **observable behaviour through a module's public interface**
— the *order* a query stream emits, whether a restored list has its items back,
whether an empty Pinned section is hidden — never private field values or the
exact SQL. All three modules get coverage (user's call):

### ListsDao + migration (in-memory Drift)

Prior art: `AppDb.forTesting(e)` already exists for this; instantiate with
`NativeDatabase.memory()`. No DAO test exists yet, so this is the new baseline.

- **Sort:** `watchLists` emits pinned-first then by position; `watchItems` emits unchecked-before-checked then by position.
- **No regression:** a list whose items were never reordered emits in unchecked-first, oldest-first order (matches v1).
- **Placement:** a new list lands at the top of the unpinned block; a new item appends to the bottom of the unchecked group.
- **Pin:** `setPinned(true)` floats a list above unpinned ones regardless of its position; unpin returns it to position order.
- **Reorder:** `reorderItems`/`reorderLists` produce the expected emitted order, including a move-down (off-by-one) and a move to first/last.
- **Undo round-trip:** `snapshotList` then `deleteList` then `restoreList` yields a list with the same name and the same item set (labels + done states) it had before.
- **Migration:** open a v1 DB seeded with lists/items, upgrade to v2, assert positions are dense and per-list contiguous and that the emitted order is unchanged from v1.

### Reorder helper (pure unit)

- `applyReorder` for: move up, move down, move to first, move to last, no-op (oldIndex == newIndex), single-element and two-element lists. Fast, no DB.

### UI / widget behaviours (testWidgets + ProviderScope overrides)

Prior art: `test/widget_test.dart` (override the lists stream providers, pump,
assert on rendered widgets / provider state).

- Deleting a row shows a SnackBar with an UNDO action; tapping UNDO calls restore (assert via a stubbed repository / overridden provider).
- The Pinned section header renders when a pinned list is present and is absent when none are.
- Rename opens the dialog pre-filled with the current text.
- (Drag reorder is exercised primarily at the DAO + helper level; a single happy-path widget drag is optional given how fiddly `ReorderableListView` drag simulation is.)

## Out of Scope

- **Checked-items-frozen-in-place** (a stable aisle map where checked items don't sink) — deferred per-list opt-in (ADR-0002, Open questions).
- **Per-list sort/behaviour settings** — rejected for this iteration (ADR-0002).
- **Surfacing the pinned list on the Brief** — recorded in Future Enhancements; contract stays unchanged here.
- **Manual ordering across lists** (dragging an item from one list to another).
- **Archive vs delete / "clear completed"** — separate idea in Open questions.
- **Per-list icon/colour, item notes/quantities/due dates** — Open questions; only promote to columns when queried/sorted.
- **Sync / multi-device** — project-level deferral; data layer stays local-first.

## Further Notes

- `ReorderableListView` + `Dismissible` rows coexist but are finicky; each row needs a stable `ValueKey(id)`, and reorder is driven by the explicit drag handle (`ReorderableDragStartListener`) so it doesn't capture the swipe or long-press.
- After editing tables/DAO, run `flutter pub run build_runner build` — nothing compiles until the `*.g.dart` is regenerated. A full app relaunch (not just hot reload) is safest after the schema/migration change.
- Bumping `schemaVersion` means the migration runs on the next launch against existing on-device data — the migration test above is the guard that real lists don't get scrambled.
- The two new-placement rules are deliberately opposite (new list → top, new item → bottom); this is intentional, not an inconsistency (arranging a shelf of lists vs. appending to one list).
