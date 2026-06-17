## Agent Brief

**Category:** enhancement
**Summary:** Replace the Modules placeholder with the real launcher grid: tiles for Lists / Workouts / Clock / Goals / Journal carrying each module's summary, opening the module on tap, plus an "add a module" coming-soon affordance.

**Current behavior:**
The Modules placeholder from the shell brief is empty/minimal. Module summaries currently live on the old Brief's cards.

**Desired behavior:**
The Modules destination is the launcher + manager grid, styled in the design language:

- A **"Your modules"** section with a tile per module — **Lists, Workouts, Clock, Goals, Journal**. Each tile shows the module's icon, name, and a **summary meta line**, and pushes the module's screen on tap (landing on its in-progress activity per the shell's routing).
- The summary meta lines reuse the existing read models: Lists → list count + open items (e.g. "3 lists · 12 open"); Clock → today's enabled alarms / running timers / running stopwatch phrasing; Workouts/Goals/Journal → a placeholder/quiet meta (they have no data layer). These are the **same providers** the old Brief used — reused here, not redefined.
- An **"Add a module"** affordance that shows a generic **"coming soon"** (toast or inline) — no real add flow.
- Tiles use the design-system raised-card tile look; the grid reads colors/radii/shadows from the theme.

**Key interfaces:**

- Consumes the existing read models for list count + open-item count (lists contract) and the clock counts (clock contract) — reused from where the Brief previously used them.
- Iterates the refactored `AppModule` enum (from `04`, now including goals/journal) to build tiles, and uses the shell's push routing to open a module.
- Uses `Card`/tile styling + `Badge` from `01`/`02`.

**Acceptance criteria:**

- [ ] The Modules grid renders a tile for each `AppModule` (Lists, Workouts, Clock, Goals, Journal) with icon, name, and a summary meta line.
- [ ] Lists and Clock tiles show live summary meta from the existing read models; Workouts/Goals/Journal show a quiet placeholder meta.
- [ ] Tapping a tile pushes that module's screen (Goals/Journal push their stub screens) and Clock lands on its precedence-selected tool.
- [ ] An "add a module" affordance shows a "coming soon" message and performs no real add.
- [ ] Tiles follow the design-system tile styling from the theme.
- [ ] `flutter analyze` clean; `flutter test` passes.

**Out of scope:**

- Module "Edit" / rearrange / pinning of tiles — deferred.
- A real add-a-module flow — coming-soon only.
- The Goals/Journal **screens** themselves — see `07-stub-and-profile-screens` (this brief only links to them as push targets, which exist as placeholders from `04`).
- The shell/bar/push routing and the `AppModule` refactor — built in `04`.

**Depends on:** 01-theming-foundation, 02-custom-components, 04-launcher-shell-nav (replaces the Modules placeholder; uses the refactored `AppModule` + push routing)

**Runtime:** parallel-safe

**Design references:** `_docs/design-system/project/ui_kits/basecamp-app/ModulesScreen.jsx` (the "Your modules" + "Add a module" structure; move Goals/Journal into "Your modules" per the plan), `_docs/CONTEXT.md` (Modules / Module terms).
