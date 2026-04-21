import '../entities/playback_state.dart';
import '../entities/queue_item.dart';
import '../../core/errors/result.dart';

/// Contract for persisting and restoring queue and playback state.
///
/// This repository does NOT control the audio engine — that is the
/// responsibility of the playback provider in the presentation layer. This
/// repository only handles the database serialization of state so it can be
/// restored across app launches.
abstract class PlaybackRepository {
  // ---------------------------------------------------------------------------
  // Queue
  // ---------------------------------------------------------------------------

  /// Returns the persisted queue, ordered by [sortOrder].
  Future<Result<List<QueueItem>>> getQueue();

  /// Replaces the entire queue with [items]. Deletes all existing entries first.
  Future<Result<void>> saveQueue(List<QueueItem> items);

  /// Deletes all queue entries from the database.
  Future<Result<void>> clearQueue();

  // ---------------------------------------------------------------------------
  // Playback State
  // ---------------------------------------------------------------------------

  /// Returns the last saved playback state (shuffle, repeat, volume, etc.).
  /// Returns a default [PlaybackState.initial()] if nothing has been saved yet.
  Future<Result<PlaybackState>> getSavedPlaybackState();

  /// Persists [state] to the database so it can be restored on next launch.
  Future<Result<void>> savePlaybackState(PlaybackState state);
}
