import '../entities/song.dart';
import '../repositories/song_repository.dart';
import '../../core/errors/result.dart';

/// Returns all songs whose file paths fall under [folderPath].
final class GetSongsByFolder {
  const GetSongsByFolder(this._repository);

  final SongRepository _repository;

  Future<Result<List<Song>>> call(String folderPath) => _repository.getSongsByFolder(folderPath);
}
