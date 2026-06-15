import 'dart:convert';

import 'package:drift/drift.dart';

/// Stores an arbitrary JSON document in a single TEXT column.
/// This is the "schema-light" lane: modules that don't warrant real tables
/// drop their data through here. Promote a field to a real/generated column
/// the day you need to query or sort by it.
class JsonConverter extends TypeConverter<Map<String, dynamic>, String> {
  const JsonConverter();

  @override
  Map<String, dynamic> fromSql(String fromDb) =>
      json.decode(fromDb) as Map<String, dynamic>;

  @override
  String toSql(Map<String, dynamic> value) => json.encode(value);
}
