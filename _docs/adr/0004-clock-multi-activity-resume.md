---
status: accepted
date: 2026-06-16
deciders: Development
---

# Clock surfaces several in-progress activities as counts with fixed tool precedence

ADR-0001 established drawer-hub navigation in which a module "opens into its
In-progress activity if one exists, and the Brief shows a Resume banner" —
assuming **at most one** in-progress activity per module. Clock breaks that
assumption cleanly: a running **Stopwatch** and several running **Timers** can be
live at the same time. So the Brief represents Clock as **three counts** (alarms
today · running timers · stopwatch running) rather than a single Resume banner,
and tapping the card opens Clock to a tool tab chosen by a **fixed precedence —
Stopwatch > Timer > Alarm** (Alarms when nothing is live). This **amends**
ADR-0001's single-activity model.

## Decision Drivers

- Clock genuinely holds multiple concurrent In-progress activities; one banner
  can't represent N of them.
- **Alarms are scheduled future state, not in-progress work** — they are a summary
  line, never a Resume target. A *ringing* alarm is handled by the full-screen
  intent (ADR-0003), not the Brief.
- Precedence by "what are you most likely to need to act on?": the **Stopwatch**
  is open-ended (counts up until stopped → most likely forgotten), Timers
  self-terminate, Alarms are future.

## Considered Options

- **Single most-salient banner** (e.g. soonest-ending activity) — loses the others
  and is awkward when both the stopwatch and timers run.
- **Counts + fixed tool precedence (chosen)** — the card states all three counts;
  precedence picks the tab on tap.
- **One banner per running activity** — clutters the Brief as concurrency grows.

## Consequences

- The glossary relaxes: a **Module** may own **several** In-progress activities; the
  Brief summarizes them (see `_docs/CONTEXT.md`).
- `ClockApi` exposes counts (`watchTodaysAlarmCount` / `watchRunningTimerCount` /
  `watchStopwatchRunning`), not a single active-countdown.
- The active Clock **tab** is derived from live domain state on entry-via-card
  (the Clock-internal echo of ADR-0001's "landing is derived from data"); a
  manual tab choice still persists within a session via the kept-alive
  `IndexedStack`.
- A future module with concurrent live activities can follow this same pattern.

## Links
- Amends: ADR-0001 (single-activity Resume model)
- Related: ADR-0003 (the scheduling/notification mechanism behind the live activities)
