import 'package:music_fse/domain/entities/song.dart';
import 'package:music_fse/domain/entities/playlist.dart';
import 'package:music_fse/domain/entities/queue_item.dart';
import 'package:music_fse/domain/entities/play_history_entry.dart';

/// Factory helpers for creating test entities.
final class TestSongs {
  TestSongs._();

  static Song song({
    int id = 1,
    String filePath = '/music/test.mp3',
    String title = 'Test Song',
    String artist = 'Test Artist',
    String album = 'Test Album',
    String albumArtist = 'Test Artist',
    String genre = 'Rock',
    int? year = 2024,
    int? trackNumber = 1,
    int? discNumber,
    int durationMs = 180000,
    int fileSize = 5000000,
    DateTime? fileModifiedAt,
    String? artCachePath,
    DateTime? dateAdded,
    int playCount = 0,
    DateTime? lastPlayedAt,
    bool isFavorite = false,
    bool isMissing = false,
  }) =>
      Song(
        id: id,
        filePath: filePath,
        title: title,
        artist: artist,
        album: album,
        albumArtist: albumArtist,
        genre: genre,
        year: year,
        trackNumber: trackNumber,
        discNumber: discNumber,
        durationMs: durationMs,
        fileSize: fileSize,
        fileModifiedAt: fileModifiedAt ?? DateTime(2024, 1, 1),
        artCachePath: artCachePath,
        dateAdded: dateAdded ?? DateTime(2024, 1, 1),
        playCount: playCount,
        lastPlayedAt: lastPlayedAt,
        isFavorite: isFavorite,
        isMissing: isMissing,
      );

  static List<Song> songs(int count) => List.generate(
        count,
        (i) => song(id: i + 1, title: 'Song ${i + 1}'),
      );

  static Playlist playlist({
    int id = 1,
    String name = 'Test Playlist',
    DateTime? createdAt,
    DateTime? updatedAt,
    int songCount = 0,
    int totalDurationMs = 0,
  }) =>
      Playlist(
        id: id,
        name: name,
        createdAt: createdAt ?? DateTime(2024, 1, 1),
        updatedAt: updatedAt ?? DateTime(2024, 1, 1),
        songCount: songCount,
        totalDurationMs: totalDurationMs,
      );

  static QueueItem queueItem({
    Song? song,
    int sortOrder = 0,
    bool isCurrent = false,
    int positionMs = 0,
  }) =>
      QueueItem(
        song: song ?? TestSongs.song(),
        sortOrder: sortOrder,
        isCurrent: isCurrent,
        positionMs: positionMs,
      );

  static PlayHistoryEntry historyEntry({
    int id = 0,
    int songId = 1,
    DateTime? playedAt,
    int durationListenedMs = 60000,
    int sessionId = 1,
  }) =>
      PlayHistoryEntry(
        id: id,
        songId: songId,
        playedAt: playedAt ?? DateTime(2024, 1, 1),
        durationListenedMs: durationListenedMs,
        sessionId: sessionId,
      );
}
