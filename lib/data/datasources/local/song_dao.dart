import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;

import 'database.dart';

part 'song_dao.g.dart';

// ---------------------------------------------------------------------------
// Lightweight result containers for aggregate queries.
// Not domain entities — only used inside this layer.
// ---------------------------------------------------------------------------

/// Aggregated album data produced by [SongDao.getAllAlbums].
final class AlbumRow {
  const AlbumRow({
    required this.name,
    required this.artist,
    this.year,
    this.artCachePath,
    required this.songCount,
    required this.totalDurationMs,
  });

  final String name;
  final String artist;
  final int? year;
  final String? artCachePath;
  final int songCount;
  final int totalDurationMs;
}

/// Aggregated artist data produced by [SongDao.getAllArtists].
final class ArtistRow {
  const ArtistRow({
    required this.name,
    required this.songCount,
    required this.albumCount,
  });

  final String name;
  final int songCount;
  final int albumCount;
}

/// Aggregated genre data produced by [SongDao.getAllGenres].
final class GenreRow {
  const GenreRow({required this.name, required this.songCount});

  final String name;
  final int songCount;
}

/// Aggregated library stats returned by [SongDao.getLibraryStats].
final class LibraryStatsRow {
  const LibraryStatsRow({
    required this.totalSongs,
    required this.totalDurationMs,
    required this.totalAlbums,
    required this.totalArtists,
  });

  final int totalSongs;
  final int totalDurationMs;
  final int totalAlbums;
  final int totalArtists;
}

// ---------------------------------------------------------------------------
// DAO
// ---------------------------------------------------------------------------

@DriftAccessor(tables: [Songs])
class SongDao extends DatabaseAccessor<AppDatabase> with _$SongDaoMixin {
  SongDao(super.db);

  // -------------------------------------------------------------------------
  // Song CRUD
  // -------------------------------------------------------------------------

  Future<List<Song>> getAllSongs({
    String? sortBy,
    bool ascending = true,
  }) {
    final query = select(songs);
    query.orderBy([_songOrder(sortBy, ascending)]);
    return query.get();
  }

  Future<Song?> getSongById(int id) => (select(songs)..where((s) => s.id.equals(id))).getSingleOrNull();

  Future<Song?> getSongByPath(String filePath) => (select(songs)..where((s) => s.filePath.equals(filePath))).getSingleOrNull();

  Future<List<Song>> getSongsByAlbum(
    String album,
    String albumArtist,
  ) =>
      (select(songs)
            ..where(
              (s) => s.album.equals(album) & s.albumArtist.equals(albumArtist),
            )
            ..orderBy([
              (s) => OrderingTerm.asc(s.discNumber),
              (s) => OrderingTerm.asc(s.trackNumber),
              (s) => OrderingTerm.asc(s.title),
            ]))
          .get();

  Future<List<Song>> getSongsByArtist(String artist) => (select(songs)
        ..where((s) => s.artist.equals(artist))
        ..orderBy([
          (s) => OrderingTerm.asc(s.album),
          (s) => OrderingTerm.asc(s.trackNumber),
        ]))
      .get();

  Future<List<Song>> getSongsByGenre(String genre) => (select(songs)
        ..where((s) => s.genre.equals(genre))
        ..orderBy([(s) => OrderingTerm.asc(s.title)]))
      .get();

  /// Returns songs whose [filePath] is directly under [folderPath]
  /// (one directory level — not recursive).
  Future<List<Song>> getSongsByFolder(String folderPath) {
    final escapedPrefix = '${_escapeLike(folderPath)}${_escapeLike(p.separator)}%';
    return customSelect(
      r'''
      SELECT songs.*
      FROM songs
      WHERE file_path LIKE ? ESCAPE '\'
      ORDER BY title ASC
      ''',
      variables: [Variable.withString(escapedPrefix)],
      readsFrom: {songs},
    ).map((row) => songs.map(row.data)).get();
  }

  Future<List<Song>> getFavorites({
    String? sortBy,
    bool ascending = true,
  }) {
    final query = select(songs)..where((s) => s.isFavorite.equals(true));
    query.orderBy([_songOrder(sortBy, ascending)]);
    return query.get();
  }

