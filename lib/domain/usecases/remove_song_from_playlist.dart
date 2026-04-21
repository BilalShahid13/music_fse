import '../repositories/playlist_repository.dart';
import '../../core/errors/result.dart';

/// Removes a song from a playlist and compacts the remaining sort order.
final class RemoveSongFromPlaylist {
  const RemoveSongFromPlaylist(this._repository);

  final PlaylistRepository _repository;

  Future<Result<void>> call(int playlistId, int songId) => _repository.removeSongFromPlaylist(playlistId, songId);
}
