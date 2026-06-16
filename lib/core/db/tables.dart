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

/// The generic JSON lane. Any future module can persist here with no migration:
/// (moduleId, entryKey) identifies a record; `payload` is an opaque document.
class ModuleData extends Table {
  TextColumn get moduleId => text()();
  TextColumn get entryKey => text()();
  TextColumn get payload => text().map(const JsonConverter())();

  @override
  Set<Column> get primaryKey => {moduleId, entryKey};
}
