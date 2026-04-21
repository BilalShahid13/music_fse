import '../entities/play_history_entry.dart';
import '../../core/errors/result.dart';

/// Contract for recording and querying play history.
///
/// History is append-only from the perspective of normal playback.
/// [clearHistory] exists only for the user-facing "Clear History" action.
abstract class PlayHistoryRepository {
  /// Records a completed (or sufficiently long) play event.
  Future<Result<void>> addEntry(PlayHistoryEntry entry);

  /// Returns the most recent [limit] play history entries, newest first.
  Future<Result<List<PlayHistoryEntry>>> getHistory({int limit = 200});

  /// Deletes all history entries. Irreversible — caller should confirm first.
  Future<Result<void>> clearHistory();
}