  Future<List<Song>> getMostPlayed({int limit = 50}) => (select(songs)
        ..where((s) => s.playCount.isBiggerThanValue(0))
        ..orderBy([(s) => OrderingTerm.desc(s.playCount)])
        ..limit(limit))
      .get();

  Future<List<Song>> getRecentlyAdded({int limit = 50}) => (select(songs)
        ..orderBy([(s) => OrderingTerm.desc(s.dateAdded)])
        ..limit(limit))
      .get();

  Future<List<Song>> getRecentlyPlayed({int limit = 100}) => (select(songs)
        ..where((s) => s.lastPlayedAt.isNotNull())
        ..orderBy([(s) => OrderingTerm.desc(s.lastPlayedAt)])
        ..limit(limit))
      .get();

  Future<List<Song>> searchSongs(String query, {int limit = 5}) {
    final escaped = _escapeLike(query);
    final exact = escaped.toLowerCase();
    final starts = '$escaped%';
    final contains = '%$escaped%';
    return customSelect(
      r"""
      SELECT songs.*,
        CASE
          WHEN LOWER(title) = ? THEN 100
          WHEN LOWER(artist) = ? THEN 95
          WHEN LOWER(album) = ? THEN 90
          WHEN title LIKE ? ESCAPE '\' THEN 70
          WHEN artist LIKE ? ESCAPE '\' THEN 65
          WHEN album LIKE ? ESCAPE '\' THEN 60
          WHEN title LIKE ? ESCAPE '\' THEN 40
          WHEN artist LIKE ? ESCAPE '\' THEN 35
          WHEN album LIKE ? ESCAPE '\' THEN 30
          ELSE 10
        END AS relevance
      FROM songs
      WHERE (title LIKE ? ESCAPE '\' OR artist LIKE ? ESCAPE '\' OR album LIKE ? ESCAPE '\')
        AND is_missing = 0
      ORDER BY relevance DESC, title ASC
      LIMIT ?
      """,
      variables: [
        Variable.withString(exact),
        Variable.withString(exact),
        Variable.withString(exact),
        Variable.withString(starts),
        Variable.withString(starts),
        Variable.withString(starts),
        Variable.withString(contains),
        Variable.withString(contains),
        Variable.withString(contains),
        Variable.withString(contains),
        Variable.withString(contains),
        Variable.withString(contains),
        Variable.withInt(limit),
      ],
      readsFrom: {songs},
    ).map((row) => songs.map(row.data)).get();
  }

  Future<int> upsertSong(SongsCompanion companion) => into(songs).insert(
        companion,
        onConflict: DoUpdate(
          (old) => companion,
          target: [songs.filePath],
        ),
      );

  Future<void> updatePlayCount(
    int id,
    int count,
    DateTime lastPlayed,
  ) =>
      (update(songs)..where((s) => s.id.equals(id))).write(
        SongsCompanion(
          playCount: Value(count),
          lastPlayedAt: Value(lastPlayed),
        ),
      );

  Future<void> toggleFavorite(int id, {required bool isFavorite}) => (update(songs)..where((s) => s.id.equals(id))).write(
        SongsCompanion(isFavorite: Value(isFavorite)),
      );

  Future<void> markMissing(int id, {required bool isMissing}) => (update(songs)..where((s) => s.id.equals(id))).write(
        SongsCompanion(isMissing: Value(isMissing)),
      );

  Future<int> deleteSong(int id) => (delete(songs)..where((s) => s.id.equals(id))).go();

  Future<int> clearAllSongs() => delete(songs).go();

  Future<int> getSongCount() async {
    final row = await (selectOnly(songs)..addColumns([songs.id.count()])).getSingle();
    return row.read(songs.id.count()) ?? 0;
  }

  /// Returns all distinct file paths — used by the repository to compute
  /// folder structure in Dart (SQLite has no path functions).
  Future<List<String>> getAllFilePaths() async {
    final rows = await (selectOnly(songs)..addColumns([songs.filePath])).get();
    return rows.map((r) => r.read(songs.filePath)!).toList();
  }

