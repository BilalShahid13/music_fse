// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'play_history_dao.dart';

// ignore_for_file: type=lint
mixin _$PlayHistoryDaoMixin on DatabaseAccessor<AppDatabase> {
  $SongsTable get songs => attachedDatabase.songs;
  $PlayHistoryTable get playHistory => attachedDatabase.playHistory;
  PlayHistoryDaoManager get managers => PlayHistoryDaoManager(this);
}

class PlayHistoryDaoManager {
  final _$PlayHistoryDaoMixin _db;
  PlayHistoryDaoManager(this._db);
  $$SongsTableTableManager get songs =>
      $$SongsTableTableManager(_db.attachedDatabase, _db.songs);
  $$PlayHistoryTableTableManager get playHistory =>
      $$PlayHistoryTableTableManager(_db.attachedDatabase, _db.playHistory);
}
