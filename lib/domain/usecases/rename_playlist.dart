import '../repositories/playlist_repository.dart';
import '../../core/errors/result.dart';

/// Renames a playlist.
final class RenamePlaylist {
  const RenamePlaylist(this._repository);

  final PlaylistRepository _repository;

  Future<Result<void>> call(int playlistId, String name) => _repository.renamePlaylist(playlistId, name);
}
