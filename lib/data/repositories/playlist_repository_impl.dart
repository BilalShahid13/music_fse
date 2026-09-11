import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/errors/app_error.dart';
import '../../core/errors/result.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/playlist.dart';
import '../../domain/entities/song.dart';
import '../../domain/repositories/playlist_repository.dart';
import '../datasources/local/playlist_dao.dart';
import '../models/playlist_mapper.dart';
import '../models/song_mapper.dart';

/// Concrete implementation of [PlaylistRepository] backed by [PlaylistDao].
final class PlaylistRepositoryImpl implements PlaylistRepository {
  const PlaylistRepositoryImpl(this._dao);

  final PlaylistDao _dao;

  @override
  Future<Result<List<Playlist>>> getAllPlaylists({
    String? sortBy,
    bool ascending = true,
  }) async {
    try {
      final rows = await _dao.getAllPlaylists(sortBy: sortBy);
      final entities = rows.map((r) => r.toEntity()).toList();
      if (!ascending) entities.sort((a, b) => b.name.compareTo(a.name));
      return Result.success(entities);
    } catch (e, st) {
      AppLogger.error('getAllPlaylists failed', tag: 'PlaylistRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<Playlist>> getPlaylistById(int id) async {
    try {
      final row = await _dao.getPlaylistById(id);
      if (row == null) {
        return Result.failure(
          AppError.notFound(message: 'Playlist not found: id=$id'),
        );
      }
      return Result.success(row.toEntity());
    } catch (e, st) {
      AppLogger.error('getPlaylistById failed', tag: 'PlaylistRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<List<Song>>> getPlaylistSongs(int playlistId) async {
    try {
      final rows = await _dao.getPlaylistSongs(playlistId);
      return Result.success(rows.map((r) => r.toEntity()).toList());
    } catch (e, st) {
      AppLogger.error('getPlaylistSongs failed', tag: 'PlaylistRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<int>> createPlaylist(String name) async {
    try {
      final id = await _dao.createPlaylist(name);
      return Result.success(id);
    } catch (e, st) {
      AppLogger.error('createPlaylist failed', tag: 'PlaylistRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> renamePlaylist(int playlistId, String name) async {
    try {
      await _dao.renamePlaylist(playlistId, name);
      return const Result.success(null);
    } catch (e, st) {
      AppLogger.error('renamePlaylist failed', tag: 'PlaylistRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> deletePlaylist(int playlistId) async {
    try {
      await _dao.deletePlaylist(playlistId);
      return const Result.success(null);
    } catch (e, st) {
      AppLogger.error('deletePlaylist failed', tag: 'PlaylistRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> clearAllPlaylists() async {
    try {
      await _dao.clearAllPlaylists();
      return const Result.success(null);
    } catch (e, st) {
      AppLogger.error('clearAllPlaylists failed', tag: 'PlaylistRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> duplicatePlaylist(int playlistId) async {
    try {
      await _dao.duplicatePlaylist(playlistId);
      return const Result.success(null);
    } catch (e, st) {
      AppLogger.error('duplicatePlaylist failed', tag: 'PlaylistRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> addSongToPlaylist(
    int playlistId,
    int songId,
  ) async {
    try {
      await _dao.addSongToPlaylist(playlistId, songId);
      return const Result.success(null);
    } catch (e, st) {
      AppLogger.error('addSongToPlaylist failed', tag: 'PlaylistRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> removeSongFromPlaylist(
    int playlistId,
    int songId,
  ) async {
    try {
      await _dao.removeSongFromPlaylist(playlistId, songId);
      return const Result.success(null);
    } catch (e, st) {
      AppLogger.error('removeSongFromPlaylist failed', tag: 'PlaylistRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> reorderPlaylistSong(
    int playlistId, {
    required int oldIndex,
    required int newIndex,
  }) async {
    try {
      await _dao.reorderPlaylistSong(playlistId, oldIndex, newIndex);
      return const Result.success(null);
    } catch (e, st) {
      AppLogger.error('reorderPlaylistSong failed', tag: 'PlaylistRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<List<Playlist>>> searchPlaylists(
    String query, {
    int limit = 5,
  }) async {
    try {
      final rows = await _dao.searchPlaylists(query, limit: limit);
      return Result.success(rows.map((r) => r.toEntity()).toList());
    } catch (e, st) {
      AppLogger.error('searchPlaylists failed', tag: 'PlaylistRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  // -------------------------------------------------------------------------
  // Import / Export (M3U)
  // -------------------------------------------------------------------------

  @override
  Future<Result<String>> exportM3u(int playlistId) async {
    try {
      final playlistResult = await getPlaylistById(playlistId);
      if (playlistResult is Failure<Playlist>) {
        return Result.failure(playlistResult.error);
      }
      final playlist = (playlistResult as Success<Playlist>).value;

      final songsResult = await getPlaylistSongs(playlistId);
      if (songsResult is Failure<List<Song>>) {
        return Result.failure(songsResult.error);
      }
      final songs = (songsResult as Success<List<Song>>).value;

      final buffer = StringBuffer('#EXTM3U\n');
      for (final song in songs) {
        final durationSec = song.durationMs ~/ 1000;
        buffer
          ..write('#EXTINF:$durationSec,${song.artist} - ${song.title}\n')
          ..write('${song.filePath}\n');
      }

      final dir = await getApplicationDocumentsDirectory();
      final safeName = playlist.name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
      final dest = p.join(dir.path, '$safeName.m3u');
      await File(dest).writeAsString(buffer.toString());
      return Result.success(dest);
    } on FileSystemException catch (e, st) {
      AppLogger.error('exportM3u failed', tag: 'PlaylistRepo', error: e, stackTrace: st);
      return Result.failure(AppError.fileSystem(message: e.message));
    } catch (e, st) {
      AppLogger.error('exportM3u failed', tag: 'PlaylistRepo', error: e, stackTrace: st);
      return Result.failure(AppError.fileSystem(message: e.toString()));
    }
  }

  @override
  Future<Result<int>> importM3u(String filePath) async {
    try {
      final lines = await File(filePath).readAsLines();
      final playlistName = p.basenameWithoutExtension(filePath);

      final trackPaths = lines.where((l) => l.isNotEmpty && !l.startsWith('#')).toList();

      final playlistId = await _dao.createPlaylist(playlistName);

      for (final trackPath in trackPaths) {
        final songId = await _dao.getSongIdByPath(trackPath);
        if (songId != null) {
          await _dao.addSongToPlaylist(playlistId, songId);
        }
      }

      return Result.success(playlistId);
    } on FileSystemException catch (e, st) {
      AppLogger.error('importM3u failed', tag: 'PlaylistRepo', error: e, stackTrace: st);
      return Result.failure(AppError.fileSystem(message: e.message));
    } catch (e, st) {
      AppLogger.error('importM3u failed', tag: 'PlaylistRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }
}
