# basecamp — App UI kit

An interactive, click-through recreation of the basecamp mobile app. The nav is a
**4-tab + center-FAB launcher**: `Brief · Calendar · ⊕ Add · Activity · Modules`.

- **Brief** (forward) — the daily digest: greeting, today's progress, what's up next, later this week. Profile lives on the header avatar.
- **Calendar** (when) — a cross-module view of every dated item; **Week** (default) and **Month** toggle.
- **⊕ Add** — global quick-capture sheet (type, pick a destination chip; time-phrases auto-route).
- **Activity** (back) — completion feed with an insights header; **You / Friends** toggle.
- **Modules** (launcher) — the grid of your spaces (Lists, Workouts, Clock) plus add-a-module suggestions; tiles open each module as a pushed view with a back arrow.

The three modules (Lists, Workouts, Clock) are pushed views launched from Brief or Modules —
they are not tabs, which is what keeps the nav stable as modules are added.

## Run it
Open `index.html`. Tap a module tile (in Modules or Brief) to open it, tap **⊕** to
quick-add, and use the light/dark toggle (top-right) to switch themes. View and theme
persist across reloads.

## What's interactive
- **Brief** — glanceable; items deep-link into their module or the calendar.
- **Calendar** — switch Week/Month, tap any day to see that day's agenda across all modules.
- **Add** — type, pick List item / Workout / Timer / Alarm (a time-like phrase nudges the choice), confirm with a toast.
- **Activity** — You/Friends toggle; insights header with a 7-day spark.
- **Lists** — check/uncheck, filter All/Open/Done, add via the bar.
- **Workouts** — check off exercises; ring + counts update live.
- **Clock** — working Timer, Stopwatch (with laps), and Alarm toggles.

## Files
| File | Role |
|---|---|
| `index.html` | App shell: launcher nav, view routing, pushed module views, theme toggle, scaling. |
| `kit.css` | Layout-only styles (phone frame, screens, tiles, calendar, Add sheet, Activity). |
| `icons.jsx` | Lucide-style icon set → `window.BC.Icons`. |
| `Shell.jsx` | `PhoneFrame`, `StatusBar`, `ScreenHeader` → `window.BC.Shell`. |
| `BriefScreen.jsx` · `CalendarScreen.jsx` · `ModulesScreen.jsx` · `ListsScreen.jsx` · `WorkoutsScreen.jsx` · `ClockScreen.jsx` · `ActivityScreen.jsx` | The screens → `window.BC.Screens`. |
| `AddSheet.jsx` | The global quick-capture bottom sheet → `window.BC.AddSheet`. |

The bottom bar is the design system's `TabBar` with its `centerAction` (the ⊕ FAB) — the
kit dogfoods the component rather than re-implementing it.

## Theming
Screens set `data-module="…"` on their root (currently all resolve to the coral brand;
modules are differentiated by icon). Wrap anything in `data-theme="dark"` for dark mode.

> Recreation for prototyping — interactions are faked in-memory; there is no backend.
