# Basecamp Features

Living documentation for each module. One folder per feature, mirroring
`lib/features/<module>/`. Each `README.md` grows as the feature evolves — keep
its **Status** and **Changelog** current, and append ideas under **Open questions**.

| Feature | Folder | Status | Summary |
|---|---|---|---|
| [Daily Brief](home/README.md) | `home` | Built (aggregating) | Home screen; summarizes the other modules on open |
| [Lists](lists/README.md) | `lists` | Built | Arbitrary tracked lists (groceries, movies, …) |
| [Workouts](workouts/README.md) | `workouts` | Planned | Strength-training log; replaces the "Strong" app |
| [Clock](clock/README.md) | `clock` | Planned | Alarms, countdown Timer, stopwatch (formerly "Timers") |

## Doc template

Each feature doc follows the same shape so they read consistently and new
sections have an obvious home:

- **Purpose** — why it exists, in one paragraph.
- **Behaviour** — what the user can do.
- **Data model** — Drift tables or `ModuleData` JSON usage.
- **Public contract** — the `XApi` other modules may depend on (or "none").
- **Events** — `DomainEvent`s published/consumed.
- **Screens** — the widgets and navigation.
- **Open questions / ideas** — the growing backlog of decisions and wants.
- **Changelog** — dated, newest first.

See the root `CLAUDE.md` for the architecture rules these features must follow.
