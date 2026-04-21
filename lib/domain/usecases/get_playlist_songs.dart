import '../entities/song.dart';
import '../repositories/playlist_repository.dart';
import '../../core/errors/result.dart';

/// Returns all songs in a playlist, ordered by their sort position.
final class GetPlaylistSongs {
  const GetPlaylistSongs(this._repository);

  final PlaylistRepository _repository;

  Future<Result<List<Song>>> call(int playlistId) => _repository.getPlaylistSongs(playlistId);
}
