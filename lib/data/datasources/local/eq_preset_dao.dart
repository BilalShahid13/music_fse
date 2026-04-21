import 'package:drift/drift.dart';

import 'database.dart';

part 'eq_preset_dao.g.dart';

@DriftAccessor(tables: [EqPresets])
class EqPresetDao extends DatabaseAccessor<AppDatabase>
    with _$EqPresetDaoMixin {
  EqPresetDao(super.db);

  /// Returns all presets — builtins first (ordered by name), then user
  /// presets ordered by creation date ascending.
  Future<List<EqPreset>> getAll() =>
      (select(eqPresets)
            ..orderBy([
              (p) => OrderingTerm.desc(p.isBuiltin),
              (p) => OrderingTerm.asc(p.name),
            ]))
          .get();

  Future<EqPreset?> getById(int id) =>
      (select(eqPresets)..where((p) => p.id.equals(id))).getSingleOrNull();

  Future<int> createPreset(String name, String bandsJson) =>
      into(eqPresets)
          .insertReturning(
            EqPresetsCompanion.insert(
              name: name,
              bandsJson: bandsJson,
            ),
          )
          .then((row) => row.id);

  Future<void> updatePreset(int id, String bandsJson) =>
      (update(eqPresets)..where((p) => p.id.equals(id))).write(
        EqPresetsCompanion(bandsJson: Value(bandsJson)),
      );

  /// Deletes only non-builtin presets. Silently ignores if [id] is builtin.
  Future<void> deletePreset(int id) =>
      (delete(eqPresets)
            ..where((p) => p.id.equals(id) & p.isBuiltin.equals(false)))
          .go();
}
