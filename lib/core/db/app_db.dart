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
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // v1 -> v2: pin + manual order for Lists (ADR-0002). Additive only.
          if (from < 2) {
            await m.addColumn(trackedLists, trackedLists.pinned);
            await m.addColumn(trackedLists, trackedLists.position);
            await m.addColumn(listItems, listItems.position);
            // Backfill `position` so v1 data's *emitted* order is unchanged.
            // v1 lists emitted in createdAt order; v1 items emitted
            // done-then-createdAt. position only orders WITHIN a done-group,
            // so ranking items by createdAt per list reproduces v1 exactly.
            // Dense 0..n via ROW_NUMBER() - 1 (id breaks createdAt ties, which
            // matches autoincrement = insertion order).
            await customStatement('''
              UPDATE tracked_lists
              SET position = (
                SELECT rn - 1 FROM (
                  SELECT id AS rid,
                         ROW_NUMBER() OVER (ORDER BY created_at, id) AS rn
                  FROM tracked_lists
                ) WHERE rid = tracked_lists.id
              )
            ''');
            await customStatement('''
              UPDATE list_items
              SET position = (
                SELECT rn - 1 FROM (
                  SELECT id AS rid,
                         ROW_NUMBER() OVER (
                           PARTITION BY list_id ORDER BY created_at, id
                         ) AS rn
                  FROM list_items
                ) WHERE rid = list_items.id
              )
            ''');
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
