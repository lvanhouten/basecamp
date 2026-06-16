## Agent Brief

**Category:** enhancement
**Summary:** A pure, Flutter-free alarm-recurrence module — next-occurrence and rings-today over a time-of-day plus a 7-bit weekday mask.

**Current behavior:**
Nothing computes when an alarm should next fire. Alarms are not built, and there is no representation of one-off versus day-of-week recurrence. Without this, the Alarms data layer (later brief) would embed scheduling math in the DAO/repository where it can't be tested in isolation.

**Desired behavior:**
A pure module computes alarm scheduling from a **time-of-day** (minutes since midnight) and a **7-bit weekday mask**, given an injected `from`/`now` (no internal wall-clock read):

- **nextOccurrence** — the next `DateTime` the alarm should fire. Recurring (mask has ≥1 weekday bit): the soonest future selected weekday at the time-of-day (today if today's bit is set and the time is still ahead; otherwise the next set weekday, wrapping across the week end). One-off (mask == 0): the next occurrence of that time-of-day (today if still ahead, else tomorrow).
- **ringsToday** — whether the alarm is due on a given date. Recurring: today's weekday bit is set. One-off: the time-of-day is still ahead on that date.
- **per-weekday schedule** — for a recurring alarm, the set of (weekday, time-of-day) pairs the scheduler will register one OS notification for each.

The weekday bit convention is fixed and documented in the module (e.g. bit 0 = Monday … bit 6 = Sunday) and used consistently. Edge handling: exactly-now, midnight boundary, all-seven (daily), and week-wraparound.

**Key interfaces:**

- `nextOccurrence(timeOfDayMinutes, repeatDaysMask, from) → DateTime` — pure.
- `ringsToday(timeOfDayMinutes, repeatDaysMask, date) → bool` — pure.
- A helper enumerating the (weekday, time-of-day) pairs a recurring alarm schedules.
- The module imports neither Flutter nor Drift and documents the weekday bit convention.

**Acceptance criteria:**

- [ ] One-off (mask 0): `nextOccurrence` is today at the time-of-day when still ahead, else tomorrow.
- [ ] Recurring: `nextOccurrence` is today when today's bit is set and the time is still ahead.
- [ ] Recurring: when today is past or not set, `nextOccurrence` is the next set weekday at the time-of-day, wrapping across the week end.
- [ ] Daily (all 7 bits) always yields the next occurrence within 24h.
- [ ] `ringsToday` is true for a recurring alarm whose today bit is set and for a one-off still ahead today; false otherwise.
- [ ] The per-weekday schedule helper yields exactly one pair per set bit at the correct time-of-day.
- [ ] Boundary cases (exactly now, midnight, week-wraparound) are covered by unit tests; all functions are pure (no wall-clock read).
- [ ] The module imports neither Flutter nor Drift.

**Out of scope:**

- Alarm persistence, scheduling, repository, and UI — see `07-alarm-data.md`, `08-alarm-ui.md`.
- Clock elapsed/remaining math — see `01-clock-math.md`.

**Depends on:** none

**Runtime:** parallel-safe
