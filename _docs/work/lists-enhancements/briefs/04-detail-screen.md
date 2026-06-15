## Agent Brief

**Category:** enhancement
**Summary:** List detail screen gains drag-handle item reorder, a long-press action menu (Rename/Delete), and undo on item delete.

**Current behavior:**
The detail screen shows a list's items, unchecked first then by creation. Tapping a row toggles `done` (with strikethrough); a FAB adds an item; swipe deletes an item with no undo. There is no manual reorder and no rename — anchors the PRD's "I want grocery items in store-aisle order" and accidental-delete problems.

**Desired behavior:**
- Items render in emitted order: **unchecked before checked, manual position within each group** — so a hand-picked aisle order holds among the items still to grab, while checked items still sink. A list never reordered looks exactly as it does today.
- Each row has a **drag handle** to rearrange items; the new order persists and survives cold start. Checking an item still sinks it; unchecking returns it to its position among the unchecked (per ADR-0002 — manual order never overrides checked-sink).
- A newly added item appends to the **bottom of the unchecked items**.
- **Long-press** on a row opens a bottom-sheet menu: **Rename · Delete**. Rename opens the prefilled text dialog with a "Save" button. Delete removes the item.
- Deleting an item (via swipe **or** the menu) removes it and shows a **SnackBar with an UNDO action** for a few seconds; UNDO restores the item. If it times out or the app closes, the delete stands.
- Tap still toggles `done`; swipe still deletes (now with undo).

**Key interfaces:**

- Consumes `ListsRepository` methods from `01-data-layer.md`: `reorderItems`, `renameItem`, `deleteItem`, `snapshotItem`, `restoreItem` (alongside existing `toggleItem`/`addItem`).
- Consumes the updated `promptForText` (initial value + action label) from `02-prompt-rename.md` for rename.
- Uses `ReorderableListView` with a per-row stable key and an explicit drag handle so reorder doesn't capture the tap-to-toggle or swipe-to-delete gestures.

**Acceptance criteria:**

- [ ] Items render unchecked-first, checked-last, with manual position honored within each group.
- [ ] Dragging an item's handle reorders it within the unchecked group and the order persists across a cold start.
- [ ] Checking an item still sinks it to the bottom; unchecking returns it to its position among the unchecked.
- [ ] A newly added item appears at the bottom of the unchecked items.
- [ ] Rename from the menu opens a dialog prefilled with the current label and applies the change on Save.
- [ ] Deleting an item (swipe or menu) shows a SnackBar with UNDO; tapping UNDO restores the item.
- [ ] Tap still toggles `done` (checked items shown struck-through).
- [ ] Widget test: deleting an item shows a SnackBar with an UNDO action, and UNDO triggers a restore (verified via an overridden/stubbed repository).

**Out of scope:**

- List-level pin/reorder/rename/undo — see `03-lists-screen.md`.
- The `promptForText` signature change itself — see `02-prompt-rename.md`.
- Schema, migration, DAO, and repository methods — see `01-data-layer.md`.
- Manual ordering that overrides checked-sink, or frozen-in-place checked items — out of scope per ADR-0002.

**Depends on:** 01-data-layer (repository methods + `position` on items), 02-prompt-rename (rename dialog signature)

**Runtime:** parallel-safe
