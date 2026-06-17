import 'package:basecamp/core/db/app_db.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

/// Builds a v3-shaped database (Lists v2 + the `timers` table + `module_data`,
/// but NO `alarms` table) in the given sqlite3 connection and stamps
/// `user_version = 3` so drift runs the v3 -> v4 upgrade (which creates
/// `alarms`) when it opens over the same connection. Mirrors
/// `test/clock/migration_v2_to_v3_test.dart`.
void _seedV3(Database raw) {
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
  raw.execute('''
    CREATE TABLE timers (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      label TEXT,
      duration_ms INTEGER NOT NULL,
      ends_at INTEGER,
      remaining_ms INTEGER,
      created_at INTEGER NOT NULL
    );
  ''');
  raw.execute('PRAGMA user_version = 3;');
}

void main() {
  test(
      'upgrading a v3 DB creates the alarms table additively and preserves '
      'existing Lists + Timer data', () async {
    final raw = sqlite3.openInMemory();
    _seedV3(raw);

    // Seed pre-existing data across the prior schema that must survive.
    raw.execute(
        "INSERT INTO tracked_lists (id, name, created_at, pinned, position) "
        "VALUES (1, 'Groceries', 1000, 1, 0)");
    raw.execute(
        "INSERT INTO list_items (id, list_id, label, done, created_at, position) "
        "VALUES (10, 1, 'Milk', 0, 100, 0)");
    raw.execute(
        "INSERT INTO timers (id, label, duration_ms, ends_at, remaining_ms, created_at) "
        "VALUES (5, 'Tea', 300000, 9999999999, NULL, 200)");
    raw.execute(
        "INSERT INTO module_data (module_id, entry_key, payload) "
        "VALUES ('clock', 'stopwatch', '{\"accumulatedMs\":42,\"isRunning\":false}')");

    // Before the upgrade there is no alarms table.
    final preTables = raw
        .select("SELECT name FROM sqlite_master WHERE type='table'")
        .map((r) => r['name'] as String)
        .toSet();
    expect(preTables, isNot(contains('alarms')));

    // Hand the connection to drift, which runs onUpgrade(3 -> 4).
    final db = AppDb.forTesting(NativeDatabase.opened(raw));
    addTearDown(db.close);

    // Force the migration by touching the new table.
    final alarmsAfter = await db.select(db.alarms).get();

    // --- alarms table now exists and is empty --------------------------
    expect(alarmsAfter, isEmpty,
        reason: 'a fresh additive table starts with no rows');
    final postTables = raw
        .select("SELECT name FROM sqlite_master WHERE type='table'")
        .map((r) => r['name'] as String)
        .toSet();
    expect(postTables, contains('alarms'));

    // --- existing data preserved verbatim ------------------------------
    final lists = await db.select(db.trackedLists).get();
    expect(lists.single.name, 'Groceries');
    expect(lists.single.pinned, isTrue);

    final items = await db.select(db.listItems).get();
    expect(items.single.label, 'Milk');

    final timer = await db.clockDao.findTimer(5);
    expect(timer!.label, 'Tea');
    expect(timer.durationMs, 300000);

    final sw = await db.clockDao.watchStopwatch().first;
    expect(sw!['accumulatedMs'], 42);

    // --- the new table is usable post-migration ------------------------
    final id = await db.clockDao.insertAlarm(
      timeOfDayMinutes: 7 * 60,
      repeatDays: 0,
      label: 'Wake up',
    );
    final alarm = await db.clockDao.findAlarm(id);
    expect(alarm!.label, 'Wake up');
    expect(alarm.timeOfDayMinutes, 420);
    expect(alarm.enabled, isTrue, reason: 'enabled column defaults to true');
  });
}
