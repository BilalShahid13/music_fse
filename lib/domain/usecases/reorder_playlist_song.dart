import '../repositories/playlist_repository.dart';
import '../../core/errors/result.dart';

/// Moves a song within a playlist from [oldIndex] to [newIndex].
///
/// Used by the drag-to-reorder gesture in the Playlist screen.
final class ReorderPlaylistSong {
  const ReorderPlaylistSong(this._repository);

  final PlaylistRepository _repository;

  Future<Result<void>> call(
    int playlistId, {
    required int oldIndex,
    required int newIndex,
  }) =>
      _repository.reorderPlaylistSong(
        playlistId,
        oldIndex: oldIndex,
        newIndex: newIndex,
      );
}
