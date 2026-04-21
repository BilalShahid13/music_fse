import '../entities/album.dart';
import '../repositories/song_repository.dart';
import '../../core/errors/result.dart';

/// Returns all albums derived from the library, optionally sorted.
///
/// [sortBy] accepts: 'name' | 'artist' | 'year' | 'songCount'.
final class GetAllAlbums {
  const GetAllAlbums(this._repository);

  final SongRepository _repository;

  Future<Result<List<Album>>> call({
    String? sortBy,
    bool ascending = true,
  }) =>
      _repository.getAllAlbums(sortBy: sortBy, ascending: ascending);
}
