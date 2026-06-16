import 'package:basecamp/core/db/app_db.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

/// Builds a v2-shaped database (Lists with pin/position, but NO `timers` table)
/// in the given sqlite3 connection and stamps `user_version = 2` so drift runs
/// the v2 -> v3 upgrade (which creates `timers`) when it opens over the same
/// connection. Mirrors `test/lists/migration_v1_to_v2_test.dart`.
void _seedV2(Database raw) {
  raw.execute('''
    CREATE TABLE tracked_lists (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      created_at INTEGER NOT NULL,
      pinned INTEGER NOT NULL DEFAULT 0,
      position INTEGER NOT NULL DEFAULT 0
    );
  ''');
  raw.execute('''
    CREATE TABLE list_items (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      list_id INTEGER NOT NULL REFERENCES tracked_lists (id) ON DELETE CASCADE,
      label TEXT NOT NULL,
      done INTEGER NOT NULL DEFAULT 0,
      created_at INTEGER NOT NULL,
      position INTEGER NOT NULL DEFAULT 0
    );
  ''');
  raw.execute('''
    CREATE TABLE module_data (
      module_id TEXT NOT NULL,
      entry_key TEXT NOT NULL,
      payload TEXT NOT NULL,
      PRIMARY KEY (module_id, entry_key)
    );
  ''');
  raw.execute('PRAGMA user_version = 2;');
}

void main() {
  test(
      'upgrading a v2 DB creates the timers table additively and preserves '
      'existing Lists data', () async {
    final raw = sqlite3.openInMemory();
    _seedV2(raw);

    // Seed pre-existing Lists data that must survive the upgrade untouched.
    raw.execute(
        "INSERT INTO tracked_lists (id, name, created_at, pinned, position) "
        "VALUES (1, 'Groceries', 1000, 1, 0)");
    raw.execute(
        "INSERT INTO tracked_lists (id, name, created_at, pinned, position) "
        "VALUES (2, 'Movies', 2000, 0, 3)");
    raw.execute(
        "INSERT INTO list_items (id, list_id, label, done, created_at, position) "
        "VALUES (10, 1, 'Milk', 0, 100, 0)");
    raw.execute(
        "INSERT INTO list_items (id, list_id, label, done, created_at, position) "
        "VALUES (11, 1, 'Eggs', 1, 200, 1)");

    // Before the upgrade there is no timers table.
    final preTables = raw
        .select("SELECT name FROM sqlite_master WHERE type='table'")
        .map((r) => r['name'] as String)
        .toSet();
    expect(preTables, isNot(contains('timers')));

    // Hand the connection to drift, which runs onUpgrade(2 -> 3).
    final db = AppDb.forTesting(NativeDatabase.opened(raw));
    addTearDown(db.close);

    // Force the migration by opening + touching the schema.
    final timersAfter = await db.select(db.timers).get();

    // --- timers table now exists and is empty ---------------------------
    expect(timersAfter, isEmpty,
        reason: 'a fresh additive table starts with no rows');

    final postTables = raw
        .select("SELECT name FROM sqlite_master WHERE type='table'")
        .map((r) => r['name'] as String)
        .toSet();
    expect(postTables, contains('timers'));

    // --- existing Lists data preserved verbatim -------------------------
    final lists = await db.select(db.trackedLists).get();
    expect(lists.map((l) => l.id).toSet(), {1, 2});
    final groceries = lists.firstWhere((l) => l.id == 1);
    expect(groceries.name, 'Groceries');
    expect(groceries.pinned, isTrue);
    expect(groceries.position, 0);
    final movies = lists.firstWhere((l) => l.id == 2);
    expect(movies.position, 3);

    final items = await db.select(db.listItems).get();
    expect(items.map((i) => i.id).toSet(), {10, 11});
    expect(items.firstWhere((i) => i.id == 11).done, isTrue);

    // --- the new table is usable post-migration -------------------------
    final id = await db.clockDao.insertRunningTimer(
      label: 'Tea',
      durationMs: 300000,
      endsAt: DateTime.utc(2026, 6, 16, 12, 5),
    );
    expect((await db.clockDao.findTimer(id))!.label, 'Tea');
  });
}
