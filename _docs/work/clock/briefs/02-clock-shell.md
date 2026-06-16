## Agent Brief

**Category:** enhancement
**Summary:** The Clock module shell — tab host with state-derived entry tab, the `ClockApi` count contract, a `ClockRepository` skeleton, providers, the Brief card wiring, and the lifecycle hook. Stub panes remain for the tools.

**Current behavior:**
`ClockScreen` is a stub `StatelessWidget` with a `DefaultTabController` and three placeholder tabs (Alarms / Timer / Stopwatch) showing static text. There is no `ClockApi`, no `ClockRepository`, and no Clock providers. The Brief's Clock card shows a hardcoded "No alarms set for today" line and taps through to the Clock module. No module summarizes its live state to the Brief via counts.

**Desired behavior:**
- `ClockScreen` becomes a `ConsumerWidget` hosting three tool tabs and carrying the hub navigation drawer (the established module-screen shape). The resting default landing tab is **Alarms**.
- A **pure tab-precedence function** chooses the entry tab from live counts: a running Stopwatch wins, else a running Timer, else Alarms (ADR-0004's Stopwatch > Timer > Alarm; Alarms is also the default when nothing is live). Tapping the Brief's Clock card opens Clock to that tab. A manual tab switch persists within a session (the module is kept alive in the hub `IndexedStack`).
- A `ClockApi` contract exposes three reactive count streams: today's due-and-enabled alarm count, running-timer count, and whether the stopwatch is running. `ClockRepository` implements `ClockApi`. In this brief all three return safe placeholders (0 / 0 / false) that emit without error — later briefs make each real against its persistence.
- Providers expose the repository and the narrow `ClockApi` view (mirroring the lists repository/api provider split), plus read-model providers for the three counts and the Clock module's selected-tab state.
- The Brief's Clock card reads the three counts and renders them as a precise phrase (e.g. "2 alarms today · 1 timer running · stopwatch running"), each segment phrased for what it is — **no uniform "Active N" label** ("Enabled" is the alarm term; "active" is avoided per the glossary). The all-placeholder state reads naturally (no "Active 0"). Tapping the card selects the Clock module and sets the entry tab via the precedence function.
- An `AppLifecycleListener` (or equivalent) hook exists at the Clock module level for resume-time recompute; with no tool state yet it is a no-op scaffold the later panes hang behavior on.
- The three tabs render placeholder panes, replaced by later briefs.

**Key interfaces:**

- `ClockApi` — abstract interface: `watchTodaysAlarmCount(): Stream<int>`, `watchRunningTimerCount(): Stream<int>`, `watchStopwatchRunning(): Stream<bool>`. Mirrors `ListsApi`'s narrow-contract role.
- `ClockRepository implements ClockApi` — placeholder stream implementations here; later briefs fill them in.
- A pure tab-precedence function: given (`stopwatchRunning`, `runningTimerCount`, `todaysAlarmCount`) → which Clock tab to open. Separately unit-tested.
- Providers: a clock repository provider, a narrow `clockApiProvider` view, `StreamProvider`s for the three counts, and a provider holding the Clock module's selected/entry tab that the Brief card writes and `ClockScreen` reads.
- The Brief (home) Clock card — reads the three counts via `ClockApi`; tap sets module + entry tab.

**Acceptance criteria:**

- [ ] `ClockScreen` is a `ConsumerWidget` with three tabs and the hub drawer; the default landing tab is Alarms.
- [ ] The tab-precedence function returns Stopwatch when the stopwatch is running; Timer when not but ≥1 timer runs; Alarms otherwise (including nothing live). Covered by unit tests for all four cases.
- [ ] `ClockApi` exposes the three count streams; `ClockRepository` implements it with placeholder values (0 / 0 / false) that emit without error.
- [ ] The Brief's Clock card renders the three counts as a precise phrase and updates reactively; the zero/none state reads naturally.
- [ ] Tapping the Brief's Clock card opens the Clock module and lands on the precedence-selected tab (Alarms while everything is placeholder).
- [ ] Switching tabs manually, drawer-hopping away, and returning preserves the chosen tab within a session.
- [ ] No regression to other modules' Brief cards or to the drawer.

**Out of scope:**

- Real persistence/queries behind the counts — stopwatch in `03-stopwatch.md`, timers in `04-timer-data.md`, alarms in `07-alarm-data.md`.
- The actual tool panes (start/lap, live countdowns, alarm list/ring) — see `03`, `05`, `08`.
- Clock elapsed/remaining math and alarm recurrence — see `01-clock-math.md`, `06-alarm-recurrence.md`.

**Depends on:** none

**Runtime:** parallel-safe
