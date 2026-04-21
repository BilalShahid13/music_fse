import '../entities/song.dart';
import '../repositories/song_repository.dart';
import '../../core/errors/result.dart';

/// Returns the [limit] most-played songs, ordered by play count descending.
final class GetMostPlayed {
  const GetMostPlayed(this._repository);

  final SongRepository _repository;

  Future<Result<List<Song>>> call({int limit = 50}) => _repository.getMostPlayed(limit: limit);
}
