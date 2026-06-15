## Agent Brief

**Category:** enhancement
**Summary:** Lists screen gains a Pinned section, drag-handle reorder, a long-press action menu (Pin/Rename/Delete), and undo on delete.

**Current behavior:**
The Lists screen shows every list in creation order with an open-item count chip. A FAB creates a list, swipe deletes a list (cascading to its items) with no undo, and tapping a row opens the list. There is no pin, no reorder, and no rename — anchors the PRD's "the list I use daily is buried" and "one accidental swipe destroys a list" problems.

**Desired behavior:**
- Lists render in the order emitted by the read model (pinned first, then manual position). Pinned lists appear under a **"Pinned" section header/divider**; unpinned lists below it. The header is shown **only when at least one list is pinned**. A pinned list carries a visible pin marker (e.g. a leading pin icon).
- Each row has a **drag handle** for rearranging lists. Reorder is **within a section only** — a list cannot be dragged across the pinned/unpinned boundary (pinning is the only way across). The new order persists and survives cold start.
- A newly created list appears at the **top of the unpinned block**.
- **Long-press** on a row opens a bottom-sheet menu: **Pin/Unpin · Rename · Delete**. Pin/Unpin toggles the pinned state. Rename opens the prefilled text dialog with a "Save" button. Delete removes the list.
- Deleting a list (via swipe **or** the menu) removes it and shows a **SnackBar with an UNDO action** for a few seconds; UNDO restores the list **and all its items**. If the SnackBar times out or the app closes, the delete stands (ephemeral, not a soft-delete).
- Tap still opens the list detail; swipe still deletes (now with undo).

**Key interfaces:**

- Consumes `ListsRepository` methods from `01-data-layer.md`: `setPinned`, `reorderLists`, `renameList`, `deleteList`, `snapshotList`, `restoreList`.
- Consumes the updated `promptForText` (initial value + action label) from `02-prompt-rename.md` for rename.
- Reads `pinned`/`position` off the emitted list rows — no read-model signature change required.
- Uses `ReorderableListView` with a per-row stable key and an explicit drag handle so reorder doesn't capture swipe or long-press.

**Acceptance criteria:**

- [ ] Pinned lists render in a distinct Pinned section; the header is present when ≥1 list is pinned and absent otherwise.
- [ ] Dragging a row's handle reorders the unpinned block and the new order persists (still correct after a cold start).
- [ ] A list cannot be dragged across the pinned/unpinned boundary.
- [ ] Pin/Unpin from the long-press menu moves a list into / out of the Pinned section.
- [ ] Rename from the menu opens a dialog prefilled with the current name and applies the change on Save.
- [ ] Deleting a list (swipe or menu) shows a SnackBar with UNDO; tapping UNDO restores the list and its items.
- [ ] A newly created list appears at the top of the unpinned block.
- [ ] Tap still opens the list detail.
- [ ] Widget test: deleting shows a SnackBar with an UNDO action, and UNDO triggers a restore (verified via an overridden/stubbed repository).
- [ ] Widget test: the Pinned section header renders when a pinned list exists and not when none are pinned.

**Out of scope:**

- Item-level reorder/rename/undo on the detail screen — see `04-detail-screen.md`.
- The `promptForText` signature change itself — see `02-prompt-rename.md`.
- Schema, migration, DAO, and repository methods — see `01-data-layer.md`.

**Depends on:** 01-data-layer (repository methods + `pinned`/`position` on list rows), 02-prompt-rename (rename dialog signature)

**Runtime:** parallel-safe
