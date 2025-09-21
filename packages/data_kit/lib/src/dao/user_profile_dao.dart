import 'package:core_kit/core_kit.dart';
import 'package:core_kit/src/drift/drift_database.dart';
import 'package:drift/drift.dart';

import 'dao_helpers.dart';

class UserProfileDao {
  UserProfileDao(this._db);

  final AppDatabase _db;

  Future<void> upsertProfile(UserProfile profile) async {
    await _db.into(_db.userProfiles).insert(
          MapInsertable(_db.userProfileToColumns(profile)),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<UserProfile?> getProfile(String id) async {
    final row = await _db
        .customSelect(
          'SELECT * FROM user_profiles WHERE id = ? LIMIT 1',
          variables: [Variable<String>(id)],
          readsFrom: {_db.userProfiles},
        )
        .getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _db.mapUserProfile(rowToMap(row));
  }

  Future<List<UserProfile>> getProfiles() async {
    final rows = await _db
        .customSelect(
          'SELECT * FROM user_profiles ORDER BY created_at DESC',
          readsFrom: {_db.userProfiles},
        )
        .get();
    return rows.map((row) => _db.mapUserProfile(rowToMap(row))).toList();
  }

  Future<int> deleteProfile(String id) {
    return _db.customUpdate(
      'DELETE FROM user_profiles WHERE id = ?',
      variables: [Variable<String>(id)],
      updates: {_db.userProfiles},
    );
  }

  Future<void> clear() {
    return _db.customStatement(
      'DELETE FROM user_profiles',
      updates: {_db.userProfiles},
    );
  }
}
