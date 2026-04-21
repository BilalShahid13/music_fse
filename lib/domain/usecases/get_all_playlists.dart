import '../entities/playlist.dart';
import '../repositories/playlist_repository.dart';
import '../../core/errors/result.dart';

/// Returns all playlists, optionally sorted.
///
/// [sortBy] accepts: 'name' | 'createdAt' | 'updatedAt' | 'songCount'.
final class GetAllPlaylists {
  const GetAllPlaylists(this._repository);

  final PlaylistRepository _repository;

  Future<Result<List<Playlist>>> call({
    String? sortBy,
    bool ascending = true,
  }) =>
      _repository.getAllPlaylists(sortBy: sortBy, ascending: ascending);
}
