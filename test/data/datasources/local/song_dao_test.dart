import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_fse/data/datasources/local/database.dart';
import 'package:music_fse/data/datasources/local/song_dao.dart';

void main() {
  late AppDatabase db;
  late SongDao dao;

  SongsCompanion makeSong({
    required String filePath,
    String title = 'Song',
    String artist = 'Artist',
    String album = 'Album',
    String albumArtist = 'Artist',
    String genre = 'Rock',
    int durationMs = 180000,
    int fileSize = 5000000,
    bool isFavorite = false,
    int playCount = 0,
  }) =>
      SongsCompanion.insert(
        filePath: filePath,
        title: title,
        fileModifiedAt: DateTime(2024),
        artist: Value(artist),
        album: Value(album),
        albumArtist: Value(albumArtist),
        genre: Value(genre),
        durationMs: Value(durationMs),
        fileSize: Value(fileSize),
        isFavorite: Value(isFavorite),
        playCount: Value(playCount),
      );

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = SongDao(db);
  });

  tearDown(() => db.close());

  group('CRUD', () {
    test('upsertSong inserts and returns id', () async {
      final id = await dao.upsertSong(makeSong(filePath: '/a.mp3'));
      expect(id, greaterThan(0));
    });

    test('getSongById returns inserted song', () async {
      final id = await dao.upsertSong(makeSong(filePath: '/b.mp3', title: 'Hello'));
      final song = await dao.getSongById(id);
      expect(song, isNotNull);
      expect(song!.title, 'Hello');
    });

    test('getSongById returns null for missing id', () async {
      expect(await dao.getSongById(999), isNull);
    });

    test('getSongByPath returns correct song', () async {
      await dao.upsertSong(makeSong(filePath: '/c.mp3', title: 'C'));
      final song = await dao.getSongByPath('/c.mp3');
      expect(song, isNotNull);
      expect(song!.title, 'C');
    });

    test('upsertSong updates on conflict', () async {
      final id = await dao.upsertSong(makeSong(filePath: '/d.mp3', title: 'V1'));
      // Re-insert with same id to trigger ON CONFLICT(id) UPDATE
      await dao.upsertSong(SongsCompanion(
        id: Value(id),
        filePath: const Value('/d.mp3'),
        title: const Value('V2'),
        artist: const Value('Artist'),
        album: const Value('Album'),
        albumArtist: const Value('Artist'),
        genre: const Value('Rock'),
        durationMs: const Value(180000),
        fileSize: const Value(5000000),
        fileModifiedAt: Value(DateTime(2024)),
        playCount: const Value(0),
        isFavorite: const Value(false),
      ));
      final song = await dao.getSongByPath('/d.mp3');
      expect(song!.title, 'V2');
    });
  });

  group('getAllSongs', () {
    test('returns all songs sorted by title', () async {
      await dao.upsertSong(makeSong(filePath: '/z.mp3', title: 'Zebra'));
      await dao.upsertSong(makeSong(filePath: '/a.mp3', title: 'Apple'));
      final songs = await dao.getAllSongs(sortBy: 'title', ascending: true);
      expect(songs.length, 2);
      expect(songs.first.title, 'Apple');
    });

    test('returns songs descending', () async {
      await dao.upsertSong(makeSong(filePath: '/a.mp3', title: 'A'));
      await dao.upsertSong(makeSong(filePath: '/b.mp3', title: 'B'));
      final songs = await dao.getAllSongs(sortBy: 'title', ascending: false);
      expect(songs.first.title, 'B');
    });
  });

  group('favorites', () {
    test('getFavorites returns only favorites', () async {
      await dao.upsertSong(makeSong(filePath: '/a.mp3', isFavorite: true));
      await dao.upsertSong(makeSong(filePath: '/b.mp3', isFavorite: false));
      final favs = await dao.getFavorites();
      expect(favs.length, 1);
    });

    test('toggleFavorite updates flag', () async {
      final id = await dao.upsertSong(makeSong(filePath: '/a.mp3', isFavorite: false));
      await dao.toggleFavorite(id, isFavorite: true);
      final song = await dao.getSongById(id);
      expect(song!.isFavorite, true);
    });
  });

  group('search', () {
    test('searchSongs returns ranked results', () async {
      await dao.upsertSong(makeSong(filePath: '/1.mp3', title: 'Hello World'));
      await dao.upsertSong(makeSong(filePath: '/2.mp3', title: 'Goodbye'));
      final results = await dao.searchSongs('Hello');
      expect(results.length, 1);
      expect(results.first.title, 'Hello World');
    });

    test('searchSongs returns empty for no matches', () async {
      await dao.upsertSong(makeSong(filePath: '/1.mp3', title: 'A'));
      final results = await dao.searchSongs('zzz');
      expect(results, isEmpty);
    });

    test('searchSongs matches artist', () async {
      await dao.upsertSong(makeSong(filePath: '/1.mp3', title: 'X', artist: 'John'));
      final results = await dao.searchSongs('John');
      expect(results.length, 1);
    });

    test('searchSongs respects limit', () async {
      for (var i = 0; i < 10; i++) {
        await dao.upsertSong(makeSong(filePath: '/$i.mp3', title: 'Song $i'));
      }
      final results = await dao.searchSongs('Song', limit: 3);
      expect(results.length, 3);
    });
  });

  group('play tracking', () {
    test('getMostPlayed returns songs ordered by play count', () async {
      final id1 = await dao.upsertSong(makeSong(filePath: '/a.mp3', playCount: 10));
      await dao.upsertSong(makeSong(filePath: '/b.mp3', playCount: 5));
      await dao.upsertSong(makeSong(filePath: '/c.mp3', playCount: 0));
      final top = await dao.getMostPlayed(limit: 2);
      expect(top.length, 2);
      expect(top.first.id, id1);
    });

    test('getRecentlyAdded returns newest first', () async {
      await dao.upsertSong(makeSong(filePath: '/old.mp3'));
      // Insert second song — its dateAdded will be slightly later
      await dao.upsertSong(makeSong(filePath: '/new.mp3'));
      final recent = await dao.getRecentlyAdded(limit: 1);
      expect(recent.length, 1);
    });
  });

  group('missing', () {
    test('markMissing sets flag', () async {
      final id = await dao.upsertSong(makeSong(filePath: '/a.mp3'));
      await dao.markMissing(id, isMissing: true);
      final song = await dao.getSongById(id);
      expect(song!.isMissing, true);
    });

    test('markMissing unsets flag', () async {
      final id = await dao.upsertSong(makeSong(filePath: '/a.mp3'));
      await dao.markMissing(id, isMissing: true);
      await dao.markMissing(id, isMissing: false);
      final song = await dao.getSongById(id);
      expect(song!.isMissing, false);
    });
  });

  group('deleteSong', () {
    test('removes song from database', () async {
      final id = await dao.upsertSong(makeSong(filePath: '/a.mp3'));
      await dao.deleteSong(id);
      expect(await dao.getSongById(id), isNull);
    });
  });

  group('aggregate queries', () {
    test('getSongCount returns total', () async {
      await dao.upsertSong(makeSong(filePath: '/a.mp3'));
      await dao.upsertSong(makeSong(filePath: '/b.mp3'));
      expect(await dao.getSongCount(), 2);
    });

    test('getLibraryStats returns correct counts', () async {
      await dao.upsertSong(
        makeSong(filePath: '/a.mp3', artist: 'A', album: 'X', durationMs: 1000),
      );
      await dao.upsertSong(
        makeSong(filePath: '/b.mp3', artist: 'B', album: 'Y', durationMs: 2000),
      );
      final stats = await dao.getLibraryStats();
      expect(stats.totalSongs, 2);
      expect(stats.totalDurationMs, 3000);
      expect(stats.totalArtists, 2);
      expect(stats.totalAlbums, 2);
    });
  });
}
