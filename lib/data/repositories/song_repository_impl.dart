import 'package:path/path.dart' as p;

import '../../core/errors/app_error.dart';
import '../../core/errors/result.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/album.dart';
import '../../domain/entities/artist.dart';
import '../../domain/entities/genre.dart';
import '../../domain/entities/song.dart';
import '../../domain/repositories/song_repository.dart';
import '../datasources/local/song_dao.dart';
import '../models/song_mapper.dart';

/// Concrete implementation of [SongRepository] backed by the Drift [SongDao].
///
/// Every public method wraps its DAO call in a try-catch and returns a [Result]
/// so the domain/presentation layers never see raw exceptions.
final class SongRepositoryImpl implements SongRepository {
  const SongRepositoryImpl(this._dao);

  final SongDao _dao;

  // -------------------------------------------------------------------------
  // Songs
  // -------------------------------------------------------------------------

  @override
  Future<Result<List<Song>>> getAllSongs({
    String? sortBy,
    bool ascending = true,
  }) async {
    try {
      final rows = await _dao.getAllSongs(sortBy: sortBy, ascending: ascending);
      return Result.success(rows.map((r) => r.toEntity()).toList());
    } catch (e, st) {
      AppLogger.error('getAllSongs failed', tag: 'SongRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<Song>> getSongById(int id) async {
    try {
      final row = await _dao.getSongById(id);
      if (row == null) {
        return Result.failure(
          AppError.notFound(message: 'Song not found: id=$id'),
        );
      }
      return Result.success(row.toEntity());
    } catch (e, st) {
      AppLogger.error('getSongById failed', tag: 'SongRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<Song>> getSongByPath(String filePath) async {
    try {
      final row = await _dao.getSongByPath(filePath);
      if (row == null) {
        return Result.failure(
          AppError.notFound(message: 'Song not found: $filePath'),
        );
      }
      return Result.success(row.toEntity());
    } catch (e, st) {
      AppLogger.error('getSongByPath failed', tag: 'SongRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<List<Song>>> getSongsByAlbum(
    String album,
    String albumArtist,
  ) async {
    try {
      final rows = await _dao.getSongsByAlbum(album, albumArtist);
      return Result.success(rows.map((r) => r.toEntity()).toList());
    } catch (e, st) {
      AppLogger.error('getSongsByAlbum failed', tag: 'SongRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<List<Song>>> getSongsByArtist(String artist) async {
    try {
      final rows = await _dao.getSongsByArtist(artist);
      return Result.success(rows.map((r) => r.toEntity()).toList());
    } catch (e, st) {
      AppLogger.error('getSongsByArtist failed', tag: 'SongRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<List<Song>>> getSongsByGenre(String genre) async {
    try {
      final rows = await _dao.getSongsByGenre(genre);
      return Result.success(rows.map((r) => r.toEntity()).toList());
    } catch (e, st) {
      AppLogger.error('getSongsByGenre failed', tag: 'SongRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<List<Song>>> getSongsByFolder(String folderPath) async {
    try {
      final rows = await _dao.getSongsByFolder(folderPath);
      // Filter to direct children only — DAO returns everything under the
      // folder path; we post-filter in Dart to exclude deeper sub-dirs.
      final direct = rows.map((r) => r.toEntity()).where((s) => p.dirname(s.filePath) == folderPath).toList();
      return Result.success(direct);
    } catch (e, st) {
      AppLogger.error('getSongsByFolder failed', tag: 'SongRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<List<Song>>> getFavorites({
    String? sortBy,
    bool ascending = true,
  }) async {
    try {
      final rows = await _dao.getFavorites(sortBy: sortBy, ascending: ascending);
      return Result.success(rows.map((r) => r.toEntity()).toList());
    } catch (e, st) {
      AppLogger.error('getFavorites failed', tag: 'SongRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<List<Song>>> getMostPlayed({int limit = 50}) async {
    try {
      final rows = await _dao.getMostPlayed(limit: limit);
      return Result.success(rows.map((r) => r.toEntity()).toList());
    } catch (e, st) {
      AppLogger.error('getMostPlayed failed', tag: 'SongRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<List<Song>>> getRecentlyAdded({int limit = 50}) async {
    try {
      final rows = await _dao.getRecentlyAdded(limit: limit);
      return Result.success(rows.map((r) => r.toEntity()).toList());
    } catch (e, st) {
      AppLogger.error('getRecentlyAdded failed', tag: 'SongRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<List<Song>>> getRecentlyPlayed({int limit = 100}) async {
    try {
      final rows = await _dao.getRecentlyPlayed(limit: limit);
      return Result.success(rows.map((r) => r.toEntity()).toList());
    } catch (e, st) {
      AppLogger.error('getRecentlyPlayed failed', tag: 'SongRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<List<Song>>> searchSongs(String query, {int limit = 5}) async {
    try {
      final rows = await _dao.searchSongs(query, limit: limit);
      return Result.success(rows.map((r) => r.toEntity()).toList());
    } catch (e, st) {
      AppLogger.error('searchSongs failed', tag: 'SongRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<int>> upsertSong(Song song) async {
    try {
      final id = await _dao.upsertSong(song.toCompanion());
      return Result.success(id);
    } catch (e, st) {
      AppLogger.error('upsertSong failed', tag: 'SongRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> updatePlayCount(
    int songId, {
    required int playCount,
    required DateTime lastPlayedAt,
  }) async {
    try {
      await _dao.updatePlayCount(songId, playCount, lastPlayedAt);
      return const Result.success(null);
    } catch (e, st) {
      AppLogger.error('updatePlayCount failed', tag: 'SongRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> toggleFavorite(
    int songId, {
    required bool isFavorite,
  }) async {
    try {
      await _dao.toggleFavorite(songId, isFavorite: isFavorite);
      return const Result.success(null);
    } catch (e, st) {
      AppLogger.error('toggleFavorite failed', tag: 'SongRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> markMissing(
    int songId, {
    required bool isMissing,
  }) async {
    try {
      await _dao.markMissing(songId, isMissing: isMissing);
      return const Result.success(null);
    } catch (e, st) {
      AppLogger.error('markMissing failed', tag: 'SongRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteSong(int songId) async {
    try {
      await _dao.deleteSong(songId);
      return const Result.success(null);
    } catch (e, st) {
      AppLogger.error('deleteSong failed', tag: 'SongRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<int>> getSongCount() async {
    try {
      final count = await _dao.getSongCount();
      return Result.success(count);
    } catch (e, st) {
      AppLogger.error('getSongCount failed', tag: 'SongRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<Map<String, DateTime>>> getAllFilePathsWithModified() async {
    try {
      final map = await _dao.getAllFilePathsWithModified();
      return Result.success(map);
    } catch (e, st) {
      AppLogger.error('getAllFilePathsWithModified failed', tag: 'SongRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  // -------------------------------------------------------------------------
  // Albums
  // -------------------------------------------------------------------------

  @override
  Future<Result<List<Album>>> getAllAlbums({
    String? sortBy,
    bool ascending = true,
  }) async {
    try {
      final rows = await _dao.getAllAlbums(sortBy: sortBy, ascending: ascending);
      return Result.success(
        rows
            .map(
              (r) => Album(
                name: r.name,
                artist: r.artist,
                year: r.year,
                artCachePath: r.artCachePath,
                songCount: r.songCount,
                totalDurationMs: r.totalDurationMs,
              ),
            )
            .toList(),
      );
    } catch (e, st) {
      AppLogger.error('getAllAlbums failed', tag: 'SongRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<List<Album>>> searchAlbums(String query, {int limit = 5}) async {
    try {
      final rows = await _dao.searchAlbums(query, limit: limit);
      return Result.success(
        rows
            .map(
              (r) => Album(
                name: r.name,
                artist: r.artist,
                year: r.year,
                artCachePath: r.artCachePath,
                songCount: r.songCount,
                totalDurationMs: r.totalDurationMs,
              ),
            )
            .toList(),
      );
    } catch (e, st) {
      AppLogger.error('searchAlbums failed', tag: 'SongRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  // -------------------------------------------------------------------------
  // Artists
  // -------------------------------------------------------------------------

  @override
  Future<Result<List<Artist>>> getAllArtists({
    String? sortBy,
    bool ascending = true,
  }) async {
    try {
      final rows = await _dao.getAllArtists(sortBy: sortBy, ascending: ascending);
      return Result.success(
        rows
            .map(
              (r) => Artist(
                name: r.name,
                songCount: r.songCount,
                albumCount: r.albumCount,
              ),
            )
            .toList(),
      );
    } catch (e, st) {
      AppLogger.error('getAllArtists failed', tag: 'SongRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<List<Artist>>> searchArtists(
    String query, {
    int limit = 5,
  }) async {
    try {
      final rows = await _dao.searchArtists(query, limit: limit);
      return Result.success(
        rows
            .map(
              (r) => Artist(
                name: r.name,
                songCount: r.songCount,
                albumCount: r.albumCount,
              ),
            )
            .toList(),
      );
    } catch (e, st) {
      AppLogger.error('searchArtists failed', tag: 'SongRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  // -------------------------------------------------------------------------
  // Genres
  // -------------------------------------------------------------------------

  @override
  Future<Result<List<Genre>>> getAllGenres({
    String? sortBy,
    bool ascending = true,
  }) async {
    try {
      final rows = await _dao.getAllGenres(sortBy: sortBy, ascending: ascending);
      return Result.success(
        rows.map((r) => Genre(name: r.name, songCount: r.songCount)).toList(),
      );
    } catch (e, st) {
      AppLogger.error('getAllGenres failed', tag: 'SongRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  // -------------------------------------------------------------------------
  // Folders (computed from file paths in Dart — SQLite has no path functions)
  // -------------------------------------------------------------------------

  @override
  Future<Result<List<String>>> getTopLevelFolders() async {
    try {
      final allPaths = await _dao.getAllFilePaths();
      return Result.success(_computeRootFolders(allPaths));
    } catch (e, st) {
      AppLogger.error('getTopLevelFolders failed', tag: 'SongRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<List<String>>> getSubFolders(String parentPath) async {
    try {
      final allPaths = await _dao.getAllFilePaths();
      final separator = p.separator;
      final prefix = parentPath.endsWith(separator) ? parentPath : '$parentPath$separator';

      final subDirs = <String>{};
      for (final filePath in allPaths) {
        if (!filePath.startsWith(prefix)) continue;
        final relative = filePath.substring(prefix.length);
        final nextSlash = relative.indexOf(separator);
        if (nextSlash > 0) {
          // File is in a sub-directory — add that sub-directory.
          subDirs.add('$parentPath$separator${relative.substring(0, nextSlash)}');
        }
        // Files directly in parentPath are songs, not sub-folders.
      }

      final sorted = subDirs.toList()..sort();
      return Result.success(sorted);
    } catch (e, st) {
      AppLogger.error('getSubFolders failed', tag: 'SongRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  // -------------------------------------------------------------------------
  // Library stats
  // -------------------------------------------------------------------------

  @override
  Future<Result<({int totalSongs, Duration totalDuration, int totalAlbums, int totalArtists})>> getLibraryStats() async {
    try {
      final row = await _dao.getLibraryStats();
      return Result.success((
        totalSongs: row.totalSongs,
        totalDuration: Duration(milliseconds: row.totalDurationMs),
        totalAlbums: row.totalAlbums,
        totalArtists: row.totalArtists,
      ));
    } catch (e, st) {
      AppLogger.error('getLibraryStats failed', tag: 'SongRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  /// Computes the minimal set of "root" directories from a list of file paths.
  ///
  /// A root is a directory that is not contained within any other directory
  /// that is also an immediate parent of a song. This produces the highest
  /// sensible starting point for the folder browser without needing scan
  /// folder metadata.
  static List<String> _computeRootFolders(List<String> filePaths) {
    if (filePaths.isEmpty) return [];

    // Collect all unique immediate parent directories.
    final parentDirs = filePaths.map(p.dirname).toSet().toList()..sort();

    // Build antichain: keep only dirs that are not within any other dir in
    // the set. We process sorted paths so prefixes are visited first.
    final roots = <String>[];
    for (final dir in parentDirs) {
      final isSubDir = roots.any(
        (root) => p.isWithin(root, dir),
      );
      if (!isSubDir) {
        // Remove any existing root that is a subdir of this new dir.
        roots.removeWhere((existing) => p.isWithin(dir, existing));
        roots.add(dir);
      }
    }

    return roots..sort();
  }
}
