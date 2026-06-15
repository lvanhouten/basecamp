import 'package:basecamp/core/db/app_db.dart';
import 'package:basecamp/features/lists/data/lists_dao.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

/// Builds a v1-shaped database (schema before pin/position existed) in the
/// given sqlite3 connection and stamps `user_version = 1` so drift runs the
/// v1 -> v2 upgrade when it opens over the same connection.
void _seedV1(Database raw) {
  raw.execute('''
    CREATE TABLE tracked_lists (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      created_at INTEGER NOT NULL
    );
  ''');
  raw.execute('''
    CREATE TABLE list_items (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      list_id INTEGER NOT NULL REFERENCES tracked_lists (id) ON DELETE CASCADE,
      label TEXT NOT NULL,
      done INTEGER NOT NULL DEFAULT 0,
      created_at INTEGER NOT NULL
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
  raw.execute('PRAGMA user_version = 1;');
}

void main() {
  test(
      'upgrading a v1 DB backfills dense per-list position and preserves '
      'emitted order', () async {
    final raw = sqlite3.openInMemory();
    _seedV1(raw);

    // Seed two lists in createdAt order; items per list in createdAt order with
    // mixed done states. Use explicit createdAt (epoch ms) to pin the ranking.
    raw.execute(
        "INSERT INTO tracked_lists (id, name, created_at) VALUES (1, 'Groceries', 1000)");
    raw.execute(
        "INSERT INTO tracked_lists (id, name, created_at) VALUES (2, 'Movies', 2000)");

    // Groceries: Milk(done), Eggs, Bread  (Milk inserted first, then Eggs, Bread)
    raw.execute(
        "INSERT INTO list_items (id, list_id, label, done, created_at) VALUES (10, 1, 'Milk', 1, 100)");
    raw.execute(
        "INSERT INTO list_items (id, list_id, label, done, created_at) VALUES (11, 1, 'Eggs', 0, 200)");
    raw.execute(
        "INSERT INTO list_items (id, list_id, label, done, created_at) VALUES (12, 1, 'Bread', 0, 300)");
    // Movies: Dune, Arrival(done)
    raw.execute(
        "INSERT INTO list_items (id, list_id, label, done, created_at) VALUES (20, 2, 'Dune', 0, 150)");
    raw.execute(
        "INSERT INTO list_items (id, list_id, label, done, created_at) VALUES (21, 2, 'Arrival', 1, 250)");

    // Capture the v1 emitted order with the OLD query semantics:
    //   lists: created_at ASC
    //   items: done ASC, created_at ASC
    final v1ListsIds = raw
        .select('SELECT id FROM tracked_lists ORDER BY created_at')
        .map((r) => r['id'] as int)
        .toList();
    List<int> v1ItemsIds(int listId) => raw
        .select(
            'SELECT id FROM list_items WHERE list_id = ? ORDER BY done, created_at',
            [listId])
        .map((r) => r['id'] as int)
        .toList();
    final v1Groceries = v1ItemsIds(1);
    final v1Movies = v1ItemsIds(2);

    // Now hand the connection to drift, which runs onUpgrade(1 -> 2).
    final db = AppDb.forTesting(NativeDatabase.opened(raw));
    addTearDown(db.close);
    final dao = db.listsDao;

    // Force the migration to run (opens the DB).
    final lists = await dao.watchLists().first;

    // --- Emitted order unchanged vs v1 ---------------------------------
    expect(lists.map((r) => r.list.id).toList(), v1ListsIds,
        reason: 'list emitted order must match v1 (createdAt)');

    final groceries = await dao.watchItems(1).first;
    final movies = await dao.watchItems(2).first;
    expect(groceries.map((i) => i.id).toList(), v1Groceries,
        reason: 'item emitted order must match v1 (done then createdAt)');
    expect(movies.map((i) => i.id).toList(), v1Movies);

    // --- position is dense + per-list contiguous -----------------------
    // Lists ranked globally by createdAt -> 0,1.
    final listPos = {for (final r in lists) r.list.id: r.list.position};
    expect(listPos, {1: 0, 2: 1});

    // Items ranked by createdAt WITHIN each list -> 0..n per list.
    final allItems = await db.select(db.listItems).get();
    final posByList = <int, List<int>>{};
    for (final i in allItems) {
      (posByList[i.listId] ??= []).add(i.position);
    }
    for (final entry in posByList.entries) {
      final sorted = [...entry.value]..sort();
      expect(sorted, List.generate(entry.value.length, (i) => i),
          reason: 'list ${entry.key} positions must be dense 0..n');
    }

    // Specifically: Groceries by createdAt is Milk(100),Eggs(200),Bread(300)
    // -> positions 0,1,2 regardless of done.
    final groceryPos = {
      for (final i in allItems.where((i) => i.listId == 1)) i.label: i.position
    };
    expect(groceryPos, {'Milk': 0, 'Eggs': 1, 'Bread': 2});
  });
}
