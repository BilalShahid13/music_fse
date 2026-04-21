import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/utils/logger.dart';
import '../../domain/entities/playlist.dart';
import '../../domain/entities/song.dart';
import 'use_case_providers.dart';

part 'playlist_provider.g.dart';

// ---------------------------------------------------------------------------
// Playlist list
// ---------------------------------------------------------------------------

/// All playlists, optionally sorted.
///
/// [sortBy] accepts: 'name' | 'createdAt' | 'updatedAt' | 'songCount'.
@riverpod
class PlaylistsNotifier extends _$PlaylistsNotifier {
  @override
  Future<List<Playlist>> build({
    String sortBy = 'name',
    bool ascending = true,
  }) async {
    final useCase = ref.watch(getAllPlaylistsProvider);
    final result = await useCase.call(sortBy: sortBy, ascending: ascending);
    return result.when(
      success: List.unmodifiable,
      failure: (error) {
        AppLogger.error(
          'PlaylistsNotifier: failed to load playlists',
          tag: 'PlaylistsNotifier',
          error: error,
        );
        return const [];
      },
    );
  }

  // ---------------------------------------------------------------------------
  // CRUD
  // ---------------------------------------------------------------------------

  /// Creates a new empty playlist with [name] and refreshes the list.
  ///
  /// Returns the new playlist's ID, or -1 on failure.
  Future<int> createPlaylist(String name) async {
    final useCase = ref.read(createPlaylistProvider);
    final result = await useCase.call(name);
    return result.when(
      success: (id) {
        ref.invalidateSelf();
        return id;
      },
      failure: (error) {
        AppLogger.error(
          'PlaylistsNotifier: failed to create playlist',
          tag: 'PlaylistsNotifier',
          error: error,
        );
        return -1;
      },
    );
  }

  /// Renames playlist [id] to [name].
  Future<void> renamePlaylist(int id, String name) async {
    final useCase = ref.read(renamePlaylistProvider);
    final result = await useCase.call(id, name);
    result.when(
      success: (_) => ref.invalidateSelf(),
      failure: (error) => AppLogger.error(
        'PlaylistsNotifier: failed to rename playlist',
        tag: 'PlaylistsNotifier',
        error: error,
      ),
    );
  }

  /// Deletes playlist [id].
  Future<void> deletePlaylist(int id) async {
    final useCase = ref.read(deletePlaylistProvider);
    final result = await useCase.call(id);
    result.when(
      success: (_) => ref.invalidateSelf(),
      failure: (error) => AppLogger.error(
        'PlaylistsNotifier: failed to delete playlist',
        tag: 'PlaylistsNotifier',
        error: error,
      ),
    );
  }

  /// Duplicates playlist [id] with a "(Copy)" name suffix.
  Future<void> duplicatePlaylist(int id) async {
    final useCase = ref.read(duplicatePlaylistProvider);
    final result = await useCase.call(id);
    result.when(
      success: (_) => ref.invalidateSelf(),
      failure: (error) => AppLogger.error(
        'PlaylistsNotifier: failed to duplicate playlist',
        tag: 'PlaylistsNotifier',
        error: error,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Playlist songs
// ---------------------------------------------------------------------------

/// Songs belonging to [playlistId], ordered by their sort position.
///
/// This is a separate provider from [PlaylistsNotifier] so that updating
/// song membership does not force the entire playlist list to reload.
@riverpod
class PlaylistSongsNotifier extends _$PlaylistSongsNotifier {
  @override
  Future<List<Song>> build(int playlistId) async {
    final useCase = ref.watch(getPlaylistSongsProvider);
    final result = await useCase.call(playlistId);
    return result.when(
      success: List.unmodifiable,
      failure: (error) {
        AppLogger.error(
          'PlaylistSongsNotifier: failed to load songs for playlist $playlistId',
          tag: 'PlaylistSongsNotifier',
          error: error,
        );
        return const [];
      },
    );
  }

  /// Adds [songId] to this playlist and refreshes.
  Future<void> addSong(int songId) async {
    final useCase = ref.read(addSongToPlaylistProvider);
    final result = await useCase.call(playlistId, songId);
    if (result.isSuccess) ref.invalidateSelf();
  }

  /// Removes [songId] from this playlist and refreshes.
  Future<void> removeSong(int songId) async {
    final useCase = ref.read(removeSongFromPlaylistProvider);
    final result = await useCase.call(playlistId, songId);
    if (result.isSuccess) ref.invalidateSelf();
  }

  /// Reorders the song at [oldIndex] to [newIndex] and refreshes.
  Future<void> reorderSong(int oldIndex, int newIndex) async {
    final useCase = ref.read(reorderPlaylistSongProvider);
    final result = await useCase.call(
      playlistId,
      oldIndex: oldIndex,
      newIndex: newIndex,
    );
    if (result.isSuccess) ref.invalidateSelf();
  }
}
