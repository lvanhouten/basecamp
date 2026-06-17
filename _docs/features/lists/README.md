# Lists

**Module:** `lib/features/lists/` · **Status:** Built · **Nav label:** Lists

## Purpose

Track arbitrary lists — groceries, movies to watch, books, anything. Exists
because Google Keep is a poor UX for repeated check-off lists. Each list is a
named collection of items you can check off and delete.

## Behaviour

- See all lists with a live count of unchecked items.
- Create a list (name prompt); swipe a list to delete (cascades to its items).
- Open a list → see its items; add items; check/uncheck; swipe to delete.
- Checked items sort to the bottom; unchecked stay on top (ordered by `done`, then `createdAt`).

## Data model

Relational — the app queries item state, so items are real rows, not JSON.

- `TrackedLists` — `id`, `name`, `createdAt`.
- `ListItems` — `id`, `listId` (FK → `TrackedLists`, `onDelete: cascade`), `label`, `done`, `createdAt`.

Schema v2 (planned) adds `pinned`/`position` to `TrackedLists` and `position` to `ListItems` — see [Planned](#planned--pin-rearrange-rename-undo) and [ADR-0002](../../adr/0002-item-ordering-checked-sink-primary.md).

## Public contract — `ListsApi` (`core/contracts/lists_api.dart`)

What other modules (e.g. the Brief) may use. Nothing else about Lists is public.

- `Stream<int> watchOpenItemCount()` — unchecked items across all lists.
- `Stream<int> watchListCount()` — number of lists.

Implemented by `ListsRepository`, which also exposes module-internal methods
(`watchLists`, `watchItems`, `createList`, `addItem`, `toggleItem`, `delete…`)
used only by the Lists UI.

## Events

- Publishes `ListItemToggled(itemId, done)` on check/uncheck — a live signal only; the durable effect is the Drift write. No consumers yet.
- Consumes: none.

## Screens

- `lists_screen.dart` — all lists + open-counts; FAB creates a list. Hosts the shared `promptForText` dialog helper.
- `list_detail_screen.dart` — items of one list; checkboxes + add + swipe-delete.

## Planned — Pin, Rearrange, Rename, Undo

Designed 2026-06-15; **not yet built.** Adds manual ordering + delete-safety to
both screens.

### Lists screen

- **Pin** a list → it floats to a Pinned section at the top; unpinned lists sit
  below. Sort: `pinned DESC, position ASC`.
- **Rearrange** by dragging a row's handle. Reorder is *within a section only* —
  pinning is the only way to cross between pinned and unpinned.
- **Rename** a list (long-press → menu).
- New lists land at the **top** of the unpinned block.

### Detail screen

- **Rearrange** items by drag handle. Sort: `done ASC, position ASC` — checked
  items still sink, but a manual (e.g. aisle) order is held within the unchecked
  group. See [ADR-0002](../../adr/0002-item-ordering-checked-sink-primary.md).
- **Rename** an item (long-press → menu).
- New items append at the **bottom** of the unchecked group.

### Both screens

- **Undo delete** — swipe (or menu → Delete) removes the row and shows a Material
  SnackBar with UNDO for a few seconds. Hard delete + in-memory restore (a
  deleted list restores its items in one transaction); no soft-delete column. If
  the app dies during the window, the delete stands.
- Row gestures: tap = open/toggle · drag handle = reorder · long-press = menu
  (Pin / Rename / Delete) · swipe = delete.

### Schema (v2, additive)

- `TrackedLists`: `+ pinned`, `+ position`. `ListItems`: `+ position`.
- Backfill existing rows by `createdAt` rank (lists global; items partitioned by
  list) → dense, 0-based positions.

## Open questions / ideas

- List icon/color per list (loose metadata — candidate for a JSON column rather than new columns).
- Item notes, quantities (only promote to columns if queried/sorted). Due dates promoted to [Future Enhancements](#future-enhancements).
- Archive vs delete; "clear completed" action.
- Manual item order frozen in place per-list (checked items don't sink) — deferred opt-in, see ADR-0002.

## Future Enhancements

- **Surface the pinned list on the Brief.** A pinned list is "the list I care about
  most right now" (e.g. an active Groceries run). The Brief could show its name +
  open count specifically (`watchPinnedListSummaries()` on `ListsApi`) instead of
  only the global unchecked total. Deferred to keep this iteration's pin/order
  purely internal to Lists; revisit as its own small feature.

- **Optional due date / "remind me" — on lists *and* items.** An optional `dueAt`
  timestamp on a whole list ("Pack for trip" by Friday) *and* on individual items
  ("call dentist" by Tuesday). Same nullable column on both tables, same UX
  (a date/time picker on create/rename); they differ only in scope. Two layers,
  separable — build the first, defer the second:
  - *Display* — anything with a `dueAt` shows it and surfaces on the Brief as
    due-soon/overdue. Pure Lists-internal: a nullable `dueAt` column on
    `TrackedLists` **and** `ListItems` (additive, schema v3-or-later), each
    queryable for sorting/filtering by due date. The Brief reads upcoming due
    items/lists through a new `ListsApi` method (e.g. `watchUpcomingDue()`).
  - *Reminder* — fire an OS notification when a `dueAt` arrives, even if the app
    is dead. This is **not** a Lists concern: scheduling persistent notifications
    belongs to the Clock module (`flutter_local_notifications`, `endsAt`
    timestamps). Lists would request a reminder through a shared contract/event,
    never by importing Clock (hard rule 1). Blocked on Clock existing; revisit
    then.

  Build `dueAt` storage + display (both scopes) first; reminders are a follow-on
  once Clock lands.

## Changelog

- 2026-06-15 — Designed Pin / Rearrange / Rename / Undo-delete (grilling session). See [Planned](#planned--pin-rearrange-rename-undo) + [ADR-0002](../../adr/0002-item-ordering-checked-sink-primary.md). Not yet implemented.
- 2026-06-15 — Initial build. Full CRUD, reactive counts, verified to persist across a force-stop/cold-start. First module proving the Drift + Riverpod + contracts + event-bus architecture end to end.
