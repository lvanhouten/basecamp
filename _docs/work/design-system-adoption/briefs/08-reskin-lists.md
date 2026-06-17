## Agent Brief

**Category:** enhancement
**Summary:** Restyle the Lists module (list overview + list detail) to the design language, preserving all existing behavior.

**Current behavior:**
The Lists overview and list-detail screens are built and functional (creating lists/items, checking items, pinning, manual rearrange, the checked-sink + position ordering per ADR-0002) but use stock Material styling. After the shell brief they are pushed routes (no drawer) but visually unstyled to the new system.

**Desired behavior:**
Lists looks like the design system while behaving exactly as before:

- The list overview and list detail adopt the design-language surfaces, cards, list rows (`BcListItem` / hairline-grouped rows), pill buttons, checkboxes, inputs, badges, and type from `01`/`02`.
- As a pushed module screen it presents a back arrow and module chrome appropriate to a pushed route (no drawer).
- All existing behavior is unchanged: list/item CRUD, check/uncheck, pin/unpin (pinned float to a top section), manual rearrange within a group, the automatic checked-sink + creation ordering, and empty states (now phrased in the brand voice — one calm line).
- Numerics (e.g. counts) use the tabular numeric style; copy is sentence case, emoji-free.

**Key interfaces:**

- No data-layer, DAO, repository, or provider changes — purely presentational. The list/item read models and mutations are consumed unchanged.
- Uses themed Material widgets (`01`) and the custom components (`02`).

**Acceptance criteria:**

- [ ] List overview and list detail render in the design language (surfaces, cards, rows, buttons, inputs, checkboxes, badges, type).
- [ ] All existing Lists behavior is preserved: create/edit/delete lists and items, check/uncheck, pin/unpin to a top section, manual rearrange within a group, checked-sink + creation ordering (ADR-0002).
- [ ] Empty states are a single calm brand-voice line; copy is sentence case and emoji-free; counts use tabular figures.
- [ ] The screens work as pushed routes with a back arrow and no drawer.
- [ ] No changes to the lists data layer or providers; `flutter analyze` clean; existing Lists tests + `flutter test` pass.

**Out of scope:**

- Any behavior/data change to Lists — presentational only.
- The shell/back-arrow plumbing and drawer removal — done in `04` (this brief assumes drawerless pushed routes).
- The theme and components themselves — built in `01`/`02`.

**Depends on:** 01-theming-foundation, 02-custom-components, 04-launcher-shell-nav (module screens are pushed, drawerless)

**Runtime:** parallel-safe

**Design references:** `_docs/design-system/project/ui_kits/basecamp-app/ListsScreen.jsx`, `_docs/design-system/project/components/` (Card, ListItem, Checkbox, Badge, Button), `_docs/adr/0002-item-ordering-checked-sink-primary.md` (behavior to preserve).
