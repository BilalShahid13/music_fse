import 'package:freezed_annotation/freezed_annotation.dart';

import 'song.dart';

part 'queue_item.freezed.dart';

/// A single entry in the playback queue.
///
/// The same song may appear multiple times in the queue (e.g., when a user
/// adds it twice). Each entry has its own auto-incremented database ID to
/// allow duplicates. [sortOrder] controls the visual position. [isCurrent]
/// marks which entry is actively playing.
@freezed
abstract class QueueItem with _$QueueItem {
  const factory QueueItem({
    required Song song,
    required int sortOrder,
    @Default(false) bool isCurrent,

    /// Position within this item, used for resume-from-queue on app restart.
    @Default(0) int positionMs,
  }) = _QueueItem;
}
