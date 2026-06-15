import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../features/lists/data/lists_dao.dart';
import 'converters.dart';
import 'tables.dart';

part 'app_db.g.dart';

/// The single Basecamp database. Tables are registered here, but the *queries*
/// for each module live in that module's DAO (see [daos]) — so adding a module
/// is "register its tables + DAO", not "edit a shared query file".
@DriftDatabase(tables: [TrackedLists, ListItems, ModuleData], daos: [ListsDao])
class AppDb extends _$AppDb {
  AppDb() : super(driftDatabase(name: 'basecamp'));

  /// For unit tests: pass an in-memory executor.
  AppDb.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        // New module later == an additive step here, e.g.:
        //   if (from < 2) await m.createTable(moodEntries);
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
