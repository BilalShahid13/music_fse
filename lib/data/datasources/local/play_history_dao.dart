import 'package:drift/drift.dart';

import 'database.dart';

part 'play_history_dao.g.dart';

@DriftAccessor(tables: [PlayHistory])
class PlayHistoryDao extends DatabaseAccessor<AppDatabase>
    with _$PlayHistoryDaoMixin {
  PlayHistoryDao(super.db);

  Future<void> addEntry(PlayHistoryCompanion companion) =>
      into(playHistory).insert(companion);

  Future<List<PlayHistoryData>> getHistory({int limit = 100}) =>
      (select(playHistory)
            ..orderBy([(h) => OrderingTerm.desc(h.playedAt)])
            ..limit(limit))
          .get();

  Future<void> clearHistory() => delete(playHistory).go();
}