  /// Returns all file paths with their last-modified timestamps — used for
  /// incremental scan delta detection.
  Future<Map<String, DateTime>> getAllFilePathsWithModified() async {
    final rows = await (selectOnly(songs)..addColumns([songs.filePath, songs.fileModifiedAt])).get();
    return {
      for (final row in rows) row.read(songs.filePath)!: row.read(songs.fileModifiedAt)!,
    };
  }

  // -------------------------------------------------------------------------
  // Album aggregates (customSelect for GROUP BY support)
  // -------------------------------------------------------------------------

  Future<List<AlbumRow>> getAllAlbums({
    String? sortBy,
    bool ascending = true,
  }) async {
    final orderClause = _albumOrderClause(sortBy, ascending);
    final rows = await customSelect(
      '''
      SELECT
        album,
        album_artist,
        year,
        MAX(art_cache_path) AS art_cache_path,
        COUNT(*)           AS song_count,
        SUM(duration_ms)   AS total_duration_ms
      FROM songs
      WHERE is_missing = 0
      GROUP BY album, album_artist
      ORDER BY $orderClause
      ''',
      readsFrom: {songs},
    ).get();
    return rows.map(_albumRowFromQuery).toList();
  }

  Future<List<AlbumRow>> searchAlbums(
    String query, {
    int limit = 5,
  }) async {
    final escaped = _escapeLike(query);
    final exact = escaped.toLowerCase();
    final starts = '$escaped%';
    final contains = '%$escaped%';
    final rows = await customSelect(
      r"""
      SELECT
        album,
        album_artist,
        year,
        MAX(art_cache_path) AS art_cache_path,
        COUNT(*)            AS song_count,
        SUM(duration_ms)    AS total_duration_ms,
        CASE
          WHEN LOWER(album) = ? THEN 100
          WHEN album LIKE ? ESCAPE '\' THEN 70
          WHEN album LIKE ? ESCAPE '\' THEN 40
          ELSE 10
        END AS relevance
      FROM songs
      WHERE album LIKE ? ESCAPE '\'
        AND is_missing = 0
      GROUP BY album, album_artist
      ORDER BY relevance DESC, album ASC
      LIMIT ?
      """,
      variables: [
        Variable.withString(exact),
        Variable.withString(starts),
        Variable.withString(contains),
        Variable.withString(contains),
        Variable.withInt(limit),
      ],
      readsFrom: {songs},
    ).get();
    return rows.map(_albumRowFromQuery).toList();
  }

  // -------------------------------------------------------------------------
  // Artist aggregates
  // -------------------------------------------------------------------------

  Future<List<ArtistRow>> getAllArtists({
    String? sortBy,
    bool ascending = true,
  }) async {
    final orderClause = _artistOrderClause(sortBy, ascending);
    final rows = await customSelect(
      '''
      SELECT
        artist,
        COUNT(*)             AS song_count,
        COUNT(DISTINCT album) AS album_count
      FROM songs
      WHERE is_missing = 0
      GROUP BY artist
      ORDER BY $orderClause
      ''',
      readsFrom: {songs},
    ).get();
    return rows.map(_artistRowFromQuery).toList();
  }

  Future<List<ArtistRow>> searchArtists(
    String query, {
    int limit = 5,
  }) async {
    final escaped = _escapeLike(query);
    final exact = escaped.toLowerCase();
    final starts = '$escaped%';
    final contains = '%$escaped%';
    final rows = await customSelect(
      r"""
      SELECT
        artist,
        COUNT(*)             AS song_count,
        COUNT(DISTINCT album) AS album_count,
        CASE
          WHEN LOWER(artist) = ? THEN 100
          WHEN artist LIKE ? ESCAPE '\' THEN 70
          WHEN artist LIKE ? ESCAPE '\' THEN 40
          ELSE 10
        END AS relevance
      FROM songs
      WHERE artist LIKE ? ESCAPE '\'
        AND is_missing = 0
      GROUP BY artist
      ORDER BY relevance DESC, artist ASC
      LIMIT ?
      """,
      variables: [
        Variable.withString(exact),
        Variable.withString(starts),
        Variable.withString(contains),
        Variable.withString(contains),
        Variable.withInt(limit),
      ],
      readsFrom: {songs},
    ).get();
    return rows.map(_artistRowFromQuery).toList();
  }

