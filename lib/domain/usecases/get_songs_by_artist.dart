import '../entities/song.dart';
import '../repositories/song_repository.dart';
import '../../core/errors/result.dart';

/// Returns all songs by a specific artist.
final class GetSongsByArtist {
  const GetSongsByArtist(this._repository);

  final SongRepository _repository;

  Future<Result<List<Song>>> call(String artist) => _repository.getSongsByArtist(artist);
}
