import '../entities/album.dart';
import '../entities/artist.dart';
import '../entities/genre.dart';
import '../entities/song.dart';
import '../../core/errors/result.dart';

/// Contract for all song-related read/write operations.
///
/// The data layer implements this. Presentation depends only on this interface —
/// never on the concrete implementation.
///
/// Methods for Album, Artist, Genre, and Folder are co-located here because
/// they are all derived from the Songs table. Splitting them into separate
/// repositories would add indirection without meaningful benefit.
abstract class SongRepository {
  // ---------------------------------------------------------------------------
  // Songs
  // ---------------------------------------------------------------------------

  /// Returns all songs sorted by [sortBy] field ('title' | 'artist' | 'album'
  /// | 'dateAdded' | 'year' | 'duration' | 'trackNumber').
  /// Defaults to title ascending.
  Future<Result<List<Song>>> getAllSongs({
    String? sortBy,
    bool ascending = true,
  });

  Future<Result<Song>> getSongById(int id);
  Future<Result<Song>> getSongByPath(String filePath);

  Future<Result<List<Song>>> getSongsByAlbum(
    String album,
    String albumArtist,
  );

  Future<Result<List<Song>>> getSongsByArtist(String artist);
  Future<Result<List<Song>>> getSongsByGenre(String genre);

  /// Returns songs whose [filePath] starts with [folderPath].
  Future<Result<List<Song>>> getSongsByFolder(String folderPath);

  Future<Result<List<Song>>> getFavorites({
    String? sortBy,
    bool ascending = true,
  });

  Future<Result<List<Song>>> getMostPlayed({int limit = 50});
  Future<Result<List<Song>>> getRecentlyAdded({int limit = 50});
  Future<Result<List<Song>>> getRecentlyPlayed({int limit = 100});

  /// Full-text search across title, artist, and album. Results are limited.
  Future<Result<List<Song>>> searchSongs(String query, {int limit = 5});

  /// Inserts or updates a song by [filePath]. Returns the row ID.
  Future<Result<int>> upsertSong(Song song);

  Future<Result<void>> updatePlayCount(
    int songId, {
    required int playCount,
    required DateTime lastPlayedAt,
  });

  Future<Result<void>> toggleFavorite(
    int songId, {
    required bool isFavorite,
  });

  Future<Result<void>> markMissing(
    int songId, {
    required bool isMissing,
  });

  Future<Result<void>> deleteSong(int songId);

  /// Returns the total number of songs in the library.
  Future<Result<int>> getSongCount();

  /// Returns all file paths with their last-modified timestamps for
  /// incremental scan delta detection.
  Future<Result<Map<String, DateTime>>> getAllFilePathsWithModified();

  // ---------------------------------------------------------------------------
  // Albums (aggregated)
  // ---------------------------------------------------------------------------

  Future<Result<List<Album>>> getAllAlbums({
    String? sortBy,
    bool ascending = true,
  });

  Future<Result<List<Album>>> searchAlbums(String query, {int limit = 5});

  // ---------------------------------------------------------------------------
  // Artists (aggregated)
  // ---------------------------------------------------------------------------

  Future<Result<List<Artist>>> getAllArtists({
    String? sortBy,
    bool ascending = true,
  });

  Future<Result<List<Artist>>> searchArtists(String query, {int limit = 5});

  // ---------------------------------------------------------------------------
  // Genres (aggregated)
  // ---------------------------------------------------------------------------

  Future<Result<List<Genre>>> getAllGenres({
    String? sortBy,
    bool ascending = true,
  });

  // ---------------------------------------------------------------------------
  // Folders (derived from filePath)
  // ---------------------------------------------------------------------------

  /// Returns the unique top-level directories that contain audio files.
  Future<Result<List<String>>> getTopLevelFolders();

  /// Returns direct sub-directories of [parentPath] that contain audio files.
  Future<Result<List<String>>> getSubFolders(String parentPath);

  // ---------------------------------------------------------------------------
  // Aggregates
  // ---------------------------------------------------------------------------

  /// Returns total song count, total duration, album count, and artist count.
  /// Used by the Home screen's stats footer.
  Future<Result<({int totalSongs, Duration totalDuration, int totalAlbums, int totalArtists})>> getLibraryStats();
}
