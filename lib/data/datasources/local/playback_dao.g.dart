// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playback_dao.dart';

// ignore_for_file: type=lint
mixin _$PlaybackDaoMixin on DatabaseAccessor<AppDatabase> {
  $EqPresetsTable get eqPresets => attachedDatabase.eqPresets;
  $PlaybackStatesTable get playbackStates => attachedDatabase.playbackStates;
  PlaybackDaoManager get managers => PlaybackDaoManager(this);
}

class PlaybackDaoManager {
  final _$PlaybackDaoMixin _db;
  PlaybackDaoManager(this._db);
  $$EqPresetsTableTableManager get eqPresets =>
      $$EqPresetsTableTableManager(_db.attachedDatabase, _db.eqPresets);
  $$PlaybackStatesTableTableManager get playbackStates =>
      $$PlaybackStatesTableTableManager(
          _db.attachedDatabase, _db.playbackStates);
}
