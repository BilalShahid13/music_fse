import '../entities/queue_item.dart';
import '../repositories/playback_repository.dart';
import '../../core/errors/result.dart';

/// Returns the persisted playback queue, ordered by sort position.
final class GetSavedQueue {
  const GetSavedQueue(this._repository);

  final PlaybackRepository _repository;

  Future<Result<List<QueueItem>>> call() => _repository.getQueue();
}
