import '../entities/queue_item.dart';
import '../repositories/playlist_repository.dart';
import '../../core/errors/result.dart';

/// Saves the current playback queue as a new playlist.
///
/// Creates the playlist with [name] and adds all [queueItems] in order.
/// Returns the new playlist's ID.
///
/// Used by the Queue panel's "Save as Playlist" button.
final class SaveQueueAsPlaylist {
  const SaveQueueAsPlaylist(this._repository);

  final PlaylistRepository _repository;

  Future<Result<int>> call(String name, List<QueueItem> queueItems) async {
    final createResult = await _repository.createPlaylist(name);
    if (createResult.isFailure) return Result.failure(createResult.errorOrNull!);

    final playlistId = createResult.valueOrNull!;

    for (final item in queueItems) {
      final addResult = await _repository.addSongToPlaylist(playlistId, item.song.id);
      if (addResult.isFailure) {
        // A partial failure still returns the playlist ID — the caller can
        // inform the user that some songs could not be added.
        return Result.failure(addResult.errorOrNull!);
      }
    }

    return Result.success(playlistId);
  }
}
