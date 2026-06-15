import 'package:drift/drift.dart';

import 'converters.dart';

/// A user-created collection (Groceries, Movies to watch, …).
class TrackedLists extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// A row inside a [TrackedLists]. `done` and `listId` are real columns because
/// the app queries them (the brief counts `done = false`; the detail filters by list).
class ListItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get listId =>
      integer().references(TrackedLists, #id, onDelete: KeyAction.cascade)();
  TextColumn get label => text()();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
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
