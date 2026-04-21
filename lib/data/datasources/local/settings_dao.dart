import 'package:drift/drift.dart';

import 'database.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: [Settings])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.db);

  Future<String?> getValue(String key) async {
    final row = await (select(settings)
          ..where((s) => s.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  /// Inserts or replaces the value for [key].
  Future<void> setValue(String key, String value) =>
      into(settings).insertOnConflictUpdate(
        SettingsCompanion.insert(key: key, value: value),
      );

  Future<void> remove(String key) =>
      (delete(settings)..where((s) => s.key.equals(key))).go();
}
