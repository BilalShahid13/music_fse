import '../entities/song.dart';
import '../repositories/song_repository.dart';
import '../../core/errors/result.dart';

/// Returns the [limit] most recently played songs, ordered by last-played
/// date descending.
final class GetRecentlyPlayed {
  const GetRecentlyPlayed(this._repository);

  final SongRepository _repository;

  Future<Result<List<Song>>> call({int limit = 100}) => _repository.getRecentlyPlayed(limit: limit);
}
