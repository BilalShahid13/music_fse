import '../entities/genre.dart';
import '../repositories/song_repository.dart';
import '../../core/errors/result.dart';

/// Returns all genres derived from the library, optionally sorted.
///
/// [sortBy] accepts: 'name' | 'songCount'.
final class GetAllGenres {
  const GetAllGenres(this._repository);

  final SongRepository _repository;

  Future<Result<List<Genre>>> call({
    String? sortBy,
    bool ascending = true,
  }) =>
      _repository.getAllGenres(sortBy: sortBy, ascending: ascending);
}
