// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'eq_preset_dao.dart';

// ignore_for_file: type=lint
mixin _$EqPresetDaoMixin on DatabaseAccessor<AppDatabase> {
  $EqPresetsTable get eqPresets => attachedDatabase.eqPresets;
  EqPresetDaoManager get managers => EqPresetDaoManager(this);
}

class EqPresetDaoManager {
  final _$EqPresetDaoMixin _db;
  EqPresetDaoManager(this._db);
  $$EqPresetsTableTableManager get eqPresets =>
      $$EqPresetsTableTableManager(_db.attachedDatabase, _db.eqPresets);
}
