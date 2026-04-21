import 'package:freezed_annotation/freezed_annotation.dart';

part 'play_history_entry.freezed.dart';

/// Records a single listening event.
///
/// Created when a track exceeds the play-count threshold
/// (30 seconds or 50% of duration, whichever comes first).
/// [sessionId] groups entries within a single app session, allowing the
/// recommendations engine to understand listening context.
@freezed
abstract class PlayHistoryEntry with _$PlayHistoryEntry {
  const factory PlayHistoryEntry({
    required int id,
    required int songId,
    required DateTime playedAt,

    /// How many milliseconds of the track were actually listened to.
    required int durationListenedMs,

    /// Numeric session identifier — incremented each time the app launches.
    required int sessionId,
  }) = _PlayHistoryEntry;
}
