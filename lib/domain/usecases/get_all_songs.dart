import '../entities/song.dart';
import '../repositories/song_repository.dart';
import '../../core/errors/result.dart';

/// Returns all songs from the library, optionally sorted.
///
/// [sortBy] accepts: 'title' | 'artist' | 'album' | 'dateAdded' | 'year' |
/// 'duration' | 'trackNumber'. Defaults to title ascending.
final class GetAllSongs {
  const GetAllSongs(this._repository);

  final SongRepository _repository;

  Future<Result<List<Song>>> call({
    String? sortBy,
    bool ascending = true,
  }) =>
      _repository.getAllSongs(sortBy: sortBy, ascending: ascending);
}
