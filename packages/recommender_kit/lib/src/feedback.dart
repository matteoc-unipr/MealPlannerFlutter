import 'package:core_kit/core_kit.dart';
import 'package:core_kit/src/drift/drift_database.dart';
import 'package:data_kit/data_kit.dart';
import 'package:drift/drift.dart';

/// Stores user feedback as an [EventLog] entry in the shared database.
Future<void> recordFeedback(EventLog event) async {
  final AppDatabase db = await initDatabase();
  await db.into(db.eventLogs).insert(
        _MapInsertable(db.eventLogToColumns(event)),
        mode: InsertMode.insertOrReplace,
      );
}

class _MapInsertable implements Insertable<dynamic> {
  _MapInsertable(this.values);

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
