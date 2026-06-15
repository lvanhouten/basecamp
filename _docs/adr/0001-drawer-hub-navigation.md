---
status: accepted
date: 2026-06-15
deciders: Development
---

# Drawer-launched hub navigation, not a bottom navigation bar

Basecamp is a hub of modules (Brief, Lists, Workouts, Clock) with 5+ modules
expected. Navigation is a drawer launched from the Brief (the home screen);
modules are kept alive as `IndexedStack` peers and the drawer is reachable from
every module root. Where you land is derived from persisted domain state — a
module opens into its In-progress activity if one exists, and the Brief shows a
Resume banner — rather than from a remembered navigation stack.

## Decision Drivers

- 5+ top-level modules expected. Material guidance favors a bottom navigation bar
  only for 3–5 destinations; beyond that a drawer scales without crowding.
- "Switch modules from anywhere, come back to where I was, without back-button
  spam" — e.g. leave an in-progress workout to add a grocery item, then return to
  the workout.
- Standing project rule: Drift is the source of truth; UI state should be
  reconstructable from data, so navigation shouldn't be the thing that remembers.

## Considered Options

- **Bottom NavigationBar (status quo)** — conventional for ≤5 destinations; doesn't
  scale past that and spends permanent vertical space.
- **Pure push-and-back spoke** — Brief pushes a module, back returns. Rejected: loses
  your place and forces back-button spam — fails the workout scenario.
- **Per-module nested navigators (go_router `StatefulShellRoute`)** — preserves each
  module's full navigation stack across switches. Rejected for now: adds go_router
  plus a routing layer to maintain, and is unnecessary once landing is derived from
  domain state.
- **Drawer-launched hub + `IndexedStack` peers + domain-state landing (chosen)** —
  instant switching, no back-spam, and resumption falls out of the data.

## Consequences

- Each module owns its own chrome (AppBar + FAB) and sits on the shared drawer.
  Adding a module is additive: one `AppModule` enum case + a self-contained screen.
- In-progress activities must be modeled as persisted state (e.g. a Workout with no
  finish time); each module's `XApi` may expose its In-progress activity for the
  Brief's Resume banner. (Forward-looking — Workouts and Clock are still stubs.)
- Deep sub-screens (e.g. a list's detail) are pushed over the shell with a back
  arrow and no drawer; acceptable because resumable activities surface as module
  roots, not deep pushes.
- If we later want to drawer-hop directly out of a deep sub-screen and return to it
  untouched, revisit the nested-navigator option.
