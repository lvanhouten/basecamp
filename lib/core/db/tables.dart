import 'package:drift/drift.dart';

import 'converters.dart';

/// A user-created collection (Groceries, Movies to watch, …).
///
/// `pinned` and `position` are real, sortable columns (schema v2): lists emit
/// `pinned DESC, position ASC` — pinned lists float to the top, manual drag
/// order applies *within* each group. See ADR-0002: same `position` mechanism
/// as items, but pin is the primary sort key instead of `done`.
class TrackedLists extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();
  // Manual order within the pinned/unpinned group. createList assigns this on
  // insert (places a new list at the top of the unpinned block); the v2
  // migration backfills it from createdAt rank. Default 0 is only a schema
  // fallback — every insert path sets it explicitly.
  IntColumn get position => integer().withDefault(const Constant(0))();
}

/// A row inside a [TrackedLists]. `done` and `listId` are real columns because
/// the app queries them (the brief counts `done = false`; the detail filters by list).
///
/// `position` is a real, sortable column (schema v2): items emit
/// `done ASC, position ASC` — checked items still sink, manual drag order is
/// honoured *within* each done-group (ADR-0002).
class ListItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get listId =>
      integer().references(TrackedLists, #id, onDelete: KeyAction.cascade)();
  TextColumn get label => text()();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  // Manual order within the item's done-group. addItem assigns this on insert
  // (appends to the bottom of its list); the v2 migration backfills it from
  // per-list createdAt rank. Default 0 is only a schema fallback.
  IntColumn get position => integer().withDefault(const Constant(0))();
}

/// An **ephemeral** countdown Timer (Clock module, schema v3). Multiple run at
/// once. We persist *timestamps*, not ticking state (see ADR-0004 / the Clock
/// README): a killed process can't keep counting, so remaining is always
/// recomputed from `endsAt` via `clock_math.countdownRemaining`.
///
/// State is derived purely from the two nullable time fields — never a separate
/// status column (which could drift out of sync with the timestamps):
///   - **running**  → `endsAt` set, `remainingMs` null.
///   - **paused**   → `endsAt` null, `remainingMs` set (captured at the pause
///                    transition via `clock_math.pausedRemaining`).
///   - **finished** → `endsAt` set but in the past (`endsAt <= now`). The row
///                    stays until the user dismisses it (then it's deleted).
///
/// `durationMs` is the originally-configured length, retained so the UI can show
/// "5:00 timer" and for a future reusable-timer library (Clock README → Future
/// Enhancements). These are first-iteration ephemeral timers, so there is no
/// idle state / `position` column yet — those land additively if/when reusable
/// timers ship.
///
/// NOTE: the generated row class is named [TimerRow] (via `@DataClassName`), NOT
/// `Timer` — Drift would otherwise singularize `Timers` to `Timer`, which
/// collides with `dart:async.Timer` (the in-app countdown ticker the TimerPane
/// will use). Downstream briefs: the data class is `TimerRow`.
@DataClassName('TimerRow')
class Timers extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Optional user label ("Tea", "Pasta"). Null = an unlabeled timer.
  TextColumn get label => text().nullable()();

  /// The configured countdown length in milliseconds. Set once at creation.
  IntColumn get durationMs => integer()();

  /// Absolute completion time. Set **only while running** (and on a finished
  /// timer it points to the past); null while paused. The running list orders
  /// by this ascending (soonest first).
  DateTimeColumn get endsAt => dateTime().nullable()();

  /// Remaining milliseconds captured at the **pause** transition. Set **only
  /// while paused**; null while running. On resume `endsAt = now + remainingMs`
  /// and this is cleared.
  IntColumn get remainingMs => integer().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// A persisted **Alarm** (Clock module, schema v4). Unlike a Timer (an
/// ephemeral countdown), an Alarm is a standing wall-clock schedule: it fires
/// at a time-of-day, optionally on a recurring weekday set, until the user
/// disables it. We persist only the *schedule* (a time-of-day + weekday mask),
/// not any ticking/ringing state — the OS holds the scheduled notification
/// (ADR-0003), and the exact fire instant is derived from these fields via the
/// pure `alarm_recurrence` math (brief 06). State that survives cold start is
/// the row; the ring itself is transient OS state.
///
///   - **one-off**   → `repeatDays == 0`: fires once, at the next occurrence of
///                     `timeOfDayMinutes`. `dismiss` flips `enabled = false`.
///   - **recurring** → `repeatDays != 0`: fires on every selected weekday at
///                     `timeOfDayMinutes`, forever. `dismiss` leaves it enabled.
///
/// `repeatDays` uses the FIXED 7-bit weekday convention from
/// `alarm_recurrence.dart` (bit 0 = Monday … bit 6 = Sunday, `1 << (weekday-1)`).
/// Use `weekdayBit` / `maskHasWeekday` rather than re-deriving the shift.
///
/// The generated row class is [AlarmRow] (via `@DataClassName`), mirroring
/// [TimerRow] — `AlarmRow`, not `Alarm`, so downstream code reads consistently
/// and there's no confusion with a domain "Alarm" concept.
@DataClassName('AlarmRow')
class Alarms extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Time-of-day in minutes since local midnight, `[0, 1440)`. The alarm fires
  /// at this wall-clock time on each due day.
  IntColumn get timeOfDayMinutes => integer()();

  /// The true on/off. A disabled alarm has no scheduled OS notification; it
  /// persists so the user can re-enable it (which reschedules). The Brief's
  /// today-due count only includes enabled alarms.
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();

  /// 7-bit weekday mask (bit 0 = Monday … bit 6 = Sunday). `0` = one-off; any
  /// non-zero subset = recurring. See `alarm_recurrence.dart`.
  IntColumn get repeatDays => integer().withDefault(const Constant(0))();

  /// Optional user label ("Wake up", "Meds"). Null = unlabeled.
  TextColumn get label => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// The generic JSON lane. Any future module can persist here with no migration:
/// (moduleId, entryKey) identifies a record; `payload` is an opaque document.
class ModuleData extends Table {
  TextColumn get moduleId => text()();
  TextColumn get entryKey => text()();
  TextColumn get payload => text().map(const JsonConverter())();

  @override
  Set<Column> get primaryKey => {moduleId, entryKey};
}