  // -------------------------------------------------------------------------
  // Genre aggregates
  // -------------------------------------------------------------------------

  Future<List<GenreRow>> getAllGenres({
    String? sortBy,
    bool ascending = true,
  }) async {
    final dir = ascending ? 'ASC' : 'DESC';
    final rows = await customSelect(
      '''
      SELECT
        genre,
        COUNT(*) AS song_count
      FROM songs
      WHERE genre != ''
        AND is_missing = 0
      GROUP BY genre
      ORDER BY genre $dir
      ''',
      readsFrom: {songs},
    ).get();
    return rows.map(_genreRowFromQuery).toList();
  }

  // -------------------------------------------------------------------------
  // Library stats
  // -------------------------------------------------------------------------

  Future<LibraryStatsRow> getLibraryStats() async {
    final rows = await customSelect(
      '''
      SELECT
        COUNT(*)              AS total_songs,
        COALESCE(SUM(duration_ms), 0) AS total_duration_ms,
        COUNT(DISTINCT album) AS total_albums,
        COUNT(DISTINCT artist) AS total_artists
      FROM songs
      WHERE is_missing = 0
      ''',
      readsFrom: {songs},
    ).get();

    final row = rows.first;
    return LibraryStatsRow(
      totalSongs: row.data['total_songs'] as int? ?? 0,
      totalDurationMs: row.data['total_duration_ms'] as int? ?? 0,
      totalAlbums: row.data['total_albums'] as int? ?? 0,
      totalArtists: row.data['total_artists'] as int? ?? 0,
    );
  }

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  OrderClauseGenerator<$SongsTable> _songOrder(
    String? sortBy,
    bool ascending,
  ) {
    return (s) {
      final Expression<Object> term = switch (sortBy) {
        'artist' => s.artist,
        'album' => s.album,
        'dateAdded' => s.dateAdded,
        'year' => s.year as Expression<Object>,
        'duration' => s.durationMs as Expression<Object>,
        'trackNumber' => s.trackNumber as Expression<Object>,
        _ => s.title,
      };
      return ascending ? OrderingTerm.asc(term) : OrderingTerm.desc(term);
    };
  }

  String _albumOrderClause(String? sortBy, bool ascending) {
    final dir = ascending ? 'ASC' : 'DESC';
    return switch (sortBy) {
      'year' => 'year $dir, album $dir',
      'artist' => 'album_artist $dir, album $dir',
      'songCount' => 'song_count $dir, album $dir',
      _ => 'album $dir',
    };
  }

  String _artistOrderClause(String? sortBy, bool ascending) {
    final dir = ascending ? 'ASC' : 'DESC';
    return switch (sortBy) {
      'songCount' => 'song_count $dir, artist $dir',
      'albumCount' => 'album_count $dir, artist $dir',
      _ => 'artist $dir',
    };
  }

  AlbumRow _albumRowFromQuery(QueryRow row) => AlbumRow(
        name: row.data['album'] as String? ?? '',
        artist: row.data['album_artist'] as String? ?? '',
        year: row.data['year'] as int?,
        artCachePath: row.data['art_cache_path'] as String?,
        songCount: row.data['song_count'] as int? ?? 0,
        totalDurationMs: row.data['total_duration_ms'] as int? ?? 0,
      );

  ArtistRow _artistRowFromQuery(QueryRow row) => ArtistRow(
        name: row.data['artist'] as String? ?? '',
        songCount: row.data['song_count'] as int? ?? 0,
        albumCount: row.data['album_count'] as int? ?? 0,
      );

  GenreRow _genreRowFromQuery(QueryRow row) => GenreRow(
        name: row.data['genre'] as String? ?? '',
        songCount: row.data['song_count'] as int? ?? 0,
      );

  /// Escapes LIKE wildcards in user-supplied strings to prevent injection.
  String _escapeLike(String input) => input.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_');
}
