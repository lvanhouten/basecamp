// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clock_dao.dart';

// ignore_for_file: type=lint
mixin _$ClockDaoMixin on DatabaseAccessor<AppDb> {
  $TimersTable get timers => attachedDatabase.timers;
  $ModuleDataTable get moduleData => attachedDatabase.moduleData;
  ClockDaoManager get managers => ClockDaoManager(this);
}

class ClockDaoManager {
  final _$ClockDaoMixin _db;
  ClockDaoManager(this._db);
  $$TimersTableTableManager get timers =>
      $$TimersTableTableManager(_db.attachedDatabase, _db.timers);
  $$ModuleDataTableTableManager get moduleData =>
      $$ModuleDataTableTableManager(_db.attachedDatabase, _db.moduleData);
}
