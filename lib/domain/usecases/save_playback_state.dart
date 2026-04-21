import '../entities/playback_state.dart';
import '../repositories/playback_repository.dart';
import '../../core/errors/result.dart';

/// Persists the current playback state to the database.
///
/// Called when the app is about to close or background.
final class SavePlaybackState {
  const SavePlaybackState(this._repository);

  final PlaybackRepository _repository;

  Future<Result<void>> call(PlaybackState state) => _repository.savePlaybackState(state);
}
