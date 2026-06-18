import 'package:drift/drift.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'db/app_db.dart';
import 'providers.dart' show dbProvider;

/// App settings persistence (01-theming-foundation).
///
/// Settings live in the existing generic [ModuleData] JSON lane — no new table,
/// no migration. The whole settings document is ONE record addressed by a fixed
/// (moduleId, entryKey) = ([settingsModuleId], [settingsEntryKey]); the
/// `payload` map is the persisted truth. Drift is the source of truth, so the
/// chosen theme mode survives cold start for free (CLAUDE.md hard rule 2).
const settingsModuleId = 'settings';
const settingsEntryKey = 'app';

/// Payload key for the persisted theme mode.
const _themeModeKey = 'themeMode';

/// Reads/writes the single settings record through [AppDb]'s generic JSON lane.
/// Pure persistence; no Drift schema change. Lives here (not in a module DAO)
/// because settings are cross-cutting, not owned by any module.
class SettingsStore {
  SettingsStore(this._db);

  final AppDb _db;

  /// Loads the settings payload, or an empty map on a fresh install (no record
  /// yet). `getSingleOrNull` because nothing is written until the first change.
  Future<Map<String, dynamic>> _read() async {
    final row = await (_db.select(_db.moduleData)
          ..where((r) =>
              r.moduleId.equals(settingsModuleId) &
              r.entryKey.equals(settingsEntryKey)))
        .getSingleOrNull();
    return row?.payload ?? <String, dynamic>{};
  }

  /// Upserts the settings record, merging [changes] over the existing payload.
  /// The (moduleId, entryKey) primary key makes this idempotent — there is
  /// always exactly one settings row.
  Future<void> _merge(Map<String, dynamic> changes) async {
    final next = <String, dynamic>{...await _read(), ...changes};
    await _db.into(_db.moduleData).insertOnConflictUpdate(
          ModuleDataCompanion.insert(
            moduleId: settingsModuleId,
            entryKey: settingsEntryKey,
            payload: next,
          ),
        );
  }

  /// The persisted theme mode, defaulting to [ThemeMode.system] on a fresh
  /// install or any unrecognized stored value.
  Future<ThemeMode> readThemeMode() async {
    final stored = (await _read())[_themeModeKey] as String?;
    return _decode(stored);
  }

  /// Persists [mode] as the chosen theme mode.
  Future<void> writeThemeMode(ThemeMode mode) =>
      _merge({_themeModeKey: mode.name});

  static ThemeMode _decode(String? name) {
    switch (name) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}

final settingsStoreProvider = Provider<SettingsStore>(
  (ref) => SettingsStore(ref.watch(dbProvider)),
);

/// The current theme mode (light / dark / system), user-selectable and
/// persisted. The root applies `themeMode: ref.watch(themeModeProvider)`; the
/// Profile screen (07) calls [ThemeModeController.set]. Defaults to
/// [ThemeMode.system] until the persisted value loads, then hydrates from Drift
/// — so the user's choice survives cold start (the persistence test pins this).
class ThemeModeController extends Notifier<ThemeMode> {
  /// True once the user has explicitly chosen a mode. Guards [_hydrate] from
  /// clobbering a [set] that races the initial async load (a user can toggle
  /// before the persisted read resolves).
  bool _userChose = false;

  @override
  ThemeMode build() {
    _userChose = false;
    // Hydrate from the persisted record; until it resolves we render `system`.
    _hydrate();
    return ThemeMode.system;
  }

  Future<void> _hydrate() async {
    final stored = await ref.read(settingsStoreProvider).readThemeMode();
    // Don't overwrite a choice the user made while the load was in flight.
    if (!_userChose) state = stored;
  }

  /// Sets and persists the chosen [mode]. Optimistically updates the provider
  /// so the UI flips immediately; the write is the durable copy.
  Future<void> set(ThemeMode mode) async {
    _userChose = true;
    state = mode;
    await ref.read(settingsStoreProvider).writeThemeMode(mode);
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);
