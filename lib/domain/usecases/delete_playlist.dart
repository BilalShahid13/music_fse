import '../repositories/playlist_repository.dart';
import '../../core/errors/result.dart';

/// Permanently deletes a playlist and all of its song entries.
final class DeletePlaylist {
  const DeletePlaylist(this._repository);

  final PlaylistRepository _repository;

  Future<Result<void>> call(int playlistId) => _repository.deletePlaylist(playlistId);
}
