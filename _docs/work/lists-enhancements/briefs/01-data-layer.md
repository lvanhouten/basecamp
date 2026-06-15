## Agent Brief

**Category:** enhancement
**Summary:** Add pin/position persistence, a v2 migration, the pure reorder helper, and the DAO + repository methods the Lists UI will call.

**Current behavior:**
The Lists data layer (`TrackedLists`, `ListItems`, `ListsDao`, `ListsRepository`) supports plain CRUD. Lists are emitted in creation order; items are emitted unchecked-first then oldest-first. There is no pin, no manual order, no rename, and no way to restore a deleted row. The database schema version is 1. Anchors the PRD's problem: lists sit in fixed creation order, items can only sort one way, and there is no rename or undo.

**Desired behavior:**
- `TrackedLists` gains a `pinned` boolean (default false) and an integer `position`. `ListItems` gains an integer `position`. These are real, sortable columns (not the JSON lane).
- Schema version becomes 2 via an **additive** migration that adds the new columns and backfills `position` so existing data's visible order is unchanged: lists ranked by `createdAt` globally into dense `0..n`; items ranked by `createdAt` **within each list** into dense `0..n` per list.
- `watchLists` emits ordered by **pinned-desc, then position-asc**. `watchItems` emits ordered by **done-asc, then position-asc** — checked items still sink; manual order is honored *within* each group (per ADR-0002).
- Creating a list assigns `pinned = false` and a `position` that places it at the **top of the unpinned block** (below `MIN(position)` across lists). Adding an item assigns a `position` that **appends it to the bottom** of its list.
- A pure helper turns a drag move into a new id order; the DAO uses it to persist a contiguous `0..n` renumber of the affected **section** in a single transaction. The caller passes the section's ids — reorder never crosses the pinned/unpinned boundary.
- `setPinned` toggles a list's pinned flag. `renameList` / `renameItem` update name / label. `deleteList` / `deleteItem` remain **hard deletes** (cascade preserved for lists).
- `snapshotList` returns a list together with its items; `restoreList` re-inserts the list and its items in one transaction (fresh autoincrement ids are acceptable — nothing durable references the old ones). `snapshotItem` / `restoreItem` do the same for a single item. These back the UI's ephemeral undo.
- `ListsRepository` exposes pass-throughs for all the above and keeps publishing `ListItemToggled` on toggle.

**Key interfaces:**

- `TrackedLists` — add `pinned` (bool, default false) and `position` (int).
- `ListItems` — add `position` (int).
- `AppDb.schemaVersion` 1 → 2; migration adds the columns and backfills `position` (window function `ROW_NUMBER() OVER (PARTITION BY list_id ORDER BY created_at, id)` or a correlated count — either is fine at this size).
- `applyReorder(List<int> orderedIds, int oldIndex, int newIndex) -> List<int>` — **pure**, in its own module/file, separately unit-tested. Owns the `ReorderableListView` index math (including the move-down off-by-one). Returns the ids in their new display order; the DAO writes `position = index`.
- `ListsDao` — change the sort on `watchLists`/`watchItems`; add `setPinned`, `reorderLists`, `reorderItems`, `renameList`, `renameItem`, `snapshotList`, `restoreList`, `snapshotItem`, `restoreItem`; assign `position` in `createList`/`addItem`.
- `ListsRepository` — pass-throughs for the new DAO methods; `ListItemToggled` publish preserved.
- `ListsApi` — **unchanged**; do not widen it (pin/order stay internal to the module).

**Acceptance criteria:**

- [ ] `watchLists` emits pinned lists before unpinned, each group ordered by `position` ascending.
- [ ] `watchItems` emits unchecked before checked, each group ordered by `position` ascending.
- [ ] A list/items never reordered emits in the same order as before the feature (unchecked-first, oldest-first) — no regression.
- [ ] `createList` places the new list at the top of the unpinned block.
- [ ] `addItem` appends the new item to the bottom of its list.
- [ ] `setPinned(true)` floats a list above all unpinned lists regardless of its position; `setPinned(false)` returns it to position order.
- [ ] `reorderLists` and `reorderItems` produce the expected emitted order for move-up, move-down, move-to-first, and move-to-last.
- [ ] `applyReorder` is covered by pure unit tests for move up/down/first/last, a no-op (`oldIndex == newIndex`), and 1- and 2-element lists.
- [ ] `snapshotList` → `deleteList` → `restoreList` yields a list with the same name and the same set of items (labels + done states) it had before deletion.
- [ ] Upgrading a v1 database seeded with lists and items to v2 backfills `position` to dense, per-list-contiguous values and leaves the emitted order identical to v1.
- [ ] `renameList` / `renameItem` change the name / label; `deleteList` / `deleteItem` still hard-delete (list delete still cascades to items).
- [ ] `ListsApi` (`watchOpenItemCount`, `watchListCount`) is unchanged and its existing behavior holds.

**Out of scope:**

- All UI — `ReorderableListView`, menus, SnackBar, pinned-section rendering — see `03-lists-screen.md` and `04-detail-screen.md`.
- The `promptForText` dialog change — see `02-prompt-rename.md`.
- Soft-delete / archive columns — undo is ephemeral and built in the UI briefs on top of the snapshot/restore methods here.
- Surfacing the pinned list on the Brief, per-list sort settings, frozen-checked mode — PRD Out of Scope.

**Depends on:** none

**Runtime:** parallel-safe
