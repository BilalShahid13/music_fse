import '../entities/song.dart';
import '../repositories/song_repository.dart';
import '../../core/errors/result.dart';

/// Returns all songs tagged with a specific genre.
final class GetSongsByGenre {
  const GetSongsByGenre(this._repository);

  final SongRepository _repository;

  Future<Result<List<Song>>> call(String genre) => _repository.getSongsByGenre(genre);
}
