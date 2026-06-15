# Daily Brief

**Module:** `lib/features/home/` · **Status:** Built (aggregating) · **Nav label:** Brief

## Purpose

The first thing you see when you open Basecamp. A glanceable summary of the
other modules — what's open, what's recent, what's due — so the app answers
"what do I need to know right now?" before you navigate anywhere.

## Behaviour

- Time-aware greeting ("Good morning/afternoon/evening") + today's date.
- One summary card per module. Tapping a card will deep-link into that module (not wired yet).
- The Brief owns no data of its own — every card reads another module's data **through that module's contract**, never its tables.

## Data model

None. This module is purely a consumer.

## Public contract

None — nothing depends on the Brief.

## Events

- Consumes: none yet. Could subscribe to `WorkoutCompleted`, alarm-fired, etc. to refresh or surface a toast.
- Publishes: none.

## Screens

- `home_screen.dart` — `ConsumerWidget`. Lists card is live (reads `listCountProvider` / `openItemCountProvider`, both backed by `ListsApi`); Workouts/Timers cards are still placeholder text.

## Open questions / ideas

- Make cards tappable → switch tab / push detail.
- "Today" focus: due alarms, today's planned workout, a list pinned for today.
- Optional: a small streak/stat strip once Workouts logs history.
- Should the brief be reorderable / cards toggleable per user preference? (would need a settings store)

## Changelog

- 2026-06-15 — Initial build. Greeting + date + 3 cards; Lists card wired live through `ListsApi`.
