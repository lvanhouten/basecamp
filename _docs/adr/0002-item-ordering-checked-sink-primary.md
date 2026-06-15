---
status: accepted
date: 2026-06-15
deciders: Development
---

# Item ordering: checked-sink primary, manual position secondary

List items sort by `done ASC, position ASC` — checked items still sink to the
bottom, while a user-chosen manual order (`position`) controls sequence *within*
the checked and unchecked groups. This lets a grocery list hold an aisle order
among its unchecked items without losing the "cross it off and it drops away"
behaviour that backlog-style lists (movies, books) rely on.

## Decision Drivers

- Two list archetypes with opposite needs share one screen: **shopping** lists
  want a stable manual (aisle) order; **backlog** lists want checked items to
  disappear downward. One sort must serve both with no per-list configuration.
- No regression — an un-reordered list must look identical to the pre-feature
  app (unchecked first, oldest first).
- Hard rule: Drift is the source of truth, so order is a persisted column, not
  view state.

## Considered Options

- **Pure `position` sort** — checked items frozen in place, only struck-through.
  Best for a stable aisle map mid-shop, but regresses every backlog-style list
  where sinking is the wanted behaviour.
- **Per-list "sort mode" setting** — each list picks manual-vs-auto and
  sink-vs-freeze. Maximal flexibility, but adds a settings surface and a mode
  column to every list; overkill for a personal single-user app.
- **`done ASC, position ASC` (chosen)** — checked-sink stays the primary key,
  manual `position` the secondary. A strict superset of current behaviour;
  aisle order is held within the unchecked group; zero per-list config.

## Consequences

- `ListItems` gains a `position` column (schema v2), defaulted to creation order
  so un-reordered lists are byte-for-byte unchanged.
- Manual order is honoured *within* each done-group, not across the whole list:
  a checked grocery item sinks but keeps its relative aisle position among the
  checked. A future reader should not expect drag order to override checked-sink.
- If a list ever genuinely needs checked items frozen in place (a stable aisle
  map you don't want shifting mid-shop), that's a per-list opt-in to revisit —
  explicitly deferred here.
- Lists themselves use the parallel rule `pinned DESC, position ASC` — same
  `position` mechanism, different primary key (pin instead of done).
