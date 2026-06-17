# PRD — Design System Adoption

**Slug:** `design-system-adoption`
**Status:** Ready for slicing (`prd-to-briefs`)
**Key decisions:** [ADR-0005](../../adr/0005-launcher-bottom-bar-navigation.md) (launcher nav, supersedes [ADR-0001](../../adr/0001-drawer-hub-navigation.md)); glossary in [CONTEXT.md](../../CONTEXT.md).
**Design source of truth:** `_docs/design-system/project/` (tokens, component specs, `ui_kits/basecamp-app/` screens). Local copy is current.

---

## Problem Statement

Basecamp's UI grew organically on Material 3 defaults: a single terracotta seed, warm-cream
surfaces, stock Roboto type, and a navigation drawer. There is now a complete, deliberately
designed brand + product **design system** (built with Claude Design) — coral/navy palette,
Hanken Grotesk, a defined component vocabulary, and a **launcher** navigation model — but
nothing in the app reflects it. The app looks and navigates nothing like the intended product.

The user wants the existing app to *become* the design system: the same look, the same
components, and the same launcher navigation the kit specifies — not a partial token port, but
a faithful recreation of the kit's visual language and information architecture.

## Solution

Adopt the design system across the app in one coordinated pass:

1. **A theming foundation** — replace the single-seed `ColorScheme` with an explicit
   token layer (the DS hand-picks every value): a `ColorScheme` for the Material-semantic
   roles plus a `BasecampTokens` `ThemeExtension` for everything Material has no slot for, a
   Hanken-Grotesk `TextTheme`, and both light and dark themes.
2. **A component kit** — theme stock Material widgets where they map 1:1, and build small
   custom Flutter widgets for the DS-specific primitives Material lacks.
3. **The launcher navigation** — retire the drawer + `IndexedStack` hub and replace it with a
   fixed bottom bar of four destinations (Brief · Calendar · ⊕ · Activity · Modules) split
   around a center Quick-add FAB, with modules opened as pushed views.
4. **Reskinned + re-contented screens** — the Brief becomes a forward-looking digest, a new
   Modules grid becomes the launcher, the existing module screens are restyled, and the new
   destinations (Calendar, Activity, Profile, plus the Goals/Journal stub modules) ship as
   honest placeholders.

The result is the existing app, unchanged in data and behavior, wearing the full design system
and navigating the launcher model. Net-new *features* implied by the mockups (real Calendar,
real Activity feed, quick-capture, social) are explicitly deferred.

## User Stories

1. As the user, I want the app to use the coral/navy brand palette, so that it looks like the
   designed product rather than a default Material app.
2. As the user, I want warm-cream/terracotta surfaces replaced by the cool navy-leaning
   neutrals, so that the whole app reads as one cohesive brand.
3. As the user, I want a dark theme that matches the design system's dark palette, so that the
   app is comfortable at night.
4. As the user, I want a light/dark toggle in a Profile/Settings screen, so that I can choose my
   theme.
5. As the user, I want my chosen theme to persist across cold starts, so that I don't re-pick it
   every launch.
6. As the user, I want all text set in Hanken Grotesk, so that typography matches the brand.
7. As the user, I want numeric displays (timers, stopwatch, durations, alarm times, stats,
   counts) to use tabular figures, so that digits don't jump as they change.
8. As the user, I want buttons, cards, inputs, switches, and checkboxes to follow the design
   system's shapes (pills, soft radii) and states, so that controls feel consistent.
9. As the user, I want the design system's bespoke components (progress ring, stat, badge with
   status dot, tag, list rows) rendered faithfully, so that screens match the mockups.
10. As the user, I want a fixed bottom bar with Brief, Calendar, Activity, and Modules around a
    center ⊕ button, so that I navigate the app the way the design intends.
