import '../repositories/playlist_repository.dart';
import '../../core/errors/result.dart';

/// Appends a song to the end of a playlist.
final class AddSongToPlaylist {
  const AddSongToPlaylist(this._repository);

  final PlaylistRepository _repository;

  Future<Result<void>> call(int playlistId, int songId) => _repository.addSongToPlaylist(playlistId, songId);
}
