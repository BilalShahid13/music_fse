import '../entities/playback_state.dart';
import '../repositories/playback_repository.dart';
import '../../core/errors/result.dart';

/// Returns the last persisted playback state (volume, repeat, shuffle, etc.).
///
/// Returns [PlaybackState.initial()] if nothing has been saved yet.
final class GetSavedPlaybackState {
  const GetSavedPlaybackState(this._repository);

  final PlaybackRepository _repository;

  Future<Result<PlaybackState>> call() => _repository.getSavedPlaybackState();
}
