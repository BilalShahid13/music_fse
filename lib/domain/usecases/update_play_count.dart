import '../repositories/song_repository.dart';
import '../../core/errors/result.dart';

/// Updates the play count and last-played timestamp for a song.
///
/// Called by the playback provider when the play-count threshold is crossed
/// (30 seconds or 50% of duration, whichever comes first).
final class UpdatePlayCount {
  const UpdatePlayCount(this._repository);

  final SongRepository _repository;

  Future<Result<void>> call(
    int songId, {
    required int playCount,
    required DateTime lastPlayedAt,
  }) =>
      _repository.updatePlayCount(
        songId,
        playCount: playCount,
        lastPlayedAt: lastPlayedAt,
      );
}
