import '../repositories/playlist_repository.dart';
import '../../core/errors/result.dart';

/// Duplicates a playlist as a new playlist with a " (Copy)" name suffix.
final class DuplicatePlaylist {
  const DuplicatePlaylist(this._repository);

  final PlaylistRepository _repository;

  Future<Result<void>> call(int playlistId) => _repository.duplicatePlaylist(playlistId);
}
