import 'package:freezed_annotation/freezed_annotation.dart';

import 'song.dart';

part 'playback_state.freezed.dart';

/// Controls how the player repeats tracks.
enum RepeatMode {
  /// No repetition — stop after the last queue item.
  off,

  /// Repeat the entire queue.
  all,

  /// Repeat the current track indefinitely.
  one,
}

/// Identifies what context the current queue was populated from.
/// Used to display context info in the Now Playing screen and for SMTC.
enum QueueSourceType {
  library,
  album,
  artist,
  genre,
  playlist,
  search,
  folder,

  /// Queue was populated from the favorites view.
  favorites,

  /// Queue was populated from the recently played view.
  recentlyPlayed,

  /// Queue was populated from the "All Songs" view.
  allSongs,

  /// Songs were added to the queue manually (e.g. "Add to Queue" action).
  manual,
}

/// Snapshot of the audio playback engine's current state.
///
/// This is a pure value object — no methods, no side effects.
/// The playback provider composes these fields from just_audio streams and
/// persists a serialised form to the database on app close so playback can be
/// resumed on next launch.
@freezed
abstract class PlaybackState with _$PlaybackState {
  const factory PlaybackState({
    /// The song currently loaded in the player. Null when the queue is empty.
    Song? currentSong,
    @Default(false) bool isPlaying,
    @Default(Duration.zero) Duration position,
    @Default(Duration.zero) Duration duration,
    @Default(false) bool isShuffle,
    @Default(RepeatMode.off) RepeatMode repeatMode,

    /// Master volume 0.0–1.0. Default 0.7 per REQUIREMENTS §7.1.
    @Default(0.7) double volume,
    @Default(false) bool isMuted,

    /// Crossfade duration in seconds (0 = disabled).
    @Default(0) int crossfadeSeconds,
    @Default(false) bool isEqEnabled,

    /// What populated the queue (e.g. an album or playlist).
    QueueSourceType? queueSourceType,

    /// The ID of the source (playlist ID, album name hash, etc.).
    int? queueSourceId,

    /// The current ordered queue of songs.
    @Default([]) List<Song> queue,
  }) = _PlaybackState;

  /// An empty, stopped playback state — used as the initial value.
  factory PlaybackState.initial() => const PlaybackState();
}
