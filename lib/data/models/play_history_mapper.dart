import '../../domain/entities/play_history_entry.dart' as domain;
import '../datasources/local/database.dart';

/// Converts a Drift [PlayHistoryData] row into a domain [domain.PlayHistoryEntry].
extension PlayHistoryRowMapper on PlayHistoryData {
  domain.PlayHistoryEntry toEntity() => domain.PlayHistoryEntry(
        id: id,
        songId: songId,
        playedAt: playedAt,
        durationListenedMs: durationListenedMs,
        sessionId: sessionId,
      );
}

/// Converts a domain [domain.PlayHistoryEntry] into a [PlayHistoryCompanion]
/// for insertion. The [id] is omitted — assigned by autoIncrement.
extension PlayHistoryEntryMapper on domain.PlayHistoryEntry {
  PlayHistoryCompanion toCompanion() => PlayHistoryCompanion.insert(
        songId: songId,
        playedAt: playedAt,
        durationListenedMs: durationListenedMs,
        sessionId: sessionId,
      );
}
