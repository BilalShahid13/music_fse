import '../entities/queue_item.dart';
import '../repositories/playback_repository.dart';
import '../../core/errors/result.dart';

/// Persists the current queue to the database.
///
/// Called when the app is about to close or background so the queue can be
/// restored on next launch.
final class SaveQueue {
  const SaveQueue(this._repository);

  final PlaybackRepository _repository;

  Future<Result<void>> call(List<QueueItem> items) => _repository.saveQueue(items);
}
