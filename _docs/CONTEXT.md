# Basecamp

A personal life-tracker "super-app": one hub with many self-contained modules
(Brief, Lists, Workouts, Clock). This glossary fixes the words the app and its
docs use, so the same concept isn't called three things.

## Language

**Brief**:
The home screen — a daily dashboard that summarizes each module, launches into
it, and hosts the navigation drawer. The hub's front door.
_Avoid_: home, dashboard (as proper nouns).

**Module**:
A self-contained feature area reachable from the Brief (Lists, Workouts, Clock,
…). Modules never reference each other directly.
_Avoid_: sub-app, tab, feature (informal).

**In-progress activity**:
An unfinished, resumable unit of work owned by a module and derived from
persisted state (e.g. a workout with no finish time). It exists because the data
says so — not because of any remembered navigation state.
_Avoid_: open activity. A module may name its own concretely (e.g. "active workout").

**Resume**:
Returning to an In-progress activity. Surfaced two ways: a banner on the Brief,
and a module opening straight into its In-progress activity when entered.

**Clock**:
The time-tools module: Alarms, a Timer, and a Stopwatch.
_Avoid_: Timers — the former module name, which collided with the Timer tool.

**Timer**:
The countdown tool *inside* Clock — one tool of three. Singular.
_Avoid_: using "Timer"/"Timers" to mean the Clock module.

**Pin / Pinned**:
Marking an entry as always-active so it floats to a dedicated section at the
top of its module, above the freely-rearranged rest. A presentation state, not
a content state — it changes grouping and order, nothing about the entry itself.
_Avoid_: favorite, star.

**Rearrange**:
Manually dragging entries into a chosen order that persists. Distinct from
**Pin** (which floats a few entries to a top section) and from **Sort** (an
automatic rule like by-date or checked-last). Rearrange sets the manual order
_within_ a section.
_Avoid_: reorder (informal synonym — pick one), move.

**Sort**:
An _automatic_ ordering rule the app applies (e.g. list items sort checked-last,
then by creation time). Contrast **Rearrange** (manual). When both apply, they
operate on different scopes — never the same one.

## Relationships

- The **Brief** summarizes and launches every **Module**.
- A **Module** may own one **In-progress activity**, which the **Brief** surfaces for **Resume**.
- **Clock** contains a **Timer**, one or more **Alarms**, and a **Stopwatch**.

## Flagged ambiguities

- "Timers" meant both the time-tools module and the countdown tool within it —
  resolved: the module is **Clock**, the countdown tool is **Timer**.
