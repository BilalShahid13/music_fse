import '../entities/song.dart';
import '../repositories/song_repository.dart';
import '../../core/errors/result.dart';

/// Returns the [limit] most recently added songs, ordered by date descending.
final class GetRecentlyAdded {
  const GetRecentlyAdded(this._repository);

  final SongRepository _repository;

  Future<Result<List<Song>>> call({int limit = 50}) => _repository.getRecentlyAdded(limit: limit);
}
