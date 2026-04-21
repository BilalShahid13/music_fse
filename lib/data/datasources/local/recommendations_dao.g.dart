// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendations_dao.dart';

// ignore_for_file: type=lint
mixin _$RecommendationsDaoMixin on DatabaseAccessor<AppDatabase> {
  $SongsTable get songs => attachedDatabase.songs;
  $RecommendationsTable get recommendations => attachedDatabase.recommendations;
  RecommendationsDaoManager get managers => RecommendationsDaoManager(this);
}

class RecommendationsDaoManager {
  final _$RecommendationsDaoMixin _db;
  RecommendationsDaoManager(this._db);
  $$SongsTableTableManager get songs =>
      $$SongsTableTableManager(_db.attachedDatabase, _db.songs);
  $$RecommendationsTableTableManager get recommendations =>
      $$RecommendationsTableTableManager(
          _db.attachedDatabase, _db.recommendations);
}
