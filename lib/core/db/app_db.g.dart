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
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt];
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
  const TrackedList({
    required this.id,
    required this.name,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TrackedListsCompanion toCompanion(bool nullToAbsent) {
    return TrackedListsCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
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
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TrackedList copyWith({int? id, String? name, DateTime? createdAt}) =>
      TrackedList(
        id: id ?? this.id,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
      );
  TrackedList copyWithCompanion(TrackedListsCompanion data) {
    return TrackedList(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackedList(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackedList &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt);
}

class TrackedListsCompanion extends UpdateCompanion<TrackedList> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  const TrackedListsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TrackedListsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<TrackedList> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TrackedListsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
  }) {
    return TrackedListsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackedListsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
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
  @override
  List<GeneratedColumn> get $columns => [id, listId, label, done, createdAt];
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
  const ListItem({
    required this.id,
    required this.listId,
    required this.label,
    required this.done,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['list_id'] = Variable<int>(listId);
    map['label'] = Variable<String>(label);
    map['done'] = Variable<bool>(done);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ListItemsCompanion toCompanion(bool nullToAbsent) {
    return ListItemsCompanion(
      id: Value(id),
      listId: Value(listId),
      label: Value(label),
      done: Value(done),
      createdAt: Value(createdAt),
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
    };
  }

  ListItem copyWith({
    int? id,
    int? listId,
    String? label,
    bool? done,
    DateTime? createdAt,
  }) => ListItem(
    id: id ?? this.id,
    listId: listId ?? this.listId,
    label: label ?? this.label,
    done: done ?? this.done,
    createdAt: createdAt ?? this.createdAt,
  );
  ListItem copyWithCompanion(ListItemsCompanion data) {
    return ListItem(
      id: data.id.present ? data.id.value : this.id,
      listId: data.listId.present ? data.listId.value : this.listId,
      label: data.label.present ? data.label.value : this.label,
      done: data.done.present ? data.done.value : this.done,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ListItem(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('label: $label, ')
          ..write('done: $done, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, listId, label, done, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ListItem &&
          other.id == this.id &&
          other.listId == this.listId &&
          other.label == this.label &&
          other.done == this.done &&
          other.createdAt == this.createdAt);
}

class ListItemsCompanion extends UpdateCompanion<ListItem> {
  final Value<int> id;
  final Value<int> listId;
  final Value<String> label;
  final Value<bool> done;
  final Value<DateTime> createdAt;
  const ListItemsCompanion({
    this.id = const Value.absent(),
    this.listId = const Value.absent(),
    this.label = const Value.absent(),
    this.done = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ListItemsCompanion.insert({
    this.id = const Value.absent(),
    required int listId,
    required String label,
    this.done = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : listId = Value(listId),
       label = Value(label);
  static Insertable<ListItem> custom({
    Expression<int>? id,
    Expression<int>? listId,
    Expression<String>? label,
    Expression<bool>? done,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (listId != null) 'list_id': listId,
      if (label != null) 'label': label,
      if (done != null) 'done': done,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ListItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? listId,
    Value<String>? label,
    Value<bool>? done,
    Value<DateTime>? createdAt,
  }) {
    return ListItemsCompanion(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      label: label ?? this.label,
      done: done ?? this.done,
      createdAt: createdAt ?? this.createdAt,
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ListItemsCompanion(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('label: $label, ')
          ..write('done: $done, ')
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

abstract class _$AppDb extends GeneratedDatabase {
  _$AppDb(QueryExecutor e) : super(e);
  $AppDbManager get managers => $AppDbManager(this);
  late final $TrackedListsTable trackedLists = $TrackedListsTable(this);
  late final $ListItemsTable listItems = $ListItemsTable(this);
  late final $ModuleDataTable moduleData = $ModuleDataTable(this);
  late final ListsDao listsDao = ListsDao(this as AppDb);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    trackedLists,
    listItems,
    moduleData,
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
    });
typedef $$TrackedListsTableUpdateCompanionBuilder =
    TrackedListsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<DateTime> createdAt,
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
              }) => TrackedListsCompanion(
                id: id,
                name: name,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<DateTime> createdAt = const Value.absent(),
              }) => TrackedListsCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
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
    });
typedef $$ListItemsTableUpdateCompanionBuilder =
    ListItemsCompanion Function({
      Value<int> id,
      Value<int> listId,
      Value<String> label,
      Value<bool> done,
      Value<DateTime> createdAt,
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
              }) => ListItemsCompanion(
                id: id,
                listId: listId,
                label: label,
                done: done,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int listId,
                required String label,
                Value<bool> done = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ListItemsCompanion.insert(
                id: id,
                listId: listId,
                label: label,
                done: done,
                createdAt: createdAt,
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

class $AppDbManager {
  final _$AppDb _db;
  $AppDbManager(this._db);
  $$TrackedListsTableTableManager get trackedLists =>
      $$TrackedListsTableTableManager(_db, _db.trackedLists);
  $$ListItemsTableTableManager get listItems =>
      $$ListItemsTableTableManager(_db, _db.listItems);
  $$ModuleDataTableTableManager get moduleData =>
      $$ModuleDataTableTableManager(_db, _db.moduleData);
}
