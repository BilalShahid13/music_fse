// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queue_dao.dart';

// ignore_for_file: type=lint
mixin _$QueueDaoMixin on DatabaseAccessor<AppDatabase> {
  $SongsTable get songs => attachedDatabase.songs;
  $QueueItemsTable get queueItems => attachedDatabase.queueItems;
  QueueDaoManager get managers => QueueDaoManager(this);
}

class QueueDaoManager {
  final _$QueueDaoMixin _db;
  QueueDaoManager(this._db);
  $$SongsTableTableManager get songs =>
      $$SongsTableTableManager(_db.attachedDatabase, _db.songs);
  $$QueueItemsTableTableManager get queueItems =>
      $$QueueItemsTableTableManager(_db.attachedDatabase, _db.queueItems);
}
