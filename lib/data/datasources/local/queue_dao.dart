import 'package:drift/drift.dart';

import 'database.dart';

part 'queue_dao.g.dart';

/// A typed result that pairs a queue item row with its full song row.
final class QueueItemWithSong {
  const QueueItemWithSong({
    required this.queueItem,
    required this.song,
  });

  final QueueItem queueItem;
  final Song song;
}

@DriftAccessor(tables: [QueueItems, Songs])
class QueueDao extends DatabaseAccessor<AppDatabase> with _$QueueDaoMixin {
  QueueDao(super.db);

  /// Returns all queue items joined with their songs, ordered by sort_order.
  Future<List<QueueItemWithSong>> getQueue() {
    final query = select(queueItems).join([
      innerJoin(songs, songs.id.equalsExp(queueItems.songId)),
    ])
      ..orderBy([OrderingTerm.asc(queueItems.sortOrder)]);

    return query
        .map(
          (row) => QueueItemWithSong(
            queueItem: row.readTable(queueItems),
            song: row.readTable(songs),
          ),
        )
        .get();
  }

  /// Replaces the entire queue atomically.
  Future<void> saveQueue(List<QueueItemsCompanion> companions) =>
      transaction(() async {
        await delete(queueItems).go();
        if (companions.isNotEmpty) {
          await batch((b) => b.insertAll(queueItems, companions));
        }
      });

  Future<void> clearQueue() => delete(queueItems).go();
}
