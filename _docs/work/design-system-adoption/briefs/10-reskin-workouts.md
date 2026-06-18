## Agent Brief

**Category:** enhancement
**Summary:** Restyle the Workouts stub screen to the design language; it remains a stub (no workout data model is added).

**Current behavior:**
Workouts is a placeholder/stub screen with stock Material styling. After the shell brief it is a pushed module screen (no drawer).

**Desired behavior:**
The Workouts stub looks like the design system: design-language surface, heading, and a calm empty/"coming soon" line in the brand voice, using themed widgets from `01`/`02`. It presents as a pushed module screen (back arrow, no drawer). It remains a stub — no workout/exercise/set data model, DAO, repository, or contract is introduced.

**Key interfaces:**

- Presentational only. No data layer.
- Uses theme/type from `01` and components from `02` as needed.

**Acceptance criteria:**

- [ ] The Workouts screen renders in the design language with a heading and a single calm brand-voice line (sentence case, emoji-free).
- [ ] Works as a pushed route with a back arrow and no drawer.
- [ ] No data layer is added; `flutter analyze` clean; `flutter test` passes.

**Out of scope:**

- Building the real Workouts module (workout → exercises → sets/reps/weight schema and behavior) — a separate future feature.
- The shell/push routing — done in `04`.
- The theme and components — built in `01`/`02`.

**Depends on:** 01-theming-foundation, 02-custom-components, 04-launcher-shell-nav (module screens are pushed, drawerless)

**Runtime:** parallel-safe

**Design references:** `_docs/design-system/project/readme.md` (empty-state voice), `_docs/CONTEXT.md` (Module term), and the existing Workouts stub for current content.
