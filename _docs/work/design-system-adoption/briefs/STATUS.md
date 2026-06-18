# Execution status — design-system-adoption

**Run model:** sequential, non-isolated, topological order (01→10). `Agent isolation:"worktree"` provisions off `main` in this repo (re-confirmed by probe 2026-06-17), so dependent briefs can't run in worktrees. Each brief-executor runs non-isolated on the feature branch, self-verifies, leaves changes uncommitted; the orchestrator gates (`flutter analyze` + `flutter test`) and owns every commit. No merges (single working tree). AFK run — git allowlisted in tracked `.claude/settings.json` (commit `77ed463`).

| Brief | Status | Wave | Merged SHA | Criteria | Note |
|---|---|---|---|---|---|
| 01-theming-foundation       | integrated | 1 | 18b2ba1 | 8/8 | |
| 02-custom-components        | integrated | 2 | 456ffa5 | 8/8 | API differs from brief sketch — see notes |
| 03-launcher-tabbar          | integrated | 2 | d6c32bb | 7/7 | |
| 04-launcher-shell-nav       | running | 3 | — | — | |
| 05-brief-screen             | pending | 4 | — | — | |
| 06-modules-screen           | pending | 4 | — | — | |
| 07-stub-and-profile-screens | pending | 4 | — | — | |
| 08-reskin-lists             | pending | 4 | — | — | |
| 09-reskin-clock             | pending | 4 | — | — | |
| 10-reskin-workouts          | pending | 4 | — | — | |

Status values: `pending` → `running` → `integrated` | `blocked` | `partial`.
(Waves are the logical DAG layers; execution is serialized within and across them.)

## Handoff notes

- **01 → [02, 03, 08, 09, 10]:** Read design tokens Material can't express from `BasecampTokens` (`lib/core/tokens.dart`) via `Theme.of(context).extension<BasecampTokens>()!` — `joy/joyTint/joyInk`, `shadows` (xs..xl `List<BoxShadow>`), `radii` (xs/sm/md/lg/xl/xxl/full), `spacing` (s0..s12 + gutter/gutterTight/contentMax/tapMin), `motion` (instant/fast/base/slow/slower durations + standard/easeOut/easeIn/spring curves), dormant `moduleTint`. Don't hardcode. (constraint)
- **01 → [02, 05, 09]:** Reusable `numericTextStyle({fontSize,fontWeight,height,color})` exported from `lib/core/theme.dart` — applies `FontFeature.tabularFigures()`. Use for timers/stopwatch/stats/durations/alarm times/counts; no monospace face. (constraint)
- **01 → [07]:** Theme mode = `themeModeProvider` (`NotifierProvider<ThemeModeController, ThemeMode>`) in `lib/core/settings.dart`. Profile calls `ref.read(themeModeProvider.notifier).set(ThemeMode.x)` to change+persist and `ref.watch(themeModeProvider)` to read. Persisted in generic `ModuleData` JSON lane (`settingsModuleId`/`settingsEntryKey`), no schema change. (contract-change)
- **01 → [all]:** `themeModeProvider` hydrates the persisted mode asynchronously (returns `ThemeMode.system` until the load resolves; an in-flight `set()` is guarded). Tests asserting the hydrated value must await the state transition, not read synchronously. (gotcha)
- **02 → [05, 06, 07, 08, 09, 10]:** Import all custom components via `package:basecamp/core/widgets/components.dart`. APIs (differ from brief's React sketch): `BcBadge(label:, tone: BadgeTone{neutral,brand,module,success,warning,danger}, dot:)` — named BcBadge to avoid Material's Badge. `ProgressRing(value:, size:, thickness:, label:)` — value accepts fraction [0,1] or percentage (>1 = %), clamps; `label` optional center Widget. `Stat(value:String, unit?, label?)`. `Tag(label:, icon?, onRemove?)`. `BcListItem(leading?, title:String, subtitle?, trailing?, onTap?, done:)` + `BcListItemIcon(IconData)` leading-tile helper + `BcListGroup(children: List<BcListItem>)` for single-hairline grouped rows. `SegmentedControl<T>(options: List<SegmentOption<T>>, value:, onChanged:)` — generic, custom (not Material SegmentedButton). (contract-change)
- **02 → [any using Badge success/warning]:** `BcBadge` success/warning tones use design-system green/amber constants inside `badge.dart` (`_kSuccess*/_kWarning*`), since 01 surfaced no success/warning ColorScheme roles. danger/brand/module/neutral resolve from the theme. Works as-is; swap to a token if 01's tokens later gain success/warning. (gotcha)
- **03 → [04]:** Widget is `LauncherTabBar<T>` (generic). `items: List<LauncherTabItem<T>>` (`LauncherTabItem(value:T, label:String, icon:IconData)`), `value: T`, `onChange: ValueChanged<T>`, optional `centerAction: LauncherCenterAction(icon:IconData, label:String, onClick:VoidCallback)`. The center action has **no `value`** — cannot collide with a destination. It already wraps itself in `SafeArea(top:false)` — do NOT double-wrap. Place in `Scaffold.bottomNavigationBar`. Import via `package:basecamp/core/widgets/components.dart`. (contract-change)

## Deviations

- **01:** Settings persistence lives in new `lib/core/settings.dart` (`SettingsStore` + `themeModeProvider`) writing AppDb's generic `ModuleData` lane directly (`moduleId='settings'`, `entryKey='app'`), not a module DAO — settings are cross-cutting, no schema change. No downstream brief assumed otherwise → no amendments.
- **01:** Joy accent also mapped to `ColorScheme.tertiary` (so stock Material tertiary-using widgets pick up sun yellow); canonical read remains `BasecampTokens.joy`.
