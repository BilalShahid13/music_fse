import '../entities/queue_item.dart';
import '../entities/song.dart';
import '../repositories/playback_repository.dart';
import '../../core/errors/result.dart';

/// Loads the resume context for the Home screen's "Quick Resume" hero card.
///
/// Combines saved playback state and saved queue into a single call so the
/// Home screen doesn't need to make multiple separate round-trips.
final class GetResumeContext {
  const GetResumeContext({
    required PlaybackRepository playbackRepository,
  }) : _playbackRepository = playbackRepository;

  final PlaybackRepository _playbackRepository;

  Future<
      Result<
          ({
            Song? lastSong,
            Duration? lastPosition,
            List<QueueItem> savedQueue,
          })>> call() async {
    final results = await Future.wait([
      _playbackRepository.getSavedPlaybackState(),
      _playbackRepository.getQueue(),
    ]);

    final stateResult = results[0];
    final queueResult = results[1];

    // If state isn't available, return empty context — not an error.
    final state = (stateResult as Result).valueOrNull;
    final queue = (queueResult as Result).valueOrNull ?? <QueueItem>[];

    Song? lastSong;
    Duration? lastPosition;

    if (state?.currentSong != null) {
      lastSong = state!.currentSong;
      lastPosition = state.position;
    } else if (queue.isNotEmpty) {
      // Fall back to finding the current item in the saved queue.
      final currentItem = queue.where((q) => q.isCurrent).firstOrNull;
      if (currentItem != null) {
        lastSong = currentItem.song;
        lastPosition = Duration(milliseconds: currentItem.positionMs);
      }
    }

    return Result.success((
      lastSong: lastSong,
      lastPosition: lastPosition,
      savedQueue: queue,
    ));
  }
}
