# Basecamp

A personal life-tracker "super-app": one hub with many self-contained modules
(Lists, Workouts, Clock), reached through a launcher bottom bar
(Brief · Calendar · ⊕ · Activity · Modules — see ADR-0005). This glossary fixes
the words the app and its docs use, so the same concept isn't called three things.

## Language

**Brief**:
The hub's front door — a forward-looking daily digest, and one of the four
bottom-bar destinations. Shows today's progress and the next time-bound items
(today's enabled **Alarms**, running **Timers**), and surfaces **Resume**
affordances. No longer hosts a navigation drawer (removed in ADR-0005) and no
longer carries the module grid (that moved to **Modules**). Its top-right avatar
opens **Profile**.
_Avoid_: home, dashboard (as proper nouns).

**Calendar**:
A bottom-bar destination, currently a **stub**. Reserved for a future
cross-module schedule/agenda view (timed and dated entries across modules). No
scheduling data model exists yet; shipped as a placeholder so the bar is complete.

**Activity**:
A bottom-bar destination, currently a **stub**. Reserved for a future completion
feed plus insights (e.g. counts, streaks) — a record of _finished_ things.
Distinct from an **In-progress activity** (unfinished, resumable work): Activity
is about what is done, not what is open.
_Avoid_: conflating with **In-progress activity** — same word, opposite sense.

**Modules** (the destination):
The bottom-bar destination that indexes every **Module** as a launcher grid;
tapping a tile pushes that module's screen. Modules is a navigation destination,
_not_ itself a Module (it contains them); it also hosts "add a module"
affordances. Because modules live behind it, the bar never grows as modules are
added.
_Avoid_: calling the Modules destination "a module".

**Quick add** (⊕):
The center FAB in the bottom bar — a global quick-capture action (route a typed
entry to a list item / workout / timer / alarm). An **action, never a selected
destination**. Currently shipped as a **button only**; the capture sheet is deferred.

**Profile**:
The settings surface, reached from the **Brief**'s top-right avatar — not a
bottom-bar destination. Hosts app settings, starting with the light/dark theme
toggle.
_Avoid_: Settings as a separate proper noun; settings live under Profile.

**Module**:
A self-contained feature area launched from the **Modules** destination (Lists,
Workouts, Clock, …), opened as a pushed view. Modules never reference each other
directly. **Goals** and **Journal** exist as **stub modules** — real tiles that
push a placeholder screen, with no data layer yet (built as their own features later).
_Avoid_: sub-app, tab, feature (informal).

**In-progress activity**:
An unfinished, resumable unit of work owned by a module and derived from
persisted state (e.g. a workout with no finish time). It exists because the data
says so — not because of any remembered navigation state. A module may own
**several at once** (Clock can have running Timers and a running Stopwatch
together); the Brief summarizes them rather than assuming exactly one.
_Avoid_: open activity. A module may name its own concretely (e.g. "active workout").

**Resume**:
Returning to an In-progress activity. Surfaced two ways: on the **Brief** and the
**Modules** tiles (a banner, or a counts summary for a multi-activity module), and
a module opening straight into the relevant activity when entered. When a module
has several, a fixed tool precedence picks which one it opens to
(Clock: Stopwatch > Timer > Alarm).

**Clock**:
The time-tools module: Alarms, a Timer, and a Stopwatch.
_Avoid_: Timers — the former module name, which collided with the Timer tool.

**Tool**:
One of the three time utilities _inside_ the Clock module: the Timer, the
Stopwatch, and Alarms. Tools live under one Module; they are not themselves
Modules (not bottom-bar destinations, not isolated from each other).
_Avoid_: sub-module, sub-app, tab (a tab is how a tool happens to be presented,
not what it is).

**Timer**:
The countdown tool _inside_ Clock — one tool of three. Singular.
_Avoid_: using "Timer"/"Timers" to mean the Clock module.

**Alarm**:
A Clock entry that rings at a wall-clock time, one-off or recurring. Carries an
**Enabled** state and (if recurring) a repeat rule. Rings via the OS even when
the app is dead.

**Snooze**:
Defer a _ringing_ Alarm's current occurrence by a fixed interval; it re-rings
after that interval. Affects only this occurrence, never the repeat rule.

**Dismiss**:
End a _ringing_ Alarm's current occurrence. A one-off Alarm becomes disabled
(it is spent); a recurring Alarm stays **Enabled** and rings again at its next
scheduled time. The ring-time "stop" action.
_Avoid_: disarm, stop, cancel — and never let it mean "disable the whole alarm"
(that is the **Enabled** toggle).

**Enabled**:
The list-level on/off state of an Alarm. Off means it never rings, even if
recurring — the true "turn this alarm off." Distinct from **Dismiss**, which
ends one occurrence only.
_Avoid_: disarm, active.

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

- The **Modules** destination indexes and launches every **Module** (as a pushed view);
  the **Brief** summarizes today's progress and surfaces **Resume**.
- A **Module** may own one or more **In-progress activities**, which the **Brief** and
  **Modules** tiles surface for **Resume**.
- The bottom bar has four destinations — **Brief**, **Calendar**, **Activity**,
  **Modules** — split around the center **Quick add** (⊕). **Calendar** and **Activity**
  are stubs; **Profile** is reached from the Brief avatar, not the bar.
- **Clock** contains three **Tools**: a **Timer**, a **Stopwatch**, and **Alarms**.
- A ringing **Alarm** can be **Snoozed** (re-rings later) or **Dismissed** (ends this
  occurrence); its **Enabled** toggle is separate and governs whether it rings at all.

## Flagged ambiguities

- "Timers" meant both the time-tools module and the countdown tool within it —
  resolved: the module is **Clock**, the countdown tool is **Timer**.
- "sub-module" was used for Timer/Stopwatch/Alarms — resolved: these are **Tools**
  inside the Clock **Module**, not modules of their own.
- "Disarm" was used for the ring-time stop action — resolved: that action is
  **Dismiss** (ends this occurrence only); disabling an alarm entirely is the
  **Enabled** toggle.
- "Home" (the design system's label for the launcher digest) vs **Brief** (our
  canonical term) — resolved: the screen is the **Brief**; "home" is avoided.
- **Activity** (the bottom-bar feed, a future feature) vs **In-progress activity**
  (resumable, unfinished work) — same word, opposite sense (finished vs unfinished).
  The feed keeps the label **Activity** for now; its precise canonical term is
  **deferred** until the feed is actually built (candidates: Recap / History / Your week).
