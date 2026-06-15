## Agent Brief

**Category:** enhancement
**Summary:** Extend the shared single-field text dialog so it can edit existing text (rename), not just add.

**Current behavior:**
The shared `promptForText` dialog always opens with an empty field and labels its confirm button "Add". It's used to create a list and to add an item, and returns the trimmed text or null on cancel. There is no way to seed it with existing text, so renaming a list or item is impossible — anchors the PRD's "a typo means delete-and-recreate" problem.

**Desired behavior:**
- The dialog optionally pre-fills with an existing value and uses a configurable confirm-button label, so the same helper serves both add and rename.
- When an initial value is supplied, the field shows that text (ideally pre-selected for easy replacement).
- The confirm-button label defaults to "Add" (existing callers unchanged) and rename callers pass "Save".
- The return contract is unchanged: trimmed text on confirm, null on cancel.

**Key interfaces:**

- `promptForText(context, {required title, required hint, String? initialValue, String actionLabel = 'Add'})` — add the two optional parameters; preserve the existing return value and trimming behavior.

**Acceptance criteria:**

- [ ] Called with no initial value, the dialog behaves exactly as today: empty field, "Add" button.
- [ ] Called with an initial value, the field is pre-filled with that text.
- [ ] The confirm button displays the supplied action label ("Save" for rename callers).
- [ ] Returns the trimmed input on confirm and null on cancel.
- [ ] Existing callers (create list, add item) compile and behave unchanged.

**Out of scope:**

- Wiring rename into the screens, menus, or repository — see `03-lists-screen.md` and `04-detail-screen.md`.

**Depends on:** none

**Runtime:** parallel-safe
