import '../repositories/song_repository.dart';
import '../../core/errors/result.dart';

/// Toggles the favorite status of a song.
final class ToggleFavorite {
  const ToggleFavorite(this._repository);

  final SongRepository _repository;

  Future<Result<void>> call(int songId, {required bool isFavorite}) => _repository.toggleFavorite(songId, isFavorite: isFavorite);
}
