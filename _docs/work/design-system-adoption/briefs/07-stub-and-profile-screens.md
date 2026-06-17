## Agent Brief

**Category:** enhancement
**Summary:** Give final form to the non-module destinations: Calendar and Activity stubs, the Goals/Journal placeholder screens, and a real Profile screen whose light/dark toggle drives the persisted theme-mode provider.

**Current behavior:**
The shell brief left minimal placeholders for Calendar and Activity (bar destinations) and for the Goals/Journal modules. There is no Profile screen; the theme-mode provider from the foundation brief has no UI to drive it.

**Desired behavior:**
Each of these screens reaches its intended (for-now) state, styled in the design language:

- **Calendar (stub):** a placeholder screen with a heading and one calm empty line ("Nothing here yet.") in the brand voice. No scheduling data, no grid.
- **Activity (stub):** a placeholder screen with a heading and a calm empty line. **No completion feed, no insights, no Friends/social** (social is dropped permanently).
- **Goals (stub module) / Journal (stub module):** placeholder screens reached by pushing from the Modules grid, each a calm "coming soon"/"Nothing here yet" line. No data layer.
- **Profile:** a real (minimal) screen reached from the **Brief's top-right avatar**. It hosts the **light/dark theme toggle**, wired to the theme-mode provider from `01` (selecting a mode updates the app theme and persists). Built to grow (notification prefs etc.) but only the theme control is required now.

All screens follow the brand voice and use themed widgets; empty states are a single calm line.

**Key interfaces:**

- Profile consumes the theme-mode provider from `01` (reads current mode, sets new mode); uses the themed `Switch`/`SegmentedControl` for the light/dark (or light/dark/system) choice.
- Calendar/Activity/Goals/Journal screens replace the placeholders created in `04`.
- Uses `BcListItem`/`Badge` from `02` and theme/type from `01` as needed.

**Acceptance criteria:**

- [ ] Calendar and Activity render as styled stubs with a heading + one calm empty line; neither shows fabricated data; Activity has no Friends/social UI.
- [ ] Goals and Journal render as styled placeholder screens when pushed from the Modules grid.
- [ ] Profile renders a working light/dark (or light/dark/system) control that updates the app theme immediately via the `01` provider; the choice persists (persistence itself is covered by `01`'s test — here, verify the control calls the provider and reflects current mode).
- [ ] The Brief's avatar reaches Profile (the Brief brief wires the avatar; this brief ensures Profile exists and renders).
- [ ] Copy is sentence case, emoji-free, encouraging.
- [ ] `flutter analyze` clean; `flutter test` passes.

**Out of scope:**

- The real Calendar feature (scheduling/date model) and the real Activity feed (event-log + insights) — deferred entirely.
- Friends/social — dropped permanently.
- The theme-mode provider + its persistence + persistence test — built in `01` (this brief only builds the UI that drives it).
- The Goals/Journal **data layer** (tables/DAO/repo/contract) — not part of this feature.
- The shell/bar and the placeholders' creation — done in `04`.

**Depends on:** 01-theming-foundation (theme-mode provider + theme), 02-custom-components, 04-launcher-shell-nav (replaces the Calendar/Activity/Goals/Journal placeholders)

**Runtime:** parallel-safe

**Design references:** `_docs/design-system/project/ui_kits/basecamp-app/ActivityScreen.jsx` (style reference only — build the **stub**, not the feed/Friends), `_docs/design-system/project/ui_kits/basecamp-app/CalendarScreen.jsx` (style reference for the stub), `_docs/design-system/project/readme.md` (empty-state voice), `_docs/CONTEXT.md` (Calendar / Activity / Profile / Module terms).
