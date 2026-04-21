import 'package:drift/drift.dart';

import '../../domain/entities/playback_state.dart' as domain;
import '../datasources/local/database.dart';

/// Converts a Drift [PlaybackState] row into a domain [domain.PlaybackState].
///
/// Note: [domain.PlaybackState.currentSong] is NOT stored in the database row
/// — it is resolved by the provider from the queue. This mapper populates only
/// the fields that are actually persisted.
extension PlaybackStateRowMapper on PlaybackState {
  domain.PlaybackState toEntity() => domain.PlaybackState(
        // currentSong resolved separately from queue — left null here.
        isShuffle: shuffle,
        repeatMode: _parseRepeatMode(repeatMode),
        volume: volume,
        crossfadeSeconds: crossfadeSeconds,
        isEqEnabled: eqEnabled,
        queueSourceType: _parseQueueSourceType(queueSourceType),
        queueSourceId: queueSourceId,
      );
}

/// Converts a domain [domain.PlaybackState] into a [PlaybackStatesCompanion]
/// for upserting the singleton row (id = 1).
extension PlaybackStateDomainMapper on domain.PlaybackState {
  PlaybackStatesCompanion toCompanion() => PlaybackStatesCompanion(
        id: const Value(1),
        shuffle: Value(isShuffle),
        repeatMode: Value(_encodeRepeatMode(repeatMode)),
        volume: Value(volume),
        crossfadeSeconds: Value(crossfadeSeconds),
        eqEnabled: Value(isEqEnabled),
        queueSourceType: Value(queueSourceType != null ? _encodeQueueSourceType(queueSourceType!) : null),
        queueSourceId: Value(queueSourceId),
      );
}

// ---------------------------------------------------------------------------
// Conversion helpers
// ---------------------------------------------------------------------------

domain.RepeatMode _parseRepeatMode(String raw) => switch (raw) {
      'all' => domain.RepeatMode.all,
      'one' => domain.RepeatMode.one,
      _ => domain.RepeatMode.off,
    };

String _encodeRepeatMode(domain.RepeatMode mode) => switch (mode) {
      domain.RepeatMode.all => 'all',
      domain.RepeatMode.one => 'one',
      domain.RepeatMode.off => 'off',
    };

domain.QueueSourceType? _parseQueueSourceType(String? raw) => switch (raw) {
      'library' => domain.QueueSourceType.library,
      'album' => domain.QueueSourceType.album,
      'artist' => domain.QueueSourceType.artist,
      'genre' => domain.QueueSourceType.genre,
      'playlist' => domain.QueueSourceType.playlist,
      'search' => domain.QueueSourceType.search,
      'folder' => domain.QueueSourceType.folder,
      'favorites' => domain.QueueSourceType.favorites,
      'recentlyPlayed' => domain.QueueSourceType.recentlyPlayed,
      'allSongs' => domain.QueueSourceType.allSongs,
      'manual' => domain.QueueSourceType.manual,
      _ => null,
    };

String _encodeQueueSourceType(domain.QueueSourceType type) => switch (type) {
      domain.QueueSourceType.library => 'library',
      domain.QueueSourceType.album => 'album',
      domain.QueueSourceType.artist => 'artist',
      domain.QueueSourceType.genre => 'genre',
      domain.QueueSourceType.playlist => 'playlist',
      domain.QueueSourceType.search => 'search',
      domain.QueueSourceType.folder => 'folder',
      domain.QueueSourceType.favorites => 'favorites',
      domain.QueueSourceType.recentlyPlayed => 'recentlyPlayed',
      domain.QueueSourceType.allSongs => 'allSongs',
      domain.QueueSourceType.manual => 'manual',
    };
