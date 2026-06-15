# Basecamp — Claude Code Project Guide

Personal Flutter life-tracker "super-app": one hub, many sub-app modules
(daily Brief, Lists, Workouts, Clock). Android-first; iOS later (needs a Mac).
Personal use only — not published, so app-store/trademark concerns don't apply.

## Stack

- **Flutter** (stable) / Dart. Material 3, navigation-**drawer** hub shell (see `_docs/adr/0001-drawer-hub-navigation.md`).
- **State management: Riverpod** (`flutter_riverpod`) — also hosts DI and the event bus. No get_it.
- **Storage: Drift** (typed SQLite, reactive streams) via `drift_flutter`. Codegen with `build_runner`.

## Commands

Run from the project root (`flutter` is on PATH).

- Build/run: `flutter run` (pick the `flutter_pixel` emulator, or any device)
- Analyze: `flutter analyze`
- Test: `flutter test`
- **Drift codegen (after editing tables/DAOs): `flutter pub run build_runner build`** — regenerates `*.g.dart`. Nothing compiles until this runs.

### Build gotchas (learned the hard way)

- **Android Gradle builds need JDK 17+.** The system JDK is 8. VS Code's Flutter extension auto-uses Android Studio's bundled JBR, but for **terminal** `flutter build apk` / `flutter run` set `JAVA_HOME="C:\Program Files\Android\Android Studio\jbr"` or Gradle fails.
- Emulator: `%LOCALAPPDATA%\Android\Sdk\emulator\emulator.exe -avd flutter_pixel`.
- Hot reload covers `.razor`-equivalent (`.dart` widget `build` changes) but a full relaunch is safest after touching providers, DAOs, or generated code.

### Driving / inspecting the emulator

Prefer **`flutter run`** for dev — hot reload + live logcat, far faster than build→install→launch. For headless or scripted UI checks (e.g. verifying a screen without a human watching), drive the emulator with **`adb`** (`%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe`):

- Boot AVD: `…\emulator\emulator.exe -avd flutter_pixel`; wait with `adb wait-for-device` then poll `adb shell getprop sys.boot_completed` until `1`.
- Install / launch / kill: `adb install -r build/app/outputs/flutter-apk/app-debug.apk` · `adb shell monkey -p com.lukas.basecamp -c android.intent.category.LAUNCHER 1` · `adb shell am force-stop com.lukas.basecamp` (the last one is the persistence test — kill, relaunch, confirm Drift data survived).
- Inspect a screen: `adb exec-out screencap -p > shot.png`, then **Read the PNG** to see it. This is the cheap "does it look right" loop.
- Interact: `adb shell input tap X Y` · `input text "Milk"` (no spaces — use single words or `%s`) · `input keyevent 66` (Enter) / `4` (Back).

Notes / gotchas:
- `flutter_pixel` is **1080×2400**; `input tap` uses **raw device pixels**. Don't eyeball coordinates — capture a screenshot first and read positions off it (FAB/nav taps miss otherwise).
- **Playwright (in the global `~/.claude` config) is web-only — it cannot drive an Android emulator.** Don't reach for it here.
- For robust, coordinate-free UI automation, prefer `integration_test` + `flutter drive` (drives widgets in-app) over `adb input` tapping. The adb route is for quick visual checks, not regression tests.

## Architecture

Hub-with-modules. The shell (`lib/core/home_shell.dart`) keeps every module
alive in an `IndexedStack` and shows the one selected via `selectedModuleProvider`;
the navigation drawer (`core/widgets/app_drawer.dart`) and the Brief's cards
write that selection. Destinations come from the `AppModule` enum
(`core/app_module.dart`). Each module is a folder under `lib/features/<module>/`.
Layers, top to bottom:

```
Widget (ConsumerWidget)  → ref.watch(StreamProvider)
  → Repository (implements the module's XApi contract)
    → DAO (@DriftAccessor)  → Drift tables (SQLite on disk)
```

- `lib/core/db/` — `tables.dart`, `app_db.dart` (`@DriftDatabase`), `converters.dart` (`JsonConverter`).
- `lib/core/providers.dart` — `dbProvider`, `eventBusProvider`, repositories, and reactive read-model providers.
- `lib/core/contracts/` — abstract `XApi` facades. **The only thing one module may know about another.**
- `lib/core/events/` — `DomainEvent` (sealed) + `EventBus` (broadcast stream, hosted by `eventBusProvider`).
- `lib/features/<module>/data/` — that module's DAO + repository.

### Hard rules

1. **Modules never import each other.** Cross-module talk goes through `core/contracts/` (pull) or `core/events/` (push) only. A `features/X` importing `features/Y` is a bug.
2. **Drift is the source of truth.** Riverpod providers are reactive *views* over it — never the only copy of data. This is why state survives cold start for free.
3. **Events are transient.** Never persist a `DomainEvent`. If an effect must survive a restart, the handler writes it to Drift; the row is what persists.
4. **Relational vs JSON:** if the DB ever queries/filters/sorts by a field → real column. If it's only ever loaded whole → the generic `ModuleData` JSON table. Promote JSON→indexed generated column when you start querying it.

### Adding a module

1. Tables in `features/<m>/data/` (or reuse `ModuleData` for loose data) → additive Drift migration (bump `schemaVersion`, add `createTable` in `onUpgrade`).
2. DAO (`@DriftAccessor`) + repository implementing a new `core/contracts/<m>_api.dart`.
3. Providers in `core/providers.dart`. Run `build_runner`.
4. Screen as a `ConsumerWidget` whose `Scaffold` carries `drawer: const AppDrawer()`; add an `AppModule` enum case in `core/app_module.dart` (label/icon/screen) — the shell's IndexedStack and the drawer pick it up automatically.
5. Brief card (optional) reads its summary through the new `XApi`; an in-progress activity surfaces a Resume affordance (ADR-0001).

## Conventions

- Feature-first folders; `core/` holds only cross-cutting infrastructure.
- Screens are `ConsumerWidget`/`ConsumerStatefulWidget`; read state via `ref.watch`, fire actions via `ref.read(repoProvider).method()`.
- Theme is seeded from one color in `core/theme.dart` — don't hardcode colors in widgets.
- **Riverpod version note:** no `AsyncValue.valueOrNull` here — use `.asData?.value`.
- Foreign keys: enabled via `PRAGMA foreign_keys = ON` in `AppDb.migration.beforeOpen`. Use `onDelete: KeyAction.cascade` on child tables.

## Module status

- **Lists** — built, persists across cold start (relational `TrackedLists`/`ListItems`).
- **Workouts** — stub. Next up; richest schema (`workout → exercises → sets/reps/weight`). The Strong-app replacement.
- **Clock** (formerly "Timers") — stub. Module = Clock; the countdown **Timer** is one tool inside it (with Alarms + Stopwatch). When built: store `endsAt`/`startedAt` **timestamps**, not ticking state; schedule OS notifications (`flutter_local_notifications`) for alarms that must fire while the app is dead.

## Future / deferred

- **Sync** (same data across devices): not built. Drift stays local-first; layer PowerSync or Supabase on top when needed — no data-layer rewrite.
- **iOS:** code is already cross-platform; only the *build* needs a Mac (cloud Mac or CI).
