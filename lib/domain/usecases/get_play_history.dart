import '../entities/play_history_entry.dart';
import '../repositories/play_history_repository.dart';
import '../../core/errors/result.dart';

/// Returns the most recent play history entries.
final class GetPlayHistory {
  const GetPlayHistory(this._repository);

  final PlayHistoryRepository _repository;

  Future<Result<List<PlayHistoryEntry>>> call({int limit = 200}) => _repository.getHistory(limit: limit);
}
