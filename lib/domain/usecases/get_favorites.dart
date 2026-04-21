import '../entities/song.dart';
import '../repositories/song_repository.dart';
import '../../core/errors/result.dart';

/// Returns all songs marked as favorites, optionally sorted.
final class GetFavorites {
  const GetFavorites(this._repository);

  final SongRepository _repository;

  Future<Result<List<Song>>> call({
    String? sortBy,
    bool ascending = true,
  }) =>
      _repository.getFavorites(sortBy: sortBy, ascending: ascending);
}
