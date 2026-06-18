## Agent Brief

**Category:** enhancement
**Summary:** Build the launcher bottom-bar widget — N destinations split at the midpoint around a raised center FAB action — as a reusable, controlled widget with its own tests.

**Current behavior:**
There is no bottom navigation widget. Navigation is a drawer.

**Desired behavior:**
A reusable launcher `TabBar` widget exists, matching the design system's navigation spec:

- Renders a fixed bottom bar of `items` (each: value, label, icon). With a `centerAction` provided, the items are split at their midpoint — left half, then the raised center **FAB**, then the right half — so an even item count sits symmetrically around the FAB (4 items → 2 left / 2 right).
- It is **controlled**: a `value` marks the selected destination and an `onChange(value)` fires on tap. The selected item adopts the brand accent; unselected items use the tertiary text color.
- The **center FAB is an action, never a selectable destination** — it fires its own callback and never carries the selected state, regardless of `value`.
- Touch targets meet the minimum tap size; the bar reads colors/radii/shadows/type from the theme.
- Without a `centerAction`, it degrades to a plain N-tab bar (no FAB).

**Key interfaces:**

- `LauncherTabBar` (or equivalently-named) — `items: List<{value, label, icon}>`, `value`, `onChange(value)`, optional `centerAction: {icon, label, onClick}`.
- Midpoint split semantics identical to the design-system component: `ceil(items.length / 2)` items on the left, the rest on the right, FAB between.

**Acceptance criteria:**

- [ ] Given 4 items + a `centerAction`, the widget renders 2 items, then the FAB, then 2 items.
- [ ] Tapping a destination fires `onChange` with that destination's value; the destination matching `value` is rendered selected (brand accent), others unselected.
- [ ] Tapping the center FAB fires the `centerAction` callback and never changes selection — the FAB is never rendered as a selected tab even if its value collides with `value`.
- [ ] Without `centerAction`, the widget renders a plain N-tab bar with no FAB.
- [ ] Colors/shapes come from the theme; tap targets meet the minimum size.
- [ ] Widget tests cover the 2/2 split, selection + `onChange`, and the FAB-fires-action/never-selected behavior. (These are part of the navigation-related widget tests.)
- [ ] `flutter analyze` clean; `flutter test` passes.

**Out of scope:**

- The app shell that hosts this bar, the four real destinations, push routing, and domain-state landing — see `04-launcher-shell-nav` (it consumes this widget).
- The center FAB's actual quick-add behavior — it is a no-op/"coming soon" in this feature; this widget only exposes the action callback.

**Depends on:** 01-theming-foundation (consumes the theme tokens/colors)

**Runtime:** parallel-safe

**Design references:** `_docs/design-system/project/components/navigation/TabBar.jsx` (the midpoint-split + `centerAction` logic — already supports N items), `TabBar.prompt.md` (note: its prose still describes the older 2-item launcher; follow the 4-item `.jsx` behavior and the app kit), and `_docs/design-system/project/ui_kits/basecamp-app/index.html` (the live 4-item `NAV` + `centerAction` wiring).