11. As the user, I want the ⊕ button present in the bar, so that the launcher layout is complete
    (even though quick-capture isn't wired yet).
12. As the user, I want to open Lists, Workouts, and Clock from a Modules grid, so that modules
    have a dedicated home and the bar isn't crowded by them.
13. As the user, I want tapping a module to push its screen with a back arrow, so that I can
    return to where I launched it.
14. As the user, when I re-open a module that has work in progress (a running timer, a started
    workout), I want it to open straight to that in-progress activity, so that I never lose my
    place — even though screens are no longer kept alive.
15. As the user, I want the Modules tiles to show each module's summary (e.g. "3 lists · 12
    open", "2 alarms today"), so that I get a glance before opening.
16. As the user, I want the bar to never grow as I add modules, so that navigation stays stable
    no matter how many modules exist.
17. As the user, I want the Brief to be a clean daily digest — greeting, date, today's progress —
    rather than a list of module cards, so that it tells me about my day at a glance.
18. As the user, I want the Brief's progress shown as a ring with "N of M done today", so that I
    see momentum immediately.
19. As the user, I want the Brief's "Up next today" to show my genuinely time-bound items
    (today's enabled alarms, running timers), so that it reflects real data, not fictional
    agenda rows.
20. As the user, I want a profile avatar in the Brief's top-right that opens Profile/Settings, so
    that settings have a discoverable home.
21. As the user, I want a Calendar destination present (as a placeholder), so that the bar is
    complete and I know a calendar is coming.
22. As the user, I want an Activity destination present (as a placeholder), so that the bar is
    complete and I know an activity feed is coming.
23. As the user, I want Goals and Journal to appear as modules in the grid that open a "coming
    soon" placeholder, so that I can see the app's planned shape.
24. As the user, I want adding a future module to be a one-line change that surfaces as a grid
    tile, so that growth stays cheap.
25. As the user, I want the Lists screens (list overview, list detail) restyled to the new
    language, so that the module I use most looks designed.
26. As the user, I want the Clock tools (Timer, Stopwatch, Alarms, the alarm ring screen)
    restyled, so that the time tools match the brand.
27. As the user, I want the Workouts stub restyled, so that even unbuilt modules look consistent.
28. As the user, I want all existing Lists/Clock behavior (counts, ordering, pinning, alarm
    scheduling, timer math, resume) to keep working unchanged after the reskin, so that nothing
    regresses.
29. As the user, I want motion (press scale, toggle spring, ring fill) to follow the design
    system's gentle timings and respect reduced-motion, so that the app feels alive but calm.
30. As the user, I want copy to follow the brand voice (sentence case, no emoji, encouraging not
    nagging) where this work touches strings, so that tone is consistent.

## Implementation Decisions

### Theming foundation (Module A)

- The DS is an **explicit hand-picked palette**, not a derivable seed. Replace
  `ColorScheme.fromSeed(...)` in the current theme with an explicit construction:
  - Map DS semantic aliases onto Material `ColorScheme` roles: `primary` = coral
    (`#FF5A3C`), brand-tint → primary container, `surface`/the surface-container ramp → the
    navy-neutral surfaces, `error` = the DS red, `outline`/`outlineVariant` → border tokens,
    on-colors → the DS text-on/inverse tokens. Do this for **both** brightnesses (DS defines a
    full dark theme: `#131326`/`#1E1E36`/… surfaces, lightened brand on dark).
  - Put everything Material has no role for into a `BasecampTokens extends
    ThemeExtension<BasecampTokens>`: the **joy/sun** accent (`#FFC844` + tint + ink), the
    **5-step navy-tinted shadow scale** (xs–xl), **module-tint**, the **radii** scale
    (6/10/14/20/28/36/full), the **spacing** 4px grid, and **motion** (durations
    instant/fast/base/slow/slower + the standard/out/in/spring easings).
- Token values are transcribed from `_docs/design-system/project/tokens/*.css`
  (`colors`, `typography`, `spacing`, `radii`, `shadows`, `motion`). Build against the DS
  **semantic aliases**, not raw scales.
- **Typography:** one family — **Hanken Grotesk**, self-hosted `.ttf`/`.woff2` assets declared
  in `pubspec.yaml` at weights 400/500/600/700/800 (the `font-family` is `'Hanken Grotesk'`;
  the `google_fonts` package is **not** used — no runtime fetch). Build a `TextTheme` from the
  DS type roles (`display`/`title`/`heading`/`subhead`/`body`/`label`/`caption`) using the DS
  sizes/weights/line-heights/tracking. **No Spline Sans Mono** — the DS dropped it. Numerics
  use Hanken Grotesk with `FontFeature.tabularFigures()`; provide a numeric `TextStyle` helper
  so timers/stopwatch/stats/durations/alarm times opt into tabular figures.
- **Theme mode** is user-chosen (light/dark/system) and **persisted in the existing
  `ModuleData` JSON lane** (`moduleId = 'settings'`, an `entryKey` for theme mode) — **no new
  table, no migration**. A Riverpod notifier reads/writes it; `app.dart`'s `themeMode:
  ThemeMode.system` becomes `ref.watch(themeModeProvider)`.

### Component kit (Module B) — hybrid strategy

- **Theme stock Material widgets** for primitives that map 1:1, via `ThemeData` component
  themes: buttons (`FilledButton`/`OutlinedButton`/`TextButton` with **pill** shape =
  `radius-full`), `TextField` (Input), `Switch`, `Checkbox`, `Card` (soft radius + the
  navy-tinted shadow / hairline border variants). No custom widget where a themed Material one
  suffices.
- **Build custom Flutter widgets** for the DS-specific primitives with no good Material match,
  reading the token layer:
  - **ProgressRing** — circular arc fill for a 0–1 (or %) value, optional center label; eases
    its fill (~`dur-slow`), respects reduced-motion.
  - **Stat** — big tabular-numeric value + optional unit + label (Activity/Brief insights).
  - **Badge** — pill label with tone (success/warning/danger/module) and an optional leading
    **status dot** variant.
  - **Tag** — small pill chip.
  - **BcListItem** — leading icon/avatar, title, subtitle, trailing (badge/chevron/time),
    tap; the grouped-rows-with-hairlines look (rows separated by a single hairline, not boxed).
  - **Launcher TabBar** — the bottom bar: N items split at the midpoint around a raised center
    FAB (`centerAction`). Active item adopts the brand accent; the FAB is an **action**, never
    a selected tab. Matches `components/navigation/TabBar.jsx` (which already splits at the
    midpoint, so 4 items render 2/2).
  - **SegmentedControl** — only if Material's `SegmentedButton` can't be themed close enough to
    the DS spec; prefer theming the Material one first.
- Component specs/behavior live in `_docs/design-system/project/components/**` (`.prompt.md` +
  `.d.ts` per component).

### Launcher navigation (Module C) — ADR-0005

- Retire `AppDrawer` and the `IndexedStack` hub shell. New **launcher shell**: a `Scaffold`
  whose `bottomNavigationBar` is the launcher `TabBar` and whose body holds the four **bar
  destinations** (Brief, Calendar, Activity, Modules) — these may remain a lightweight
  `IndexedStack` (they are persistent tabs and are cheap). ADR-0005 retires keeping the heavy
  **module** screens alive as peers, *not* an IndexedStack for the four tabs.
- **Modules are pushed views.** Tapping a Modules-grid tile (or a Brief affordance) does
  `Navigator.push` of the module screen over the shell; back pops it. Module screens lose
  `drawer:`/the hub AppBar and gain a back arrow.
- **Domain-state landing (must not regress):** when a module is (re-)entered it lands on its
  in-progress activity by reading Drift — e.g. Clock opens to the precedence-selected tool
  (existing `entryTab` precedence: Stopwatch > Timer > Alarms). The `selectedClockTabProvider`
  mechanism is preserved; its doc-comment about "kept alive in the IndexedStack" is updated to
  "computed on module entry."
- **`AppModule` refactor:** the enum no longer drives the *bar*. It drives the **Modules grid**
  (and the push target). Add `goals` and `journal` cases. The bar's four destinations are a
  separate, fixed set (Brief/Calendar/Activity/Modules). `selectedModuleProvider`'s role is
  revisited (it becomes "which module is pushed", or is replaced by Navigator state — decide
  during implementation, keeping Drift as the source of truth for landing).
- **Quick add (⊕):** present in the bar as a button; tapping it is a **no-op / "coming soon"**
  this feature. The capture sheet is deferred.
- The `AlarmLaunchHost` wrapper (full-screen alarm intent → ring screen on the root navigator)
  must continue to work above the new shell.

### Screens

- **Brief (Module D)** — reskinned digest: time-based greeting + date eyebrow + top-right
  profile avatar (→ Profile). A progress `Card` with a `ProgressRing` + "N of M done today"
  derived from Lists `done`/open counts. An "Up next today" group populated **only** from real
  time-bound data — today's **enabled Alarms** (`todaysAlarmCountProvider` / the alarms stream)
  and **running Timers** (`runningTimersProvider`). The mockup's "Later this week" section is
  **dropped** (no scheduling model exists). Reference: `ui_kits/basecamp-app/BriefScreen.jsx`.
- **Modules (Module E)** — new launcher grid. "Your modules" tiles for Lists / Workouts / Clock
  + the stub modules Goals / Journal. Tiles carry the **summary meta lines that currently live
  on the Brief's module cards** — these providers (`listCountProvider`, `openItemCountProvider`,
  `todaysAlarmCountProvider`, `runningTimerCountProvider`, `stopwatchRunningProvider`) **move**
  from the Brief to Modules unchanged (they already route through `ListsApi`/`ClockApi`). An
  "Add a module" affordance shows a generic "coming soon". Reference:
  `ui_kits/basecamp-app/ModulesScreen.jsx`.
- **Lists / Workouts / Clock (Module G)** — restyle existing screens to the new language
  (theme + custom widgets), preserving all behavior. Lists: overview + list detail. Clock:
  Timer/Stopwatch/Alarms panes + the alarm ring screen. Workouts: keep its current stub content,
  restyled.
- **Calendar, Activity, Profile (Module F)** — new screens. Calendar + Activity are stubs
  ("Nothing here yet" in the brand voice). Profile is a minimal real screen reached from the
  Brief avatar; it hosts the **light/dark theme toggle** (and is where notification prefs grow
  later). Friends/social from the Activity mockup is **dropped permanently**.
- **Goals + Journal (Module F)** — stub modules: two `AppModule` cases + placeholder screens,
  icons **book** (Journal) / **target** (Goals). No Drift tables / DAO / repository / contract.

### Architecture constraints (from CLAUDE.md / CONTEXT.md)

- Flutter + Riverpod + Drift. **Modules never import each other**; cross-module reads go
  through `core/contracts/*Api` (the moved summary providers already comply). **Drift is the
  source of truth**; providers are reactive views.
- Screens are `ConsumerWidget`/`ConsumerStatefulWidget`. **Theme is no longer seeded from one
  color** — `core/theme.dart` is replaced by the token layer; widgets read tokens via
  `Theme.of(context)` / the `BasecampTokens` extension, never hardcoded colors.
- This feature adds **no new tables** (stubs have no data layer; theme mode uses the existing
  `ModuleData` lane), so **`build_runner` is only needed if a provider/DAO signature changes** —
  not for the reskin itself.

## Testing Decisions

A good test here asserts **observable behavior**, not implementation detail: what a widget
renders for a given input/state, and what navigating produces — never private fields or exact
pixel values. Prior art: the repo's existing widget-pump tests (Clock panes use overridable
provider seams like `notificationSchedulerProvider`/`chimePlayerProvider` with Noop/fake
implementations) and pure-function unit tests (`clock_math`, `alarm_recurrence`, `entryTab`).
Follow those patterns — override providers with fakes/seeded values and pump.

**In scope for automated tests** (user-selected):

1. **Launcher navigation** (Module C) — the ADR-0005 regression risk:
   - Tapping a Modules-grid tile pushes that module's screen; back returns to the launcher.
   - **Domain-state landing**: with Drift seeded so a module has an in-progress activity (e.g. a
     running Timer / running Stopwatch), entering Clock lands on the precedence-selected tool;
     with nothing in progress it lands on the resting default.
   - The four bar destinations switch without unmounting; the ⊕ FAB invokes its action and is
     never rendered as a selected tab.
2. **Custom component widgets** (Module B) — widget tests for each bespoke primitive's external
   behavior: ProgressRing renders the right arc for a value (and clamps), Badge renders the dot
   variant + tone, the launcher TabBar splits 4 items 2/2 with the FAB centered and fires
   `centerAction`/`onChange`, Stat/Tag/BcListItem render their slots.
3. **Theme-mode persistence** — setting light/dark in Profile writes `ModuleData` and the chosen
   mode is read back after a fresh provider container / simulated cold start (use an in-memory
   Drift DB, as existing data tests do).

**Not automated** (by decision): the **theme/token builder** role-mapping (brittle to assert,
low regression value) and **visual fidelity** of the reskinned screens (no golden tests) — these
are validated by the emulator smoke-test below.

**Mandatory manual gate (not coverable by `flutter test`):** `flutter test` never builds
Android/Gradle, so **font-asset bundling** (Hanken Grotesk actually loading on device) and the
overall look must be confirmed with an **emulator smoke-test** (`flutter run`, screenshot the
Brief/Modules/Lists/Clock in light + dark) before the feature is called done.

## Out of Scope

Deferred to their own future features (each called out so briefs don't drift into building them):

- **Real Calendar** — the cross-module scheduling/date data model and the agenda/calendar UI.
  Calendar ships as a stub only. (This is also why the Brief's "Later this week" is dropped.)
- **Real Activity feed** — the completion **event-log** table, every module emitting completion
  events, and the insights header (week count, streak, spark). Activity ships as a stub only.
- **Friends / social** — others' completions, kudos, any backend or sync. **Dropped permanently**
  (conflicts with the local-first, personal-use, no-sync stance).
- **Quick-add capture** — the global ⊕ quick-capture sheet and its routing/inference. The ⊕ is a
  button only this feature.
- **Modules "Edit" / rearrange / pin** of module tiles.
- **Goals / Journal as real modules** — their data layer, screens, and behavior. Stubs only now.
- **Per-module accent colors** — the DS is currently **brand-unified** (coral everywhere,
  modules differentiated by icon). The `data-module` theming hook concept stays **dormant**;
  do not wire per-module color ramps.
- **iOS build / sync** — unchanged from project baseline.

## Further Notes

- **Faithful recreation, not reinterpretation:** decision is to recreate the kit's visual
  language *and* IA (the launcher), treating `ui_kits/basecamp-app/*` as the screen reference.
  Where the mockups show fictional data (timed list items, scheduled workouts, a named
  multi-user "Riley"), substitute the app's **real** single-user data and drop what has no
  source.
- **Brand voice** (`_docs/design-system/project/readme.md`): sentence case everywhere, no emoji
  (meaning carried by Lucide-style icons + type), encouraging-not-nagging tone, tabular honest
  numbers, lowercase "basecamp". Apply to any strings this work touches; empty states are one
  calm line ("Nothing here yet.").
- **Icons:** the DS standardizes on Lucide (2px stroke, rounded). The app currently uses
  Material `Icons`. Closest-match Material icons are acceptable for this pass unless a brief
  calls out a specific Lucide glyph; a full Lucide icon swap is not required to land the system.
- **Dependency order for slicing:** A (foundation) → B (components) → then C/D/E/G can proceed,
  with F (stubs) depending on A/B/C. C is the load-bearing/regression-sensitive slice and should
  carry the navigation tests; A and B unblock everything visual.
- **ADR-0004 preserved:** multi-activity resume still holds; resume affordances move from the
  drawer-era Brief onto the Brief digest + Modules tiles.
