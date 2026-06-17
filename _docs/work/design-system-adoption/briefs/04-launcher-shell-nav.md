## Agent Brief

**Category:** enhancement
**Summary:** Replace the drawer + IndexedStack hub with the launcher shell (ADR-0005): a fixed bottom bar of Brief / Calendar / ⊕ / Activity / Modules, with modules opened as pushed views that land on their in-progress activity from persisted state.

**Current behavior:**
The hub keeps every module alive as `IndexedStack` peers and shows the one selected via a hub-level selection notifier, written by a navigation **drawer** mounted on every module root. The `AppModule` enum (brief / lists / workouts / clock) drives both the drawer destinations and the IndexedStack. Android back returns to the Brief from any module. (ADR-0001.)

**Desired behavior:**
The app uses the launcher navigation model (ADR-0005, which supersedes ADR-0001):

- A **launcher shell** hosts four fixed bottom-bar destinations — **Brief**, **Calendar**, **Activity**, **Modules** — split 2/2 around a raised center **⊕ Quick add** FAB (using the `03` launcher TabBar). The four bar destinations may remain a lightweight `IndexedStack` body (they are persistent, cheap tabs); ADR-0005 retires keeping the heavy **module** screens alive as peers, not the four-tab body.
- The **⊕ FAB is a no-op / "coming soon"** in this feature (a toast or nothing). Quick-capture is deferred.
- **Modules (Lists, Workouts, Clock, and the new stub modules Goals & Journal) are pushed views.** They are launched from the Modules grid (and any Brief affordance) via the navigator and return via a back arrow — they are not bar destinations and are not kept alive.
- **Domain-state landing must not regress:** when a module is entered, it lands on its in-progress activity derived from persisted Drift state — e.g. Clock opens to the precedence-selected tool (Stopwatch > Timer > Alarms) using the existing entry-precedence logic; with nothing in progress it lands on the resting default. This preserves ADR-0004 multi-activity resume.
- The **`AppModule` enum no longer drives the bar.** It enumerates the **modules** shown in the Modules grid and is the push target type; the four bar destinations are a separate fixed set. The Brief is no longer an `AppModule` member of the module list (it is a bar destination). Add `goals` and `journal` cases (icons: book for Journal, target for Goals).
- The **drawer is removed.** `AppDrawer` is deleted and every module screen drops its `drawer:` reference and its hub AppBar in favor of being a pushed route (a back arrow appears automatically). The app must compile and run with no drawer anywhere.
- The full-screen **alarm launch host** (which pushes the alarm ring screen onto the root navigator when a full-screen alarm intent opens the app) continues to work above the new shell.
- To keep the shell compiling independently, this brief provides **minimal placeholder screens** for all four bar destinations (Brief / Calendar / Activity / Modules). Later briefs replace each placeholder with its real content.

**Key interfaces:**

- The launcher shell widget — replaces the current hub shell; a `Scaffold` whose `bottomNavigationBar` is the `03` launcher TabBar and whose body holds the four destinations; owns the ⊕ no-op action and module push routing.
- `AppModule` enum — refactored: members are the grid modules (lists, workouts, clock, goals, journal), each with label/icon/screen; no longer enumerates bar destinations; brief is removed from it.
- Module-entry landing — the existing entry-precedence logic (e.g. the clock tool precedence) is invoked when a module is pushed, not when an IndexedStack index changes; the clock selected-tool notifier is preserved (its doc note about "kept alive in the IndexedStack" is corrected to "computed on module entry").
- The hub selection notifier — repurposed or retired; navigation state must keep landing derived from Drift, not from a remembered route.
- Bottom-bar destination set — a fixed list (Brief / Calendar / ⊕ / Activity / Modules) independent of `AppModule`.

**Acceptance criteria:**

- [ ] The app launches into the launcher shell with the four-destination bar + center FAB; there is no navigation drawer anywhere and `AppDrawer` is gone.
- [ ] Tapping a Modules-grid tile pushes that module's screen over the shell; the back arrow returns to the shell. (Tested.)
- [ ] **Domain-state landing:** with Drift seeded so a module has an in-progress activity (e.g. a running timer or running stopwatch), entering Clock lands on the precedence-selected tool; with nothing in progress it lands on the resting default. (Tested.)
- [ ] Switching among the four bar destinations works without unmounting them; the ⊕ FAB invokes its (no-op/coming-soon) action and is never rendered as a selected destination. (Tested.)
- [ ] `AppModule` includes `goals` and `journal`; the enum drives the Modules grid / push target, not the bar.
- [ ] The alarm full-screen launch path still routes to the ring screen above the new shell.
- [ ] Minimal placeholder screens exist for Brief / Calendar / Activity / Modules so the shell compiles before the content briefs run.
- [ ] `flutter analyze` clean; `flutter test` passes (including the new navigation tests).

**Out of scope:**

- The real Brief digest content — see `05-brief-screen` (replaces the Brief placeholder).
- The real Modules grid content — see `06-modules-screen` (replaces the Modules placeholder).
- Final Calendar/Activity/Profile/Goals/Journal screen content — see `07-stub-and-profile-screens`.
- Visual restyle of the module screens' bodies — see `08-reskin-lists`, `09-reskin-clock`, `10-reskin-workouts` (this brief only removes their drawer/hub-chrome so they work as pushed routes; it does not restyle their content).
- The ⊕ quick-capture sheet functionality (deferred entirely).

**Depends on:** 01-theming-foundation (theme), 03-launcher-tabbar (the bar widget)

**Runtime:** parallel-safe

**Design references:** `_docs/adr/0005-launcher-bottom-bar-navigation.md`, `_docs/adr/0004-clock-multi-activity-resume.md` (resume precedence), `_docs/CONTEXT.md` (Brief / Modules / Calendar / Activity / Quick add / Module terms), and `_docs/design-system/project/ui_kits/basecamp-app/index.html` (shell + 4-item NAV + push-on-tile-tap + back wiring).
