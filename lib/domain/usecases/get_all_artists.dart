import '../entities/artist.dart';
import '../repositories/song_repository.dart';
import '../../core/errors/result.dart';

/// Returns all artists derived from the library, optionally sorted.
///
/// [sortBy] accepts: 'name' | 'songCount' | 'albumCount'.
final class GetAllArtists {
  const GetAllArtists(this._repository);

  final SongRepository _repository;

  Future<Result<List<Artist>>> call({
    String? sortBy,
    bool ascending = true,
  }) =>
      _repository.getAllArtists(sortBy: sortBy, ascending: ascending);
}
