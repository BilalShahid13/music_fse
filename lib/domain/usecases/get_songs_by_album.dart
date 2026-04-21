import '../entities/song.dart';
import '../repositories/song_repository.dart';
import '../../core/errors/result.dart';

/// Returns all songs that belong to a specific album.
///
/// Both [album] and [albumArtist] are required to disambiguate albums with
/// the same name by different artists.
final class GetSongsByAlbum {
  const GetSongsByAlbum(this._repository);

  final SongRepository _repository;

  Future<Result<List<Song>>> call(String album, String albumArtist) => _repository.getSongsByAlbum(album, albumArtist);
}
