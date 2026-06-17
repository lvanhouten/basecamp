## Agent Brief

**Category:** enhancement
**Summary:** Build the design system's bespoke UI primitives that Material has no good equivalent for — ProgressRing, Stat, Badge (with status-dot variant), Tag, BcListItem, and a SegmentedControl — as reusable widgets reading the token layer.

**Current behavior:**
Screens use stock Material widgets directly. There is no progress ring, stat block, pill badge, tag chip, design-system list row, or segmented control matching the design system's component specs.

**Desired behavior:**
A small library of reusable presentational widgets exists, each faithful to its design-system component spec, each reading colors/radii/shadows/motion/type from the theme (never hardcoded), and each usable across screens.

- **ProgressRing** — a circular arc that fills proportionally to a value in [0, 1] (or a percentage), with an optional center label slot. Clamps out-of-range values. Eases its fill over the design system's "slow" duration and respects reduced-motion (no animation when motion is reduced; renders at the final value).
- **Stat** — a large tabular-numeric value with an optional unit and a caption label, for insight blocks.
- **Badge** — a pill label with a tone (success / warning / danger / module/brand) and an optional **leading status dot** variant. Tone maps to the corresponding semantic colors.
- **Tag** — a small pill chip (label, optional leading icon).
- **BcListItem** — a row with a leading slot (icon or avatar), a title, an optional subtitle, an optional trailing slot (badge / chevron / time text), and tap handling. Supports the grouped presentation where rows in a group are separated by a single hairline rather than each being boxed.
- **SegmentedControl** — a 2+ option single-select control matching the design-system spec; the selected segment adopts the brand accent. Prefer theming Material's `SegmentedButton` to the spec if it suffices; otherwise build a custom widget. Whichever is chosen, expose one consistent widget API.

**Key interfaces:**

- `ProgressRing` — `value` (0–1 or percentage), optional `label`/center child, size; reads brand color + the slow duration + spring/standard easing + reduced-motion from the theme.
- `Stat` — `value` (string, rendered with tabular figures), optional `unit`, `label`.
- `Badge` — `tone` enum (success/warning/danger/module), `dot` flag, label child.
- `Tag` — label, optional leading icon.
- `BcListItem` — `leading`, `title`, `subtitle?`, `trailing?`, `onTap?`; plus a grouped/hairline-separated presentation helper.
- `SegmentedControl<T>` — `options`, `value`, `onChanged`.

**Acceptance criteria:**

- [ ] ProgressRing renders an arc proportional to its value, clamps values outside [0, 1] (or 0–100%), and renders at the final value (no animation) under reduced-motion.
- [ ] Badge renders the dot variant when requested and applies the correct semantic color per tone.
- [ ] Stat renders value + optional unit + label with the numeric value in tabular figures.
- [ ] Tag and BcListItem render their slots; BcListItem fires its tap callback; grouped BcListItems are separated by a single hairline.
- [ ] SegmentedControl renders its options, marks the selected one with the brand accent, and fires `onChanged` on selection.
- [ ] Every widget sources colors/radii/shadows/type/motion from the theme — no hardcoded color or size literals for themed values.
- [ ] Widget tests cover each component's external behavior (ProgressRing arc-for-value + clamp + reduced-motion, Badge dot + tone, Stat slots, Tag/BcListItem slots + tap, SegmentedControl selection). (These are the custom-component tests.)
- [ ] `flutter analyze` clean; `flutter test` passes.

**Out of scope:**

- The launcher TabBar (also a bespoke widget, but nav-critical with its own tests) — see `03-launcher-tabbar`.
- Material primitives already themed (buttons, input, switch, checkbox, card) — handled in `01-theming-foundation`; do not reimplement them here.
- Wiring these widgets into any screen — the screen briefs (`05`–`10`) consume them.

**Depends on:** 01-theming-foundation (consumes `BasecampTokens`, the `ColorScheme`, and the numeric text style)

**Runtime:** parallel-safe

**Design references:** `_docs/design-system/project/components/data-display/` (`ProgressRing`, `Stat`, `Badge`, `Tag`, `ListItem` — each has a `.prompt.md` + `.d.ts`), `_docs/design-system/project/components/forms/SegmentedControl.*`, and `components/components.css` for interaction states.
