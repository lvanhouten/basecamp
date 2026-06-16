# Execution status — lists-enhancements

| Brief | Status | Wave | Merged SHA | Criteria | Note |
|---|---|---|---|---|---|
| 01-data-layer    | integrated | 1 | 5e5fdb6 | 12/12 | partial→verified centrally; build_runner output == hand-roll |
| 02-prompt-rename | integrated | 1 | 7262c78 | 5/5 | partial→verified; tests run centrally |
| 03-lists-screen  | running    | 2 | — | — | depends on 01, 02 |
| 04-detail-screen | running    | 2 | — | — | depends on 01, 02 |

## Handoff notes
- **02-prompt-rename → [03-lists-screen, 04-detail-screen]:** `promptForText(context, {required String title, required String hint, String? initialValue, String actionLabel = 'Add'})`. Top-level function in `lib/features/lists/lists_screen.dart` (location unchanged). Rename callers pass `initialValue: <current text>` and `actionLabel: 'Save'`. Return contract unchanged: trimmed text on confirm, null on cancel; empty-after-trim returns `''` (not null) — callers must still guard `isNotEmpty`. (contract-change)
- **01-data-layer → [03-lists-screen, 04-detail-screen]:** Reorder is **section-scoped, never across the pinned/unpinned (lists) or done (items) boundary**. The UI calls `applyReorder(orderedIds, oldIndex, newIndex)` on a **single section's** ids, then passes that exact id list to `repository.reorderLists(ids)` / `reorderItems(ids)`, which renumbers `position = 0..n` for those ids only. Never pass the full mixed list. (constraint)
- **01-data-layer → [03-lists-screen, 04-detail-screen]:** Undo is built on `snapshotList`/`restoreList` and `snapshotItem`/`restoreItem`. `restore*` re-inserts with **fresh autoincrement ids** (old id is gone) and returns the new id — **capture the snapshot BEFORE calling `deleteList`/`deleteItem`**. `ListSnapshot` lives in `lists_dao.dart`. (constraint)
- **01-data-layer → [03-lists-screen, 04-detail-screen]:** Repository surface added: `setPinned(listId, bool)`, `renameList(listId, name)`, `renameItem(itemId, label)`, `reorderLists(ids)`, `reorderItems(ids)`, `snapshotList`/`restoreList`, `snapshotItem`/`restoreItem`. `createList`/`addItem`/`toggleItem`/`deleteList`/`deleteItem`/`watchLists`/`watchItems` signatures UNCHANGED. `ListsApi` unchanged (pin/order stay module-internal). List rows now carry `pinned`/`position`; item rows carry `position`. (contract-change)

## Deviations
- **02-prompt-rename:** Could not run `flutter pub get`/`analyze`/`test` in the worker (background-agent permission layer denies un-allowlisted Bash). Implementation static-verified only; **runtime verification performed centrally by the orchestrator** — all 5 criteria pass via `flutter test test/widget_test.dart` (9/9 incl. baseline). No spec departure in the code itself.
- **02 (process):** worker's first edits landed in the main checkout by absolute-path mistake, then were `git restore`d; committed work lives only in worktree `c7b5d76`. Main tree confirmed clean before merge.
- **01-data-layer:** Same toolchain block — worker could not run `pub get`/`build_runner`/`analyze`/`test`, so it **hand-regenerated `app_db.g.dart`**. Orchestrator re-ran real `build_runner`: output is **content-identical** to the hand-roll (zero diff). Full suite green centrally (43/43), `analyze` clean. No spec departure.
- **01-data-layer (benign refinement):** added a stable `id` tiebreaker to `watchLists`/`watchItems` `ORDER BY` (pinned/done, position, **then id**) to prevent flicker on equal positions. Strict refinement — does not change emitted order for any tested case, and does **not** invalidate any premise in 03/04 (both consume emitted order as-is). No brief amendment needed.
