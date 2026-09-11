import '../entities/playlist.dart';
import '../entities/song.dart';
import '../../core/errors/result.dart';

/// Contract for playlist CRUD and song membership operations.
abstract class PlaylistRepository {
  /// Returns all playlists sorted by [sortBy] ('name' | 'createdAt' |
  /// 'updatedAt' | 'songCount'). Includes computed [songCount] and
  /// [totalDurationMs].
  Future<Result<List<Playlist>>> getAllPlaylists({
    String? sortBy,
    bool ascending = true,
  });

  /// Returns a single playlist by [id] with computed aggregates.
  Future<Result<Playlist>> getPlaylistById(int id);

  /// Returns the songs in [playlistId] ordered by their [sortOrder].
  Future<Result<List<Song>>> getPlaylistSongs(int playlistId);

  /// Creates a new empty playlist and returns its new ID.
  Future<Result<int>> createPlaylist(String name);

  /// Renames [playlistId] and updates its [updatedAt] timestamp.
  Future<Result<void>> renamePlaylist(int playlistId, String name);

  /// Deletes the playlist and all of its PlaylistSongs entries.
  Future<Result<void>> deletePlaylist(int playlistId);

  /// Deletes all playlists and their song membership rows.
  Future<Result<void>> clearAllPlaylists();

  /// Duplicates [playlistId] with a " (Copy)" name suffix.
  Future<Result<void>> duplicatePlaylist(int playlistId);

  /// Appends [songId] to [playlistId] at the next sortOrder position.
  Future<Result<void>> addSongToPlaylist(int playlistId, int songId);

  /// Removes [songId] from [playlistId] and compacts the sortOrder.
  Future<Result<void>> removeSongFromPlaylist(int playlistId, int songId);

  /// Moves the song at [oldIndex] to [newIndex] within [playlistId].
  Future<Result<void>> reorderPlaylistSong(
    int playlistId, {
    required int oldIndex,
    required int newIndex,
  });

  /// Searches playlist names. Returns limited results.
  Future<Result<List<Playlist>>> searchPlaylists(
    String query, {
    int limit = 5,
  });

  /// Exports [playlistId] as an M3U file. Returns the export file path.
  Future<Result<String>> exportM3u(int playlistId);

  /// Imports a playlist from the M3U file at [filePath]. Returns the new ID.
  Future<Result<int>> importM3u(String filePath);
}
