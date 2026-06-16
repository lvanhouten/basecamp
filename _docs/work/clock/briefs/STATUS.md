# Execution status — clock

| Brief | Status | Wave | Merged SHA | Criteria | Note |
|---|---|---|---|---|---|
| 01-clock-math      | pending | 1 | — | — | |
| 02-clock-shell     | pending | 1 | — | — | |
| 06-alarm-recurrence | pending | 1 | — | — | |
| 03-stopwatch       | pending | 2 | — | — | |
| 04-timer-data      | pending | 2 | — | — | codegen: Timers table (+pubspec, manifest) |
| 05-timer-ui        | pending | 3 | — | — | |
| 07-alarm-data      | pending | 3 | — | — | codegen: Alarms table (+manifest) |
| 08-alarm-ui        | pending | 4 | — | — | sole brief |

## Dependency graph

- 01-clock-math → none
- 02-clock-shell → none
- 06-alarm-recurrence → none
- 03-stopwatch → 01, 02
- 04-timer-data → 01, 02
- 05-timer-ui → 04
- 07-alarm-data → 02, 04, 06
- 08-alarm-ui → 07

## Run model

- Workers self-verify in their worktree via the full flutter path (`/c/Users/Lukas5856/dev/flutter/bin/flutter.bat`); allowlist now committed to `.claude/settings.json` so worktrees inherit it.
- **Orchestrator owns codegen + generated files**: workers never run `build_runner` and never commit `*.g.dart`. I regenerate centrally after each merge.
- I re-gate every merge centrally: `flutter pub get` (if pubspec changed) → `build_runner` (if tables/DAOs changed) → `analyze` → `test`.
- Push straight through all waves; stop only on blocked/partial, semantic conflict, or a deviation invalidating a downstream brief.

## Handoff notes

_(none yet)_

## Deviations

_(none yet)_
