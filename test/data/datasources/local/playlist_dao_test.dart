import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_fse/data/datasources/local/database.dart';
import 'package:music_fse/data/datasources/local/playlist_dao.dart';
import 'package:music_fse/data/datasources/local/song_dao.dart';

void main() {
  late AppDatabase db;
  late PlaylistDao playlistDao;
  late SongDao songDao;

  Future<int> insertSong(String path) => songDao.upsertSong(
        SongsCompanion.insert(
          filePath: path,
          title: 'Song $path',
          fileModifiedAt: DateTime(2024),
        ),
      );

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    playlistDao = PlaylistDao(db);
    songDao = SongDao(db);
  });

  tearDown(() => db.close());

  group('createPlaylist', () {
    test('returns new id', () async {
      final id = await playlistDao.createPlaylist('My Playlist');
      expect(id, greaterThan(0));
    });
  });

  group('getAllPlaylists', () {
    test('returns all playlists', () async {
      await playlistDao.createPlaylist('A');
      await playlistDao.createPlaylist('B');
      final all = await playlistDao.getAllPlaylists();
      expect(all.length, 2);
    });

    test('includes song count', () async {
      final pid = await playlistDao.createPlaylist('P');
      final sid = await insertSong('/a.mp3');
      await playlistDao.addSongToPlaylist(pid, sid);

      final all = await playlistDao.getAllPlaylists();
      expect(all.first.songCount, 1);
    });
  });

  group('renamePlaylist', () {
    test('updates name', () async {
      final id = await playlistDao.createPlaylist('Old');
      await playlistDao.renamePlaylist(id, 'New');
      final row = await playlistDao.getPlaylistById(id);
      expect(row!.playlist.name, 'New');
    });
  });

  group('deletePlaylist', () {
    test('removes playlist and its songs', () async {
      final pid = await playlistDao.createPlaylist('P');
      final sid = await insertSong('/a.mp3');
      await playlistDao.addSongToPlaylist(pid, sid);
      await playlistDao.deletePlaylist(pid);

      expect(await playlistDao.getPlaylistById(pid), isNull);
    });
  });

  group('addSongToPlaylist', () {
    test('appends song at end', () async {
      final pid = await playlistDao.createPlaylist('P');
      final s1 = await insertSong('/1.mp3');
      final s2 = await insertSong('/2.mp3');
      await playlistDao.addSongToPlaylist(pid, s1);
      await playlistDao.addSongToPlaylist(pid, s2);

      final songs = await playlistDao.getPlaylistSongs(pid);
      expect(songs.length, 2);
      expect(songs.first.id, s1);
      expect(songs.last.id, s2);
    });
  });

  group('removeSongFromPlaylist', () {
    test('removes and re-indexes sort order', () async {
      final pid = await playlistDao.createPlaylist('P');
      final s1 = await insertSong('/1.mp3');
      final s2 = await insertSong('/2.mp3');
      await playlistDao.addSongToPlaylist(pid, s1);
      await playlistDao.addSongToPlaylist(pid, s2);
      await playlistDao.removeSongFromPlaylist(pid, s1);

      final songs = await playlistDao.getPlaylistSongs(pid);
      expect(songs.length, 1);
      expect(songs.first.id, s2);
    });
  });

  group('duplicatePlaylist', () {
    test('copies playlist with songs', () async {
      final pid = await playlistDao.createPlaylist('Original');
      final s1 = await insertSong('/1.mp3');
      await playlistDao.addSongToPlaylist(pid, s1);

      final newId = await playlistDao.duplicatePlaylist(pid);

      expect(newId, greaterThan(0));
      final row = await playlistDao.getPlaylistById(newId);
      expect(row!.playlist.name, 'Original (Copy)');
      final songs = await playlistDao.getPlaylistSongs(newId);
      expect(songs.length, 1);
    });
  });

  group('reorderPlaylistSong', () {
    test('moves song from position 0 to position 2', () async {
      final pid = await playlistDao.createPlaylist('P');
      final s1 = await insertSong('/1.mp3');
      final s2 = await insertSong('/2.mp3');
      final s3 = await insertSong('/3.mp3');
      await playlistDao.addSongToPlaylist(pid, s1);
      await playlistDao.addSongToPlaylist(pid, s2);
      await playlistDao.addSongToPlaylist(pid, s3);

      await playlistDao.reorderPlaylistSong(pid, 0, 2);

      final songs = await playlistDao.getPlaylistSongs(pid);
      expect(songs[0].id, s2);
      expect(songs[1].id, s3);
      expect(songs[2].id, s1);
    });
  });

  group('searchPlaylists', () {
    test('finds matching playlists', () async {
      await playlistDao.createPlaylist('Favorites Mix');
      await playlistDao.createPlaylist('Workout');
      final results = await playlistDao.searchPlaylists('fav');
      expect(results.length, 1);
      expect(results.first.playlist.name, 'Favorites Mix');
    });
  });
}
