## Agent Brief

**Category:** enhancement
**Summary:** Replace the Brief placeholder with the real digest: greeting + date + profile avatar, a progress ring, and an "Up next today" group fed only by genuinely time-bound data (today's enabled alarms + running timers).

**Current behavior:**
The Brief placeholder from the shell brief is empty/minimal. The pre-existing Brief was a list of three module summary cards (Lists / Workouts / Clock) plus a greeting and date, and it hosted the drawer.

**Desired behavior:**
The Brief is a forward-looking daily digest (one of the four bar destinations), styled in the design language:

- A hero with a **time-based greeting** ("Good morning/afternoon/evening"), a **date eyebrow** (e.g. "Tuesday · Jun 16"), and a **profile avatar in the top-right** that opens the Profile screen.
- A **progress card**: a `ProgressRing` showing today's completion with an "N of M done today" line, derived from the Lists open/done counts (via the existing list-count and open-item-count read models, which go through the lists contract). Use an encouraging caption in the brand voice.
- An **"Up next today"** group: rows for the genuinely time-bound items only — **today's enabled alarms** (with their wall-clock times) and **running timers** (with remaining/finish info) — rendered as design-system list rows. Tapping a row opens the relevant module (pushed, landing on its in-progress activity). The mockup's "Later this week" section is **omitted** (no scheduling model exists).
- The Brief no longer shows the three module summary cards — those summaries move to the Modules grid (`06`).
- All copy follows the brand voice (sentence case, no emoji, encouraging not nagging); the empty/quiet state is one calm line.

**Key interfaces:**

- Consumes the existing read models for list count + open-item count (through the lists contract), today's enabled alarm data, and the running-timers stream (through the clock contract / repository) — **reusing** them, not redefining them.
- Uses `ProgressRing`, `BcListItem`, and `Badge` from `02`, and the theme/type from `01`.
- Opens modules via the shell's push routing from `04` (so a tapped "up next" row lands on the right module/in-progress activity).

**Acceptance criteria:**

- [ ] The Brief renders the greeting (time-of-day correct), date eyebrow, and a top-right avatar that navigates to Profile.
- [ ] The progress card shows a ProgressRing + "N of M done today" derived from live list data; with no lists/items it shows a calm zero-state.
- [ ] "Up next today" lists today's enabled alarms and running timers (and only those); with none, it shows a one-line empty state. No "Later this week" section exists.
- [ ] Tapping an "up next" row opens its module via push and lands appropriately (e.g. a running-timer row opens Clock on the Timer tool).
- [ ] The Brief no longer renders module summary cards.
- [ ] Copy is sentence case, emoji-free, encouraging.
- [ ] `flutter analyze` clean; `flutter test` passes.

**Out of scope:**

- The module summary tiles — moved to `06-modules-screen` (this brief stops showing them; it does not build the grid).
- Adding any scheduling/date data model or the "Later this week"/Calendar agenda — deferred (Calendar is a stub, see `07`).
- The shell, bar, and push routing — built in `04`.

**Depends on:** 01-theming-foundation, 02-custom-components, 04-launcher-shell-nav (replaces the Brief placeholder; uses push routing)

**Runtime:** parallel-safe

**Design references:** `_docs/design-system/project/ui_kits/basecamp-app/BriefScreen.jsx` (substitute real single-user data for the mockup's fictional agenda rows; keep the progress card + "up next" structure), `_docs/design-system/project/readme.md` (Content fundamentals / voice).
