import '../repositories/song_repository.dart';
import '../../core/errors/result.dart';

/// Returns aggregate library statistics for the Home screen's stats footer.
///
/// Returns total song count, cumulative duration, unique album count, and
/// unique artist count — all in a single query.
final class GetLibraryStats {
  const GetLibraryStats(this._repository);

  final SongRepository _repository;

  Future<
      Result<
          ({
            int totalSongs,
            Duration totalDuration,
            int totalAlbums,
            int totalArtists,
          })>> call() => _repository.getLibraryStats();
}
