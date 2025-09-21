import 'package:drift/drift.dart';

/// Simple [Insertable] wrapper backed by a map of column values.
class MapInsertable implements Insertable<dynamic> {
  MapInsertable(this.values);

  final Map<String, dynamic> values;

  @override
  Map<String, Expression<Object?>> toColumns(bool nullToAbsent) {
    final mapped = <String, Expression<Object?>>{};
    values.forEach((key, value) {
      if (value == null && nullToAbsent) {
        return;
      }
      mapped[key] = _wrapValue(value);
    });
    return mapped;
  }
}

Expression<Object?> _wrapValue(dynamic value) {
  if (value is int) {
    return Variable<int>(value);
  }
  if (value is double) {
    return Variable<double>(value);
  }
  if (value is bool) {
    return Variable<bool>(value);
  }
  if (value is String) {
    return Variable<String>(value);
  }
  if (value is DateTime) {
    return Variable<DateTime>(value);
  }
  if (value is num) {
    return Variable<double>(value.toDouble());
  }
  return Variable<Object?>(value);
}

/// Returns a copy of [source] containing only keys that match [prefix],
/// stripping the prefix from the returned keys.
Map<String, dynamic> extractWithPrefix(
  Map<String, Object?> source,
  String prefix,
) {
  final result = <String, dynamic>{};
  source.forEach((key, value) {
    if (key.startsWith(prefix)) {
      result[key.substring(prefix.length)] = value;
    }
  });
  return result;
}

/// Converts a [QueryRow] into a simple map.
Map<String, dynamic> rowToMap(QueryRow row) =>
    Map<String, dynamic>.from(row.data);
