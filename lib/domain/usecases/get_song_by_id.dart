import '../entities/song.dart';
import '../repositories/song_repository.dart';
import '../../core/errors/result.dart';

/// Returns a single song by its database ID.
final class GetSongById {
  const GetSongById(this._repository);

  final SongRepository _repository;

  Future<Result<Song>> call(int id) => _repository.getSongById(id);
}
