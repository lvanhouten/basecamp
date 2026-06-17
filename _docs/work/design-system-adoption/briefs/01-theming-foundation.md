## Agent Brief

**Category:** enhancement
**Summary:** Replace the single-seed Material theme with the design system's explicit token layer — a `BasecampTokens` ThemeExtension, explicit light/dark `ColorScheme`, a Hanken Grotesk `TextTheme`, Material component theming, and a persisted theme-mode setting.

**Current behavior:**
The app's look is derived from one terracotta seed via `ColorScheme.fromSeed(...)` with warm-cream/charcoal neutral overrides. There is one `basecampTheme(Brightness)` builder; the root applies it as `theme`/`darkTheme` with `themeMode: ThemeMode.system` hardcoded. Type is stock Roboto. There is no shared token surface for radii, spacing, shadows, motion, or the brand's accent colors, and no user-controllable theme mode.

**Desired behavior:**
The app renders in the design system's palette and type, in both light and dark, with a user-chosen theme mode that survives cold start.

- The brand palette is an **explicit, hand-picked** set of values (transcribed from the design-system token files), not a seed-derived scheme. Coral is the brand/primary (`#FF5A3C`), grounded by deep-navy ink (`#1A1A2E`) on a cool navy-leaning neutral ramp; the design system's red is the error role.
- Material's semantic color roles are populated from the design system's surface/text/border/brand/error aliases, for **both** brightnesses (the design system defines a full dark palette with its own near-black surfaces and lightened brand).
- Everything Material has no role for is exposed through a `ThemeExtension` so widgets read it from the theme: the **joy/sun accent** (`#FFC844` + tint + ink), the **5-step navy-tinted shadow scale** (xs–xl), the **module-tint**, the **radii** scale (6 / 10 / 14 / 20 / 28 / 36 / full), the **spacing** 4px grid, and **motion** (the instant/fast/base/slow/slower durations + the standard/out/in/spring easing curves).
- All text uses **Hanken Grotesk**. A `TextTheme` is derived from the design system's type roles (display / title / heading / subhead / body / label / caption) using their sizes, weights, line-heights, and tracking. A reusable numeric text style applies tabular figures (`FontFeature.tabularFigures()`) for timers/stopwatch/stats/durations/alarm times/counts. **No monospace product font** (the design system dropped Spline Sans Mono; the brand sans carries numerics).
- Stock Material primitives that map 1:1 are themed (not reimplemented) so they render in the design language: buttons are **pills** (`FilledButton`/`OutlinedButton`/`TextButton` at the full radius), plus themed `TextField`/input, `Switch`, `Checkbox`, and `Card` (soft radius + the navy-tinted soft shadow for raised, hairline border for outlined). Press/selected/focus/disabled states follow the design system's interaction-states guidance.
- **Theme mode** (light / dark / system) is user-selectable and persisted in the existing generic JSON store (no new table, no migration): a settings record holds the chosen mode. A Riverpod provider exposes the current mode and a setter; the root reads the provider for `themeMode` instead of hardcoding `system`.
- Widgets never hardcode colors — they read `ColorScheme` / the tokens extension from `Theme.of(context)`.

**Key interfaces:**

- `BasecampTokens extends ThemeExtension<BasecampTokens>` — new theme extension carrying joy accent, shadow scale, radii, spacing, motion durations/easings, module-tint. `copyWith`/`lerp` implemented. Read via `Theme.of(context).extension<BasecampTokens>()`.
- `basecampTheme(Brightness)` — rewritten to build `ThemeData` from explicit tokens (ColorScheme + TextTheme + component themes + the extension) rather than `fromSeed`.
- Theme-mode provider — a Riverpod `NotifierProvider` exposing `ThemeMode` + a setter that reads/writes the persisted settings record through the database. The root applies `themeMode: ref.watch(...)`.
- Persistence uses the existing generic JSON table (a `settings` module id) — no schema change.
- Font family `'Hanken Grotesk'` declared in `pubspec.yaml` at weights 400/500/600/700/800, pointing at these exact assets (the binaries are dropped manually — see `assets/fonts/README.md`): `assets/fonts/HankenGrotesk-Regular.ttf` (400), `-Medium.ttf` (500), `-SemiBold.ttf` (600), `-Bold.ttf` (700), `-ExtraBold.ttf` (800).

**Acceptance criteria:**

- [ ] `ColorScheme` primary resolves to the coral brand in light and a design-system-correct brand in dark; surfaces use the navy-neutral ramp (not warm cream); error uses the design-system red.
- [ ] `BasecampTokens` is registered on `ThemeData.extensions` for both brightnesses and exposes joy accent, the 5-step shadow scale, the radii scale, the spacing scale, and motion durations/easings.
- [ ] The `TextTheme` maps the design system's type roles to Hanken Grotesk with the specified sizes/weights/line-heights/tracking; a numeric text style enabling tabular figures is available for reuse.
- [ ] Themed Material buttons render as pills; `TextField`, `Switch`, `Checkbox`, and `Card` reflect the design-system shapes/states. No bespoke reimplementation of these five.
- [ ] `pubspec.yaml` declares the `Hanken Grotesk` family at the five weights pointing at `assets/fonts/`.
- [ ] Theme mode is selectable via the provider and **persists across a simulated cold start**: a test using an in-memory database sets a mode, rebuilds the provider container, and reads the same mode back. (This is the theme-mode persistence test.)
- [ ] The root applies `themeMode` from the provider rather than a hardcoded value.
- [ ] `flutter analyze` is clean and `flutter test` passes.

**Out of scope:**

- The custom bespoke widgets (ProgressRing, Stat, Badge, Tag, BcListItem, SegmentedControl) — see `02-custom-components`.
- The launcher TabBar widget — see `03-launcher-tabbar`.
- The Profile screen UI that drives the theme toggle — see `07-stub-and-profile-screens` (this brief provides the provider it calls).
- Supplying the actual Hanken Grotesk `.ttf`/`.woff2` **binaries**: declare the pubspec entries and reference `assets/fonts/`; the font files are a manual drop (same pattern as the committed `chime.wav` placeholder). Fonts *actually rendering on device* is verified by the manual emulator smoke-test, not by `flutter test` (which never builds the Android/Gradle layer).
- Per-module accent colors — the system is brand-unified coral; keep any module-theming hook dormant.

**Depends on:** none

**Runtime:** parallel-safe

**Design references:** `_docs/design-system/project/tokens/` (`colors.css`, `typography.css`, `spacing.css`, `radii.css`, `shadows.css`, `motion.css`, `fonts.css`), `_docs/design-system/project/readme.md` (Visual foundations / Interaction states), and the foundation specimen cards in `_docs/design-system/project/guidelines/`.
