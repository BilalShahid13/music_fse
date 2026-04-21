import 'package:drift/drift.dart';

import '../../domain/entities/queue_item.dart' as domain;
import '../datasources/local/database.dart';
import '../datasources/local/queue_dao.dart';
import 'song_mapper.dart';

/// Converts a [QueueItemWithSong] (DAO join result) into a domain [domain.QueueItem].
extension QueueItemWithSongMapper on QueueItemWithSong {
  domain.QueueItem toEntity() => domain.QueueItem(
        song: song.toEntity(),
        sortOrder: queueItem.sortOrder,
        isCurrent: queueItem.isCurrent,
        positionMs: queueItem.positionMs,
      );
}

/// Converts a domain [domain.QueueItem] into a [QueueItemsCompanion] for
/// batch insertion. [sortOrder] must be supplied explicitly.
QueueItemsCompanion queueItemToCompanion(
  domain.QueueItem item, {
  required int sortOrder,
}) =>
    QueueItemsCompanion.insert(
      songId: item.song.id,
      sortOrder: sortOrder,
      isCurrent: Value(item.isCurrent),
      positionMs: Value(item.positionMs),
    );
