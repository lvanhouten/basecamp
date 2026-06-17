// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_db.dart';

// ignore_for_file: type=lint
class $TrackedListsTable extends TrackedLists
    with TableInfo<$TrackedListsTable, TrackedList> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackedListsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _pinnedMeta = const VerificationMeta('pinned');
  @override
  late final GeneratedColumn<bool> pinned = GeneratedColumn<bool>(
    'pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt, pinned, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tracked_lists';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrackedList> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('pinned')) {
      context.handle(
        _pinnedMeta,
        pinned.isAcceptableOrUnknown(data['pinned']!, _pinnedMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrackedList map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackedList(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      pinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pinned'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $TrackedListsTable createAlias(String alias) {
    return $TrackedListsTable(attachedDatabase, alias);
  }
}

class TrackedList extends DataClass implements Insertable<TrackedList> {
  final int id;
  final String name;
  final DateTime createdAt;
  final bool pinned;
  final int position;
  const TrackedList({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.pinned,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['pinned'] = Variable<bool>(pinned);
    map['position'] = Variable<int>(position);
    return map;
  }

  TrackedListsCompanion toCompanion(bool nullToAbsent) {
    return TrackedListsCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
      pinned: Value(pinned),
      position: Value(position),
    );
  }

  factory TrackedList.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackedList(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      pinned: serializer.fromJson<bool>(json['pinned']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'pinned': serializer.toJson<bool>(pinned),
      'position': serializer.toJson<int>(position),
    };
  }

  TrackedList copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
    bool? pinned,
    int? position,
  }) => TrackedList(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    pinned: pinned ?? this.pinned,
    position: position ?? this.position,
  );
  TrackedList copyWithCompanion(TrackedListsCompanion data) {
    return TrackedList(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      pinned: data.pinned.present ? data.pinned.value : this.pinned,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackedList(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('pinned: $pinned, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt, pinned, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackedList &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.pinned == this.pinned &&
          other.position == this.position);
}

class TrackedListsCompanion extends UpdateCompanion<TrackedList> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<bool> pinned;
  final Value<int> position;
  const TrackedListsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.pinned = const Value.absent(),
    this.position = const Value.absent(),
  });
  TrackedListsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.createdAt = const Value.absent(),
    this.pinned = const Value.absent(),
    this.position = const Value.absent(),
  }) : name = Value(name);
  static Insertable<TrackedList> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<bool>? pinned,
    Expression<int>? position,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (pinned != null) 'pinned': pinned,
      if (position != null) 'position': position,
    });
  }

  TrackedListsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<bool>? pinned,
    Value<int>? position,
  }) {
    return TrackedListsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      pinned: pinned ?? this.pinned,
      position: position ?? this.position,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (pinned.present) {
      map['pinned'] = Variable<bool>(pinned.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackedListsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('pinned: $pinned, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }
}

class $ListItemsTable extends ListItems
    with TableInfo<$ListItemsTable, ListItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ListItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _listIdMeta = const VerificationMeta('listId');
  @override
  late final GeneratedColumn<int> listId = GeneratedColumn<int>(
    'list_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tracked_lists (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doneMeta = const VerificationMeta('done');
  @override
  late final GeneratedColumn<bool> done = GeneratedColumn<bool>(
    'done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    listId,
    label,
    done,
    createdAt,
    position,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'list_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ListItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('list_id')) {
      context.handle(
        _listIdMeta,
        listId.isAcceptableOrUnknown(data['list_id']!, _listIdMeta),
      );
    } else if (isInserting) {
      context.missing(_listIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('done')) {
      context.handle(
        _doneMeta,
        done.isAcceptableOrUnknown(data['done']!, _doneMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ListItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ListItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      listId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}list_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      done: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}done'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $ListItemsTable createAlias(String alias) {
    return $ListItemsTable(attachedDatabase, alias);
  }
}

class ListItem extends DataClass implements Insertable<ListItem> {
  final int id;
  final int listId;
  final String label;
  final bool done;
  final DateTime createdAt;
  final int position;
  const ListItem({
    required this.id,
    required this.listId,
    required this.label,
    required this.done,
    required this.createdAt,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['list_id'] = Variable<int>(listId);
    map['label'] = Variable<String>(label);
    map['done'] = Variable<bool>(done);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['position'] = Variable<int>(position);
    return map;
  }

  ListItemsCompanion toCompanion(bool nullToAbsent) {
    return ListItemsCompanion(
      id: Value(id),
      listId: Value(listId),
      label: Value(label),
      done: Value(done),
      createdAt: Value(createdAt),
      position: Value(position),
    );
  }

  factory ListItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ListItem(
      id: serializer.fromJson<int>(json['id']),
      listId: serializer.fromJson<int>(json['listId']),
      label: serializer.fromJson<String>(json['label']),
      done: serializer.fromJson<bool>(json['done']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'listId': serializer.toJson<int>(listId),
      'label': serializer.toJson<String>(label),
      'done': serializer.toJson<bool>(done),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'position': serializer.toJson<int>(position),
    };
  }

  ListItem copyWith({
    int? id,
    int? listId,
    String? label,
    bool? done,
    DateTime? createdAt,
    int? position,
  }) => ListItem(
    id: id ?? this.id,
    listId: listId ?? this.listId,
    label: label ?? this.label,
    done: done ?? this.done,
    createdAt: createdAt ?? this.createdAt,
    position: position ?? this.position,
  );
  ListItem copyWithCompanion(ListItemsCompanion data) {
    return ListItem(
      id: data.id.present ? data.id.value : this.id,
      listId: data.listId.present ? data.listId.value : this.listId,
      label: data.label.present ? data.label.value : this.label,
      done: data.done.present ? data.done.value : this.done,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ListItem(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('label: $label, ')
          ..write('done: $done, ')
          ..write('createdAt: $createdAt, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, listId, label, done, createdAt, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ListItem &&
          other.id == this.id &&
          other.listId == this.listId &&
          other.label == this.label &&
          other.done == this.done &&
          other.createdAt == this.createdAt &&
          other.position == this.position);
}

class ListItemsCompanion extends UpdateCompanion<ListItem> {
  final Value<int> id;
  final Value<int> listId;
  final Value<String> label;
  final Value<bool> done;
  final Value<DateTime> createdAt;
  final Value<int> position;
  const ListItemsCompanion({
    this.id = const Value.absent(),
    this.listId = const Value.absent(),
    this.label = const Value.absent(),
    this.done = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.position = const Value.absent(),
  });
  ListItemsCompanion.insert({
    this.id = const Value.absent(),
    required int listId,
    required String label,
    this.done = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.position = const Value.absent(),
  }) : listId = Value(listId),
       label = Value(label);
  static Insertable<ListItem> custom({
    Expression<int>? id,
    Expression<int>? listId,
    Expression<String>? label,
    Expression<bool>? done,
    Expression<DateTime>? createdAt,
    Expression<int>? position,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (listId != null) 'list_id': listId,
      if (label != null) 'label': label,
      if (done != null) 'done': done,
      if (createdAt != null) 'created_at': createdAt,
      if (position != null) 'position': position,
    });
  }

  ListItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? listId,
    Value<String>? label,
    Value<bool>? done,
    Value<DateTime>? createdAt,
    Value<int>? position,
  }) {
    return ListItemsCompanion(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      label: label ?? this.label,
      done: done ?? this.done,
      createdAt: createdAt ?? this.createdAt,
      position: position ?? this.position,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (listId.present) {
      map['list_id'] = Variable<int>(listId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (done.present) {
      map['done'] = Variable<bool>(done.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ListItemsCompanion(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('label: $label, ')
          ..write('done: $done, ')
          ..write('createdAt: $createdAt, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }
}

class $TimersTable extends Timers with TableInfo<$TimersTable, TimerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endsAtMeta = const VerificationMeta('endsAt');
  @override
  late final GeneratedColumn<DateTime> endsAt = GeneratedColumn<DateTime>(
    'ends_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remainingMsMeta = const VerificationMeta(
    'remainingMs',
  );
  @override
  late final GeneratedColumn<int> remainingMs = GeneratedColumn<int>(
    'remaining_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    label,
    durationMs,
    endsAt,
    remainingMs,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'timers';
  @override
  VerificationContext validateIntegrity(
    Insertable<TimerRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('ends_at')) {
      context.handle(
        _endsAtMeta,
        endsAt.isAcceptableOrUnknown(data['ends_at']!, _endsAtMeta),
      );
    }
    if (data.containsKey('remaining_ms')) {
      context.handle(
        _remainingMsMeta,
        remainingMs.isAcceptableOrUnknown(
          data['remaining_ms']!,
          _remainingMsMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TimerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimerRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      endsAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ends_at'],
      ),
      remainingMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remaining_ms'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TimersTable createAlias(String alias) {
    return $TimersTable(attachedDatabase, alias);
  }
}

class TimerRow extends DataClass implements Insertable<TimerRow> {
  final int id;

  /// Optional user label ("Tea", "Pasta"). Null = an unlabeled timer.
  final String? label;

  /// The configured countdown length in milliseconds. Set once at creation.
  final int durationMs;

  /// Absolute completion time. Set **only while running** (and on a finished
  /// timer it points to the past); null while paused. The running list orders
  /// by this ascending (soonest first).
  final DateTime? endsAt;

  /// Remaining milliseconds captured at the **pause** transition. Set **only
  /// while paused**; null while running. On resume `endsAt = now + remainingMs`
  /// and this is cleared.
  final int? remainingMs;
  final DateTime createdAt;
  const TimerRow({
    required this.id,
    this.label,
    required this.durationMs,
    this.endsAt,
    this.remainingMs,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    map['duration_ms'] = Variable<int>(durationMs);
    if (!nullToAbsent || endsAt != null) {
      map['ends_at'] = Variable<DateTime>(endsAt);
    }
    if (!nullToAbsent || remainingMs != null) {
      map['remaining_ms'] = Variable<int>(remainingMs);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TimersCompanion toCompanion(bool nullToAbsent) {
    return TimersCompanion(
      id: Value(id),
      label: label == null && nullToAbsent
          ? const Value.absent()
          : Value(label),
      durationMs: Value(durationMs),
      endsAt: endsAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endsAt),
      remainingMs: remainingMs == null && nullToAbsent
          ? const Value.absent()
          : Value(remainingMs),
      createdAt: Value(createdAt),
    );
  }

  factory TimerRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimerRow(
      id: serializer.fromJson<int>(json['id']),
      label: serializer.fromJson<String?>(json['label']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      endsAt: serializer.fromJson<DateTime?>(json['endsAt']),
      remainingMs: serializer.fromJson<int?>(json['remainingMs']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'label': serializer.toJson<String?>(label),
      'durationMs': serializer.toJson<int>(durationMs),
      'endsAt': serializer.toJson<DateTime?>(endsAt),
      'remainingMs': serializer.toJson<int?>(remainingMs),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TimerRow copyWith({
    int? id,
    Value<String?> label = const Value.absent(),
    int? durationMs,
    Value<DateTime?> endsAt = const Value.absent(),
    Value<int?> remainingMs = const Value.absent(),
    DateTime? createdAt,
  }) => TimerRow(
    id: id ?? this.id,
    label: label.present ? label.value : this.label,
    durationMs: durationMs ?? this.durationMs,
    endsAt: endsAt.present ? endsAt.value : this.endsAt,
    remainingMs: remainingMs.present ? remainingMs.value : this.remainingMs,
    createdAt: createdAt ?? this.createdAt,
  );
  TimerRow copyWithCompanion(TimersCompanion data) {
    return TimerRow(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      endsAt: data.endsAt.present ? data.endsAt.value : this.endsAt,
      remainingMs: data.remainingMs.present
          ? data.remainingMs.value
          : this.remainingMs,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimerRow(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('durationMs: $durationMs, ')
          ..write('endsAt: $endsAt, ')
          ..write('remainingMs: $remainingMs, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, label, durationMs, endsAt, remainingMs, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimerRow &&
          other.id == this.id &&
          other.label == this.label &&
          other.durationMs == this.durationMs &&
          other.endsAt == this.endsAt &&
          other.remainingMs == this.remainingMs &&
          other.createdAt == this.createdAt);
}

class TimersCompanion extends UpdateCompanion<TimerRow> {
  final Value<int> id;
  final Value<String?> label;
  final Value<int> durationMs;
  final Value<DateTime?> endsAt;
  final Value<int?> remainingMs;
  final Value<DateTime> createdAt;
  const TimersCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.endsAt = const Value.absent(),
    this.remainingMs = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TimersCompanion.insert({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    required int durationMs,
    this.endsAt = const Value.absent(),
    this.remainingMs = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : durationMs = Value(durationMs);
  static Insertable<TimerRow> custom({
    Expression<int>? id,
    Expression<String>? label,
    Expression<int>? durationMs,
    Expression<DateTime>? endsAt,
    Expression<int>? remainingMs,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (durationMs != null) 'duration_ms': durationMs,
      if (endsAt != null) 'ends_at': endsAt,
      if (remainingMs != null) 'remaining_ms': remainingMs,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TimersCompanion copyWith({
    Value<int>? id,
    Value<String?>? label,
    Value<int>? durationMs,
    Value<DateTime?>? endsAt,
    Value<int?>? remainingMs,
    Value<DateTime>? createdAt,
  }) {
    return TimersCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      durationMs: durationMs ?? this.durationMs,
      endsAt: endsAt ?? this.endsAt,
      remainingMs: remainingMs ?? this.remainingMs,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (endsAt.present) {
      map['ends_at'] = Variable<DateTime>(endsAt.value);
    }
    if (remainingMs.present) {
      map['remaining_ms'] = Variable<int>(remainingMs.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimersCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('durationMs: $durationMs, ')
          ..write('endsAt: $endsAt, ')
          ..write('remainingMs: $remainingMs, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ModuleDataTable extends ModuleData
    with TableInfo<$ModuleDataTable, ModuleDataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ModuleDataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _moduleIdMeta = const VerificationMeta(
    'moduleId',
  );
  @override
  late final GeneratedColumn<String> moduleId = GeneratedColumn<String>(
    'module_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entryKeyMeta = const VerificationMeta(
    'entryKey',
  );
  @override
  late final GeneratedColumn<String> entryKey = GeneratedColumn<String>(
    'entry_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, dynamic>, String>
  payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<Map<String, dynamic>>($ModuleDataTable.$converterpayload);
  @override
  List<GeneratedColumn> get $columns => [moduleId, entryKey, payload];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'module_data';
  @override
  VerificationContext validateIntegrity(
    Insertable<ModuleDataData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('module_id')) {
      context.handle(
        _moduleIdMeta,
        moduleId.isAcceptableOrUnknown(data['module_id']!, _moduleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_moduleIdMeta);
    }
    if (data.containsKey('entry_key')) {
      context.handle(
        _entryKeyMeta,
        entryKey.isAcceptableOrUnknown(data['entry_key']!, _entryKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_entryKeyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {moduleId, entryKey};
  @override
  ModuleDataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ModuleDataData(
      moduleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}module_id'],
      )!,
      entryKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_key'],
      )!,
      payload: $ModuleDataTable.$converterpayload.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}payload'],
        )!,
      ),
    );
  }

  @override
  $ModuleDataTable createAlias(String alias) {
    return $ModuleDataTable(attachedDatabase, alias);
  }

  static TypeConverter<Map<String, dynamic>, String> $converterpayload =
      const JsonConverter();
}

class ModuleDataData extends DataClass implements Insertable<ModuleDataData> {
  final String moduleId;
  final String entryKey;
  final Map<String, dynamic> payload;
  const ModuleDataData({
    required this.moduleId,
    required this.entryKey,
    required this.payload,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['module_id'] = Variable<String>(moduleId);
    map['entry_key'] = Variable<String>(entryKey);
    {
      map['payload'] = Variable<String>(
        $ModuleDataTable.$converterpayload.toSql(payload),
      );
    }
    return map;
  }

  ModuleDataCompanion toCompanion(bool nullToAbsent) {
    return ModuleDataCompanion(
      moduleId: Value(moduleId),
      entryKey: Value(entryKey),
      payload: Value(payload),
    );
  }

  factory ModuleDataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ModuleDataData(
      moduleId: serializer.fromJson<String>(json['moduleId']),
      entryKey: serializer.fromJson<String>(json['entryKey']),
      payload: serializer.fromJson<Map<String, dynamic>>(json['payload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'moduleId': serializer.toJson<String>(moduleId),
      'entryKey': serializer.toJson<String>(entryKey),
      'payload': serializer.toJson<Map<String, dynamic>>(payload),
    };
  }

  ModuleDataData copyWith({
    String? moduleId,
    String? entryKey,
    Map<String, dynamic>? payload,
  }) => ModuleDataData(
    moduleId: moduleId ?? this.moduleId,
    entryKey: entryKey ?? this.entryKey,
    payload: payload ?? this.payload,
  );
  ModuleDataData copyWithCompanion(ModuleDataCompanion data) {
    return ModuleDataData(
      moduleId: data.moduleId.present ? data.moduleId.value : this.moduleId,
      entryKey: data.entryKey.present ? data.entryKey.value : this.entryKey,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ModuleDataData(')
          ..write('moduleId: $moduleId, ')
          ..write('entryKey: $entryKey, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(moduleId, entryKey, payload);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ModuleDataData &&
          other.moduleId == this.moduleId &&
          other.entryKey == this.entryKey &&
          other.payload == this.payload);
}

class ModuleDataCompanion extends UpdateCompanion<ModuleDataData> {
  final Value<String> moduleId;
  final Value<String> entryKey;
  final Value<Map<String, dynamic>> payload;
  final Value<int> rowid;
  const ModuleDataCompanion({
    this.moduleId = const Value.absent(),
    this.entryKey = const Value.absent(),
    this.payload = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ModuleDataCompanion.insert({
    required String moduleId,
    required String entryKey,
    required Map<String, dynamic> payload,
    this.rowid = const Value.absent(),
  }) : moduleId = Value(moduleId),
       entryKey = Value(entryKey),
       payload = Value(payload);
  static Insertable<ModuleDataData> custom({
    Expression<String>? moduleId,
    Expression<String>? entryKey,
    Expression<String>? payload,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (moduleId != null) 'module_id': moduleId,
      if (entryKey != null) 'entry_key': entryKey,
      if (payload != null) 'payload': payload,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ModuleDataCompanion copyWith({
    Value<String>? moduleId,
    Value<String>? entryKey,
    Value<Map<String, dynamic>>? payload,
    Value<int>? rowid,
  }) {
    return ModuleDataCompanion(
      moduleId: moduleId ?? this.moduleId,
      entryKey: entryKey ?? this.entryKey,
      payload: payload ?? this.payload,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (moduleId.present) {
      map['module_id'] = Variable<String>(moduleId.value);
    }
    if (entryKey.present) {
      map['entry_key'] = Variable<String>(entryKey.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(
        $ModuleDataTable.$converterpayload.toSql(payload.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ModuleDataCompanion(')
          ..write('moduleId: $moduleId, ')
          ..write('entryKey: $entryKey, ')
          ..write('payload: $payload, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AlarmsTable extends Alarms with TableInfo<$AlarmsTable, AlarmRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlarmsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _timeOfDayMinutesMeta = const VerificationMeta(
    'timeOfDayMinutes',
  );
  @override
  late final GeneratedColumn<int> timeOfDayMinutes = GeneratedColumn<int>(
    'time_of_day_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _repeatDaysMeta = const VerificationMeta(
    'repeatDays',
  );
  @override
  late final GeneratedColumn<int> repeatDays = GeneratedColumn<int>(
    'repeat_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    timeOfDayMinutes,
    enabled,
    repeatDays,
    label,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'alarms';
  @override
  VerificationContext validateIntegrity(
    Insertable<AlarmRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('time_of_day_minutes')) {
      context.handle(
        _timeOfDayMinutesMeta,
        timeOfDayMinutes.isAcceptableOrUnknown(
          data['time_of_day_minutes']!,
          _timeOfDayMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timeOfDayMinutesMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('repeat_days')) {
      context.handle(
        _repeatDaysMeta,
        repeatDays.isAcceptableOrUnknown(data['repeat_days']!, _repeatDaysMeta),
      );
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AlarmRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AlarmRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      timeOfDayMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_of_day_minutes'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      repeatDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repeat_days'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AlarmsTable createAlias(String alias) {
    return $AlarmsTable(attachedDatabase, alias);
  }
}

class AlarmRow extends DataClass implements Insertable<AlarmRow> {
  final int id;

  /// Time-of-day in minutes since local midnight, `[0, 1440)`. The alarm fires
  /// at this wall-clock time on each due day.
  final int timeOfDayMinutes;

  /// The true on/off. A disabled alarm has no scheduled OS notification; it
  /// persists so the user can re-enable it (which reschedules). The Brief's
  /// today-due count only includes enabled alarms.
  final bool enabled;

  /// 7-bit weekday mask (bit 0 = Monday … bit 6 = Sunday). `0` = one-off; any
  /// non-zero subset = recurring. See `alarm_recurrence.dart`.
  final int repeatDays;

  /// Optional user label ("Wake up", "Meds"). Null = unlabeled.
  final String? label;
  final DateTime createdAt;
  const AlarmRow({
    required this.id,
    required this.timeOfDayMinutes,
    required this.enabled,
    required this.repeatDays,
    this.label,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['time_of_day_minutes'] = Variable<int>(timeOfDayMinutes);
    map['enabled'] = Variable<bool>(enabled);
    map['repeat_days'] = Variable<int>(repeatDays);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AlarmsCompanion toCompanion(bool nullToAbsent) {
    return AlarmsCompanion(
      id: Value(id),
      timeOfDayMinutes: Value(timeOfDayMinutes),
      enabled: Value(enabled),
      repeatDays: Value(repeatDays),
      label: label == null && nullToAbsent
          ? const Value.absent()
          : Value(label),
      createdAt: Value(createdAt),
    );
  }

  factory AlarmRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AlarmRow(
      id: serializer.fromJson<int>(json['id']),
      timeOfDayMinutes: serializer.fromJson<int>(json['timeOfDayMinutes']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      repeatDays: serializer.fromJson<int>(json['repeatDays']),
      label: serializer.fromJson<String?>(json['label']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'timeOfDayMinutes': serializer.toJson<int>(timeOfDayMinutes),
      'enabled': serializer.toJson<bool>(enabled),
      'repeatDays': serializer.toJson<int>(repeatDays),
      'label': serializer.toJson<String?>(label),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AlarmRow copyWith({
    int? id,
    int? timeOfDayMinutes,
    bool? enabled,
    int? repeatDays,
    Value<String?> label = const Value.absent(),
    DateTime? createdAt,
  }) => AlarmRow(
    id: id ?? this.id,
    timeOfDayMinutes: timeOfDayMinutes ?? this.timeOfDayMinutes,
    enabled: enabled ?? this.enabled,
    repeatDays: repeatDays ?? this.repeatDays,
    label: label.present ? label.value : this.label,
    createdAt: createdAt ?? this.createdAt,
  );
  AlarmRow copyWithCompanion(AlarmsCompanion data) {
    return AlarmRow(
      id: data.id.present ? data.id.value : this.id,
      timeOfDayMinutes: data.timeOfDayMinutes.present
          ? data.timeOfDayMinutes.value
          : this.timeOfDayMinutes,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      repeatDays: data.repeatDays.present
          ? data.repeatDays.value
          : this.repeatDays,
      label: data.label.present ? data.label.value : this.label,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AlarmRow(')
          ..write('id: $id, ')
          ..write('timeOfDayMinutes: $timeOfDayMinutes, ')
          ..write('enabled: $enabled, ')
          ..write('repeatDays: $repeatDays, ')
          ..write('label: $label, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, timeOfDayMinutes, enabled, repeatDays, label, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AlarmRow &&
          other.id == this.id &&
          other.timeOfDayMinutes == this.timeOfDayMinutes &&
          other.enabled == this.enabled &&
          other.repeatDays == this.repeatDays &&
          other.label == this.label &&
          other.createdAt == this.createdAt);
}

class AlarmsCompanion extends UpdateCompanion<AlarmRow> {
  final Value<int> id;
  final Value<int> timeOfDayMinutes;
  final Value<bool> enabled;
  final Value<int> repeatDays;
  final Value<String?> label;
  final Value<DateTime> createdAt;
  const AlarmsCompanion({
    this.id = const Value.absent(),
    this.timeOfDayMinutes = const Value.absent(),
    this.enabled = const Value.absent(),
    this.repeatDays = const Value.absent(),
    this.label = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AlarmsCompanion.insert({
    this.id = const Value.absent(),
    required int timeOfDayMinutes,
    this.enabled = const Value.absent(),
    this.repeatDays = const Value.absent(),
    this.label = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : timeOfDayMinutes = Value(timeOfDayMinutes);
  static Insertable<AlarmRow> custom({
    Expression<int>? id,
    Expression<int>? timeOfDayMinutes,
    Expression<bool>? enabled,
    Expression<int>? repeatDays,
    Expression<String>? label,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (timeOfDayMinutes != null) 'time_of_day_minutes': timeOfDayMinutes,
      if (enabled != null) 'enabled': enabled,
      if (repeatDays != null) 'repeat_days': repeatDays,
      if (label != null) 'label': label,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AlarmsCompanion copyWith({
    Value<int>? id,
    Value<int>? timeOfDayMinutes,
    Value<bool>? enabled,
    Value<int>? repeatDays,
    Value<String?>? label,
    Value<DateTime>? createdAt,
  }) {
    return AlarmsCompanion(
      id: id ?? this.id,
      timeOfDayMinutes: timeOfDayMinutes ?? this.timeOfDayMinutes,
      enabled: enabled ?? this.enabled,
      repeatDays: repeatDays ?? this.repeatDays,
      label: label ?? this.label,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (timeOfDayMinutes.present) {
      map['time_of_day_minutes'] = Variable<int>(timeOfDayMinutes.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (repeatDays.present) {
      map['repeat_days'] = Variable<int>(repeatDays.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlarmsCompanion(')
          ..write('id: $id, ')
          ..write('timeOfDayMinutes: $timeOfDayMinutes, ')
          ..write('enabled: $enabled, ')
          ..write('repeatDays: $repeatDays, ')
          ..write('label: $label, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDb extends GeneratedDatabase {
  _$AppDb(QueryExecutor e) : super(e);
  $AppDbManager get managers => $AppDbManager(this);
  late final $TrackedListsTable trackedLists = $TrackedListsTable(this);
  late final $ListItemsTable listItems = $ListItemsTable(this);
  late final $TimersTable timers = $TimersTable(this);
  late final $ModuleDataTable moduleData = $ModuleDataTable(this);
  late final $AlarmsTable alarms = $AlarmsTable(this);
  late final ListsDao listsDao = ListsDao(this as AppDb);
  late final ClockDao clockDao = ClockDao(this as AppDb);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    trackedLists,
    listItems,
    timers,
    moduleData,
    alarms,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tracked_lists',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('list_items', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$TrackedListsTableCreateCompanionBuilder =
    TrackedListsCompanion Function({
      Value<int> id,
      required String name,
      Value<DateTime> createdAt,
      Value<bool> pinned,
      Value<int> position,
    });
typedef $$TrackedListsTableUpdateCompanionBuilder =
    TrackedListsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<DateTime> createdAt,
      Value<bool> pinned,
      Value<int> position,
    });

final class $$TrackedListsTableReferences
    extends BaseReferences<_$AppDb, $TrackedListsTable, TrackedList> {
  $$TrackedListsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ListItemsTable, List<ListItem>>
  _listItemsRefsTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.listItems,
    aliasName: 'tracked_lists__id__list_items__list_id',
  );

  $$ListItemsTableProcessedTableManager get listItemsRefs {
    final manager = $$ListItemsTableTableManager(
      $_db,
      $_db.listItems,
    ).filter((f) => f.listId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_listItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TrackedListsTableFilterComposer
    extends Composer<_$AppDb, $TrackedListsTable> {
  $$TrackedListsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> listItemsRefs(
    Expression<bool> Function($$ListItemsTableFilterComposer f) f,
  ) {
    final $$ListItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.listItems,
      getReferencedColumn: (t) => t.listId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ListItemsTableFilterComposer(
            $db: $db,
            $table: $db.listItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TrackedListsTableOrderingComposer
    extends Composer<_$AppDb, $TrackedListsTable> {
  $$TrackedListsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TrackedListsTableAnnotationComposer
    extends Composer<_$AppDb, $TrackedListsTable> {
  $$TrackedListsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get pinned =>
      $composableBuilder(column: $table.pinned, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  Expression<T> listItemsRefs<T extends Object>(
    Expression<T> Function($$ListItemsTableAnnotationComposer a) f,
  ) {
    final $$ListItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.listItems,
      getReferencedColumn: (t) => t.listId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ListItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.listItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TrackedListsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $TrackedListsTable,
          TrackedList,
          $$TrackedListsTableFilterComposer,
          $$TrackedListsTableOrderingComposer,
          $$TrackedListsTableAnnotationComposer,
          $$TrackedListsTableCreateCompanionBuilder,
          $$TrackedListsTableUpdateCompanionBuilder,
          (TrackedList, $$TrackedListsTableReferences),
          TrackedList,
          PrefetchHooks Function({bool listItemsRefs})
        > {
  $$TrackedListsTableTableManager(_$AppDb db, $TrackedListsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackedListsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrackedListsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrackedListsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
                Value<int> position = const Value.absent(),
              }) => TrackedListsCompanion(
                id: id,
                name: name,
                createdAt: createdAt,
                pinned: pinned,
                position: position,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
                Value<int> position = const Value.absent(),
              }) => TrackedListsCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
                pinned: pinned,
                position: position,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TrackedListsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({listItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (listItemsRefs) db.listItems],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (listItemsRefs)
                    await $_getPrefetchedData<
                      TrackedList,
                      $TrackedListsTable,
                      ListItem
                    >(
                      currentTable: table,
                      referencedTable: $$TrackedListsTableReferences
                          ._listItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TrackedListsTableReferences(
                            db,
                            table,
                            p0,
                          ).listItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.listId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TrackedListsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $TrackedListsTable,
      TrackedList,
      $$TrackedListsTableFilterComposer,
      $$TrackedListsTableOrderingComposer,
      $$TrackedListsTableAnnotationComposer,
      $$TrackedListsTableCreateCompanionBuilder,
      $$TrackedListsTableUpdateCompanionBuilder,
      (TrackedList, $$TrackedListsTableReferences),
      TrackedList,
      PrefetchHooks Function({bool listItemsRefs})
    >;
typedef $$ListItemsTableCreateCompanionBuilder =
    ListItemsCompanion Function({
      Value<int> id,
      required int listId,
      required String label,
      Value<bool> done,
      Value<DateTime> createdAt,
      Value<int> position,
    });
typedef $$ListItemsTableUpdateCompanionBuilder =
    ListItemsCompanion Function({
      Value<int> id,
      Value<int> listId,
      Value<String> label,
      Value<bool> done,
      Value<DateTime> createdAt,
      Value<int> position,
    });

final class $$ListItemsTableReferences
    extends BaseReferences<_$AppDb, $ListItemsTable, ListItem> {
  $$ListItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TrackedListsTable _listIdTable(_$AppDb db) =>
      db.trackedLists.createAlias('list_items__list_id__tracked_lists__id');

  $$TrackedListsTableProcessedTableManager get listId {
    final $_column = $_itemColumn<int>('list_id')!;

    final manager = $$TrackedListsTableTableManager(
      $_db,
      $_db.trackedLists,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_listIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ListItemsTableFilterComposer
    extends Composer<_$AppDb, $ListItemsTable> {
  $$ListItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  $$TrackedListsTableFilterComposer get listId {
    final $$TrackedListsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.listId,
      referencedTable: $db.trackedLists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackedListsTableFilterComposer(
            $db: $db,
            $table: $db.trackedLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ListItemsTableOrderingComposer
    extends Composer<_$AppDb, $ListItemsTable> {
  $$ListItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  $$TrackedListsTableOrderingComposer get listId {
    final $$TrackedListsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.listId,
      referencedTable: $db.trackedLists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackedListsTableOrderingComposer(
            $db: $db,
            $table: $db.trackedLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ListItemsTableAnnotationComposer
    extends Composer<_$AppDb, $ListItemsTable> {
  $$ListItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<bool> get done =>
      $composableBuilder(column: $table.done, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  $$TrackedListsTableAnnotationComposer get listId {
    final $$TrackedListsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.listId,
      referencedTable: $db.trackedLists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackedListsTableAnnotationComposer(
            $db: $db,
            $table: $db.trackedLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ListItemsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $ListItemsTable,
          ListItem,
          $$ListItemsTableFilterComposer,
          $$ListItemsTableOrderingComposer,
          $$ListItemsTableAnnotationComposer,
          $$ListItemsTableCreateCompanionBuilder,
          $$ListItemsTableUpdateCompanionBuilder,
          (ListItem, $$ListItemsTableReferences),
          ListItem,
          PrefetchHooks Function({bool listId})
        > {
  $$ListItemsTableTableManager(_$AppDb db, $ListItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ListItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ListItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ListItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> listId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<bool> done = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> position = const Value.absent(),
              }) => ListItemsCompanion(
                id: id,
                listId: listId,
                label: label,
                done: done,
                createdAt: createdAt,
                position: position,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int listId,
                required String label,
                Value<bool> done = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> position = const Value.absent(),
              }) => ListItemsCompanion.insert(
                id: id,
                listId: listId,
                label: label,
                done: done,
                createdAt: createdAt,
                position: position,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ListItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({listId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (listId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.listId,
                                referencedTable: $$ListItemsTableReferences
                                    ._listIdTable(db),
                                referencedColumn: $$ListItemsTableReferences
                                    ._listIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ListItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $ListItemsTable,
      ListItem,
      $$ListItemsTableFilterComposer,
      $$ListItemsTableOrderingComposer,
      $$ListItemsTableAnnotationComposer,
      $$ListItemsTableCreateCompanionBuilder,
      $$ListItemsTableUpdateCompanionBuilder,
      (ListItem, $$ListItemsTableReferences),
      ListItem,
      PrefetchHooks Function({bool listId})
    >;
typedef $$TimersTableCreateCompanionBuilder =
    TimersCompanion Function({
      Value<int> id,
      Value<String?> label,
      required int durationMs,
      Value<DateTime?> endsAt,
      Value<int?> remainingMs,
      Value<DateTime> createdAt,
    });
typedef $$TimersTableUpdateCompanionBuilder =
    TimersCompanion Function({
      Value<int> id,
      Value<String?> label,
      Value<int> durationMs,
      Value<DateTime?> endsAt,
      Value<int?> remainingMs,
      Value<DateTime> createdAt,
    });

class $$TimersTableFilterComposer extends Composer<_$AppDb, $TimersTable> {
  $$TimersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endsAt => $composableBuilder(
    column: $table.endsAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remainingMs => $composableBuilder(
    column: $table.remainingMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TimersTableOrderingComposer extends Composer<_$AppDb, $TimersTable> {
  $$TimersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endsAt => $composableBuilder(
    column: $table.endsAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remainingMs => $composableBuilder(
    column: $table.remainingMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TimersTableAnnotationComposer extends Composer<_$AppDb, $TimersTable> {
  $$TimersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get endsAt =>
      $composableBuilder(column: $table.endsAt, builder: (column) => column);

  GeneratedColumn<int> get remainingMs => $composableBuilder(
    column: $table.remainingMs,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TimersTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $TimersTable,
          TimerRow,
          $$TimersTableFilterComposer,
          $$TimersTableOrderingComposer,
          $$TimersTableAnnotationComposer,
          $$TimersTableCreateCompanionBuilder,
          $$TimersTableUpdateCompanionBuilder,
          (TimerRow, BaseReferences<_$AppDb, $TimersTable, TimerRow>),
          TimerRow,
          PrefetchHooks Function()
        > {
  $$TimersTableTableManager(_$AppDb db, $TimersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<DateTime?> endsAt = const Value.absent(),
                Value<int?> remainingMs = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TimersCompanion(
                id: id,
                label: label,
                durationMs: durationMs,
                endsAt: endsAt,
                remainingMs: remainingMs,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> label = const Value.absent(),
                required int durationMs,
                Value<DateTime?> endsAt = const Value.absent(),
                Value<int?> remainingMs = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TimersCompanion.insert(
                id: id,
                label: label,
                durationMs: durationMs,
                endsAt: endsAt,
                remainingMs: remainingMs,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TimersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $TimersTable,
      TimerRow,
      $$TimersTableFilterComposer,
      $$TimersTableOrderingComposer,
      $$TimersTableAnnotationComposer,
      $$TimersTableCreateCompanionBuilder,
      $$TimersTableUpdateCompanionBuilder,
      (TimerRow, BaseReferences<_$AppDb, $TimersTable, TimerRow>),
      TimerRow,
      PrefetchHooks Function()
    >;
typedef $$ModuleDataTableCreateCompanionBuilder =
    ModuleDataCompanion Function({
      required String moduleId,
      required String entryKey,
      required Map<String, dynamic> payload,
      Value<int> rowid,
    });
typedef $$ModuleDataTableUpdateCompanionBuilder =
    ModuleDataCompanion Function({
      Value<String> moduleId,
      Value<String> entryKey,
      Value<Map<String, dynamic>> payload,
      Value<int> rowid,
    });

class $$ModuleDataTableFilterComposer
    extends Composer<_$AppDb, $ModuleDataTable> {
  $$ModuleDataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get moduleId => $composableBuilder(
    column: $table.moduleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryKey => $composableBuilder(
    column: $table.entryKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    Map<String, dynamic>,
    Map<String, dynamic>,
    String
  >
  get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );
}

class $$ModuleDataTableOrderingComposer
    extends Composer<_$AppDb, $ModuleDataTable> {
  $$ModuleDataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get moduleId => $composableBuilder(
    column: $table.moduleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryKey => $composableBuilder(
    column: $table.entryKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ModuleDataTableAnnotationComposer
    extends Composer<_$AppDb, $ModuleDataTable> {
  $$ModuleDataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get moduleId =>
      $composableBuilder(column: $table.moduleId, builder: (column) => column);

  GeneratedColumn<String> get entryKey =>
      $composableBuilder(column: $table.entryKey, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, dynamic>, String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);
}

class $$ModuleDataTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $ModuleDataTable,
          ModuleDataData,
          $$ModuleDataTableFilterComposer,
          $$ModuleDataTableOrderingComposer,
          $$ModuleDataTableAnnotationComposer,
          $$ModuleDataTableCreateCompanionBuilder,
          $$ModuleDataTableUpdateCompanionBuilder,
          (
            ModuleDataData,
            BaseReferences<_$AppDb, $ModuleDataTable, ModuleDataData>,
          ),
          ModuleDataData,
          PrefetchHooks Function()
        > {
  $$ModuleDataTableTableManager(_$AppDb db, $ModuleDataTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ModuleDataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ModuleDataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ModuleDataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> moduleId = const Value.absent(),
                Value<String> entryKey = const Value.absent(),
                Value<Map<String, dynamic>> payload = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ModuleDataCompanion(
                moduleId: moduleId,
                entryKey: entryKey,
                payload: payload,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String moduleId,
                required String entryKey,
                required Map<String, dynamic> payload,
                Value<int> rowid = const Value.absent(),
              }) => ModuleDataCompanion.insert(
                moduleId: moduleId,
                entryKey: entryKey,
                payload: payload,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ModuleDataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $ModuleDataTable,
      ModuleDataData,
      $$ModuleDataTableFilterComposer,
      $$ModuleDataTableOrderingComposer,
      $$ModuleDataTableAnnotationComposer,
      $$ModuleDataTableCreateCompanionBuilder,
      $$ModuleDataTableUpdateCompanionBuilder,
      (
        ModuleDataData,
        BaseReferences<_$AppDb, $ModuleDataTable, ModuleDataData>,
      ),
      ModuleDataData,
      PrefetchHooks Function()
    >;
typedef $$AlarmsTableCreateCompanionBuilder =
    AlarmsCompanion Function({
      Value<int> id,
      required int timeOfDayMinutes,
      Value<bool> enabled,
      Value<int> repeatDays,
      Value<String?> label,
      Value<DateTime> createdAt,
    });
typedef $$AlarmsTableUpdateCompanionBuilder =
    AlarmsCompanion Function({
      Value<int> id,
      Value<int> timeOfDayMinutes,
      Value<bool> enabled,
      Value<int> repeatDays,
      Value<String?> label,
      Value<DateTime> createdAt,
    });

class $$AlarmsTableFilterComposer extends Composer<_$AppDb, $AlarmsTable> {
  $$AlarmsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeOfDayMinutes => $composableBuilder(
    column: $table.timeOfDayMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repeatDays => $composableBuilder(
    column: $table.repeatDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AlarmsTableOrderingComposer extends Composer<_$AppDb, $AlarmsTable> {
  $$AlarmsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeOfDayMinutes => $composableBuilder(
    column: $table.timeOfDayMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repeatDays => $composableBuilder(
    column: $table.repeatDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AlarmsTableAnnotationComposer extends Composer<_$AppDb, $AlarmsTable> {
  $$AlarmsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get timeOfDayMinutes => $composableBuilder(
    column: $table.timeOfDayMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<int> get repeatDays => $composableBuilder(
    column: $table.repeatDays,
    builder: (column) => column,
  );

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AlarmsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $AlarmsTable,
          AlarmRow,
          $$AlarmsTableFilterComposer,
          $$AlarmsTableOrderingComposer,
          $$AlarmsTableAnnotationComposer,
          $$AlarmsTableCreateCompanionBuilder,
          $$AlarmsTableUpdateCompanionBuilder,
          (AlarmRow, BaseReferences<_$AppDb, $AlarmsTable, AlarmRow>),
          AlarmRow,
          PrefetchHooks Function()
        > {
  $$AlarmsTableTableManager(_$AppDb db, $AlarmsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlarmsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlarmsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlarmsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> timeOfDayMinutes = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> repeatDays = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AlarmsCompanion(
                id: id,
                timeOfDayMinutes: timeOfDayMinutes,
                enabled: enabled,
                repeatDays: repeatDays,
                label: label,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int timeOfDayMinutes,
                Value<bool> enabled = const Value.absent(),
                Value<int> repeatDays = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AlarmsCompanion.insert(
                id: id,
                timeOfDayMinutes: timeOfDayMinutes,
                enabled: enabled,
                repeatDays: repeatDays,
                label: label,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AlarmsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $AlarmsTable,
      AlarmRow,
      $$AlarmsTableFilterComposer,
      $$AlarmsTableOrderingComposer,
      $$AlarmsTableAnnotationComposer,
      $$AlarmsTableCreateCompanionBuilder,
      $$AlarmsTableUpdateCompanionBuilder,
      (AlarmRow, BaseReferences<_$AppDb, $AlarmsTable, AlarmRow>),
      AlarmRow,
      PrefetchHooks Function()
    >;

class $AppDbManager {
  final _$AppDb _db;
  $AppDbManager(this._db);
  $$TrackedListsTableTableManager get trackedLists =>
      $$TrackedListsTableTableManager(_db, _db.trackedLists);
  $$ListItemsTableTableManager get listItems =>
      $$ListItemsTableTableManager(_db, _db.listItems);
  $$TimersTableTableManager get timers =>
      $$TimersTableTableManager(_db, _db.timers);
  $$ModuleDataTableTableManager get moduleData =>
      $$ModuleDataTableTableManager(_db, _db.moduleData);
  $$AlarmsTableTableManager get alarms =>
      $$AlarmsTableTableManager(_db, _db.alarms);
}
