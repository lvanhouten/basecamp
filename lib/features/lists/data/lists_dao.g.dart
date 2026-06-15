// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lists_dao.dart';

// ignore_for_file: type=lint
mixin _$ListsDaoMixin on DatabaseAccessor<AppDb> {
  $TrackedListsTable get trackedLists => attachedDatabase.trackedLists;
  $ListItemsTable get listItems => attachedDatabase.listItems;
  ListsDaoManager get managers => ListsDaoManager(this);
}

class ListsDaoManager {
  final _$ListsDaoMixin _db;
  ListsDaoManager(this._db);
  $$TrackedListsTableTableManager get trackedLists =>
      $$TrackedListsTableTableManager(_db.attachedDatabase, _db.trackedLists);
  $$ListItemsTableTableManager get listItems =>
      $$ListItemsTableTableManager(_db.attachedDatabase, _db.listItems);
}
