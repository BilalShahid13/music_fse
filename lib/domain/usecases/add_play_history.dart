import '../entities/play_history_entry.dart';
import '../repositories/play_history_repository.dart';
import '../../core/errors/result.dart';

/// Records a completed play event.
///
/// Should be called by the playback provider once the play-count threshold
/// has been crossed (30 seconds or 50% of duration, whichever is first).
final class AddPlayHistory {
  const AddPlayHistory(this._repository);

  final PlayHistoryRepository _repository;

  Future<Result<void>> call(PlayHistoryEntry entry) => _repository.addEntry(entry);
}
