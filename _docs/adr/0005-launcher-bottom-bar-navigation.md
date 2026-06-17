---
status: accepted
date: 2026-06-17
deciders: Development
---

# Launcher bottom-bar navigation, superseding the drawer hub (ADR-0001)

Basecamp adopts the design-system **launcher** navigation: a fixed bottom bar of four
destinations — **Brief**, **Calendar**, **Activity**, **Modules** — split 2/2 around a
raised center **⊕ Quick add** FAB. Modules (Lists, Workouts, Clock) are no longer
top-level navigation destinations; they are **launched as pushed views** from the Modules
grid (and from Brief affordances), with a back arrow to return. Where you land on
re-entering a module is still derived from persisted domain state. This supersedes
ADR-0001's drawer + `IndexedStack`-peers model.

## Context / why revisit ADR-0001

ADR-0001 chose a drawer hub with modules kept alive as `IndexedStack` peers, rejecting a
bottom bar because "5+ modules won't fit." A from-scratch design system (built with Claude
Design, in `_docs/design-system/`) subsequently defined basecamp's visual and interaction
language around a launcher bottom bar. Reconciling the app against it — the design system's
own stated intent — reopened the navigation decision deliberately, not by accident.

## Decision Drivers

- Adopt the commissioned design language faithfully; the launcher bar is its signature chrome.
- The "5+ modules" scaling objection that killed the bottom bar in ADR-0001 is **dissolved by
  a dedicated Modules launcher tab**: modules live behind it as a grid, so the bar never grows
  with module count.
- Standing rule: Drift is the source of truth; navigation should not be the thing that
  remembers. Push-and-return + domain-state landing honors this *more* directly than
  kept-alive `IndexedStack` peers.

## Considered Options

- **Keep ADR-0001 (drawer + IndexedStack peers)** — rejected: diverges from the adopted
  design system; the drawer is no longer the product's chrome.
- **The kit's original 2-tab launcher (Home · ⊕ · Activity), modules launched from Home** —
  rejected: clutters the home screen with the module grid and offers only two persistent
  destinations.
- **4-tab launcher (Brief · Calendar · ⊕ · Activity · Modules), modules pushed from Modules
  (chosen)** — declutters the Brief into a digest, gives modules a dedicated, scalable home,
  and adds Calendar/Activity destinations (stubbed now).
- **Keep the IndexedStack under a launcher skin** — rejected: fakes push/back and keeps four
  module screens warm for no benefit now that landing is derived from Drift.

## Consequences

- The drawer (`AppDrawer`) and the `IndexedStack` shell (`home_shell.dart`) are replaced by a
  launcher shell: a 2/2 bottom bar + center FAB hosting Brief/Calendar/Activity/Modules, with
  modules pushed over it via the `Navigator`.
- Re-entering a module must **land on its in-progress activity** (running Timer, unfinished
  workout) by reading Drift — preserving ADR-0004's multi-activity resume, now surfaced on the
  Brief/Modules tiles rather than a drawer Brief. This is the one behavior push-nav must not
  regress.
- **Modules** is a navigation destination that *indexes* modules; it is not itself a Module.
  Adding a module is still additive (an `AppModule` enum case + screen) and now appears as a
  Modules-grid tile, never a new bar slot.
- **Calendar** and **Activity** ship as **stubs** (placeholder content) so the bar is honest;
  their real features — a cross-module scheduling model, and a completion feed — are deferred.
  **Quick add** (⊕) ships as a **button only**; its global quick-capture sheet is deferred.
- **Settings** is reached via a **profile avatar** in the Brief header (top-right), not a bar
  slot; it hosts the light/dark theme toggle.
- The `AppModule` enum no longer drives the bottom bar's destinations (it drives the Modules
  grid instead). `selectedModuleProvider` / `selectedClockTabProvider` semantics are revisited
  during implementation.

## Links

- Supersedes: ADR-0001 (drawer-hub navigation).
- Relates to: ADR-0004 (multi-activity resume — resume affordances move to Brief/Modules tiles).
- Design system: `_docs/design-system/` — launcher pattern in `components/navigation/TabBar`
  and `ui_kits/basecamp-app/` (Brief/Calendar/Activity/Modules screens + the 4-item bar).
