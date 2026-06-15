# Workouts

**Module:** `lib/features/workouts/` · **Status:** Planned (stub screen) · **Nav label:** Workouts

## Purpose

A strength-training log to replace the **Strong** app. Record workout sessions
made of exercises, each with sets (reps × weight). Review history and progress
over time. This is the richest module — genuinely relational data.

## Behaviour (intended)

- Start a workout session → add exercises → log sets (reps, weight) per exercise.
- Finish a session; it lands in a dated history feed.
- Browse past workouts; later: per-exercise progress, volume, PRs.
- Reuse exercises from a catalog (don't retype "Bench Press" each time).

## Data model (proposed — relational)

Queried/aggregated heavily (history, volume, PRs), so real tables, not JSON:

- `Workouts` — `id`, `name` (e.g. "Push day"), `startedAt`, `finishedAt?`.
- `Exercises` — `id`, `name`, optional `muscleGroup` (a catalog).
- `WorkoutExercises` — join: `id`, `workoutId` (FK), `exerciseId` (FK), `order`.
- `ExerciseSets` — `id`, `workoutExerciseId` (FK), `setNumber`, `reps`, `weight`, `done`.

All child tables use `onDelete: cascade`. New tables → additive migration (bump `schemaVersion`).

## Public contract — `WorkoutsApi` (proposed)

For the Brief and future stats:

- `Stream<Workout?> watchLastWorkout()` — for the brief's "Last: Push day · 2 days ago".
- `Stream<int> watchThisWeekCount()` — sessions this week (optional).

## Events (proposed)

- Publishes `WorkoutCompleted(name, duration)` when a session is finished. Natural consumers: Brief (refresh/celebrate), Clock (offer a cooldown), a future stats module.
- Consumes: possibly a Clock "rest timer finished" event (`TimerFinished`).

## Screens (planned)

- `workouts_screen.dart` — currently a stub empty-state. Becomes the history feed + "Start workout".
- `active_workout_screen.dart` — live session: add exercises, log sets.
- `exercise_picker` — choose from / add to the exercise catalog.

## Open questions / ideas

- Rest timer between sets — integrate with the Clock module via the event bus rather than duplicating timer logic.
- Templates / routines (a saved workout you instantiate).
- Units: kg vs lb (a setting; store canonical, display converted).
- Import history from Strong? (CSV export exists) — one-off importer.
- Progress charts (needs a charting package).

## Changelog

- 2026-06-15 — Stub screen only. Data model + contract + events sketched here; not built.
