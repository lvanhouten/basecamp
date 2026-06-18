## Agent Brief

**Category:** enhancement
**Summary:** Restyle the Clock module (Timer, Stopwatch, Alarms panes + the alarm ring screen) to the design language, preserving all existing behavior.

**Current behavior:**
The Clock tools are built and functional — countdown Timer(s), Stopwatch with laps, Alarms with enable/repeat and OS-scheduled notifications, and the full-screen alarm ring screen with Snooze/Dismiss (ADR-0003/0004) — but use stock Material styling. After the shell brief, Clock is a pushed module that lands on its precedence-selected tool.

**Desired behavior:**
Clock looks like the design system while behaving exactly as before:

- The tool tabs/panes (Timer, Stopwatch, Alarms) and the alarm ring screen adopt the design-language surfaces, cards, list rows, pill buttons, switches, segmented control, badges, and type from `01`/`02`.
- **Numeric displays use the tabular numeric style** — the large countdown/stopwatch readouts, durations, and alarm times — so digits don't jump (single typeface, tabular figures; no monospace).
- As a pushed module it presents a back arrow / appropriate chrome (no drawer) and still lands on the precedence-selected tool (Stopwatch > Timer > Alarms) per the shell routing.
- All existing behavior is unchanged: timer create/run/pause/resume/finish/dismiss, stopwatch start/stop/lap/reset, alarm create/enable/disable/repeat + scheduling, and the ring screen's Snooze/Dismiss + looping chime (ADR-0003).
- Copy follows the brand voice (sentence case, e.g. "Time's up", encouraging not nagging; no emoji).

**Key interfaces:**

- No data-layer, DAO, repository, scheduler, or provider changes — purely presentational. The clock read models, timer/stopwatch/alarm state, notification scheduler seam, and chime player seam are consumed unchanged.
- Uses themed Material widgets (`01`), the custom components (`02`), and the tabular numeric text style for readouts.

**Acceptance criteria:**

- [ ] Timer, Stopwatch, Alarms panes and the alarm ring screen render in the design language.
- [ ] Large numeric readouts (timer countdown, stopwatch elapsed, alarm times, durations) use tabular figures in the brand sans.
- [ ] All existing Clock behavior is preserved: timer lifecycle, stopwatch + laps, alarm enable/repeat/scheduling, ring-screen Snooze/Dismiss + looping chime; Clock still lands on the precedence-selected tool on entry.
- [ ] Works as a pushed route with no drawer; copy is sentence case, emoji-free.
- [ ] No changes to the clock data layer, scheduler, or providers; `flutter analyze` clean; existing Clock tests + `flutter test` pass.

**Out of scope:**

- Any behavior/data change to Clock — presentational only.
- The notification scheduler / chime player / alarm launch routing — unchanged (`04` keeps the launch host working).
- The theme and components themselves — built in `01`/`02`.

**Depends on:** 01-theming-foundation, 02-custom-components, 04-launcher-shell-nav (module screens are pushed, drawerless; precedence landing)

**Runtime:** parallel-safe

**Design references:** `_docs/design-system/project/ui_kits/basecamp-app/ClockScreen.jsx`, `_docs/design-system/project/guidelines/type-mono.card.html` + `type-roles.card.html` (numerics in the brand sans with tabular figures), `_docs/adr/0003-flutter-local-notifications-clock-foundation.md` + `_docs/adr/0004-clock-multi-activity-resume.md` (behavior to preserve).
