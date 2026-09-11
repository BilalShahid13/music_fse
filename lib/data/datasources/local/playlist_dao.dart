import 'package:drift/drift.dart';

import 'database.dart';

part 'playlist_dao.g.dart';

/// Provides a lightweight container for the aggregated playlist data returned
/// by [PlaylistDao.getAllPlaylists] and [PlaylistDao.getPlaylistById].
final class PlaylistRow {
  const PlaylistRow({
    required this.playlist,
    required this.songCount,
    required this.totalDurationMs,
  });

  final Playlist playlist;
  final int songCount;
  final int totalDurationMs;
}

@DriftAccessor(tables: [Playlists, PlaylistSongs, Songs])
class PlaylistDao extends DatabaseAccessor<AppDatabase>
    with _$PlaylistDaoMixin {
  PlaylistDao(super.db);

  // -------------------------------------------------------------------------
  // Playlists
  // -------------------------------------------------------------------------

  Future<List<PlaylistRow>> getAllPlaylists({String? sortBy}) async {
    final orderClause = _playlistOrderClause(sortBy);
    final rows = await customSelect(
      '''
      SELECT
        p.id,
        p.name,
        p.cover_art_path,
        p.created_at,
        p.updated_at,
        p.is_smart,
        p.smart_rule,
        COUNT(ps.song_id)            AS song_count,
        COALESCE(SUM(s.duration_ms), 0) AS total_duration_ms
      FROM playlists p
      LEFT JOIN playlist_songs ps ON ps.playlist_id = p.id
      LEFT JOIN songs s          ON s.id = ps.song_id
      GROUP BY p.id
      ORDER BY $orderClause
      ''',
      readsFrom: {playlists, playlistSongs, songs},
    ).get();
    return rows.map(_playlistRowFromQuery).toList();
  }

  Future<PlaylistRow?> getPlaylistById(int id) async {
    final rows = await customSelect(
      '''
      SELECT
        p.id,
        p.name,
        p.cover_art_path,
        p.created_at,
        p.updated_at,
        p.is_smart,
        p.smart_rule,
        COUNT(ps.song_id)               AS song_count,
        COALESCE(SUM(s.duration_ms), 0) AS total_duration_ms
      FROM playlists p
      LEFT JOIN playlist_songs ps ON ps.playlist_id = p.id
      LEFT JOIN songs s           ON s.id = ps.song_id
      WHERE p.id = ?
      GROUP BY p.id
      ''',
      variables: [Variable.withInt(id)],
      readsFrom: {playlists, playlistSongs, songs},
    ).get();
    if (rows.isEmpty) return null;
    return _playlistRowFromQuery(rows.first);
  }

  Future<List<Song>> getPlaylistSongs(int playlistId) {
    final query = select(songs).join([
      innerJoin(
        playlistSongs,
        playlistSongs.songId.equalsExp(songs.id),
      ),
    ])
      ..where(playlistSongs.playlistId.equals(playlistId))
      ..orderBy([OrderingTerm.asc(playlistSongs.sortOrder)]);
    return query.map((row) => row.readTable(songs)).get();
  }

  Future<int> createPlaylist(String name) =>
      into(playlists).insertReturning(
        PlaylistsCompanion.insert(name: name),
      ).then((row) => row.id);

  Future<void> renamePlaylist(int id, String name) =>
      (update(playlists)..where((p) => p.id.equals(id))).write(
        PlaylistsCompanion(
          name: Value(name),
          updatedAt: Value(DateTime.now()),
        ),
      );

  /// Deletes the playlist and all its [PlaylistSongs] entries.
  Future<void> deletePlaylist(int id) => transaction(() async {
        await (delete(playlistSongs)
              ..where((ps) => ps.playlistId.equals(id)))
            .go();
        await (delete(playlists)..where((p) => p.id.equals(id))).go();
      });

  Future<void> clearAllPlaylists() => transaction(() async {
        await delete(playlistSongs).go();
        await delete(playlists).go();
      });

  /// Creates a copy of [id] with " (Copy)" appended to the name, preserving
  /// all songs in the same order.
  Future<int> duplicatePlaylist(int id) => transaction(() async {
        final source =
            await (select(playlists)..where((p) => p.id.equals(id)))
                .getSingleOrNull();
        if (source == null) return -1;

        final newId = await into(playlists).insertReturning(
          PlaylistsCompanion.insert(name: '${source.name} (Copy)'),
        ).then((r) => r.id);

        final sourceSongs = await (select(playlistSongs)
              ..where((ps) => ps.playlistId.equals(id))
              ..orderBy([(ps) => OrderingTerm.asc(ps.sortOrder)]))
            .get();

        final companions = sourceSongs.map((ps) {
          return PlaylistSongsCompanion.insert(
            playlistId: newId,
            songId: ps.songId,
            sortOrder: ps.sortOrder,
          );
        }).toList();

        await batch((b) => b.insertAll(playlistSongs, companions));
        return newId;
      });

  /// Appends [songId] to [playlistId] with a sort order after all existing
  /// songs. Silently does nothing if the song is already in the playlist.
  Future<void> addSongToPlaylist(int playlistId, int songId) =>
      transaction(() async {
        // Determine next sort order.
        final maxRow = await customSelect(
          'SELECT COALESCE(MAX(sort_order), -1) AS m FROM playlist_songs WHERE playlist_id = ?',
          variables: [Variable.withInt(playlistId)],
          readsFrom: {playlistSongs},
        ).getSingle();
        final nextOrder = (maxRow.data['m'] as int? ?? -1) + 1;

        await into(playlistSongs).insertOnConflictUpdate(
          PlaylistSongsCompanion.insert(
            playlistId: playlistId,
            songId: songId,
            sortOrder: nextOrder,
          ),
        );
        await _touchPlaylist(playlistId);
      });

  Future<void> removeSongFromPlaylist(int playlistId, int songId) =>
      transaction(() async {
        await (delete(playlistSongs)
              ..where(
                (ps) =>
                    ps.playlistId.equals(playlistId) &
                    ps.songId.equals(songId),
              ))
            .go();
        // Re-index sort_order to close the gap.
        await _reindexSortOrder(playlistId);
        await _touchPlaylist(playlistId);
      });

  /// Moves the song at [oldIndex] to [newIndex] within [playlistId].
  Future<void> reorderPlaylistSong(
    int playlistId,
    int oldIndex,
    int newIndex,
  ) =>
      transaction(() async {
        if (oldIndex == newIndex) return;

        final rows = await (select(playlistSongs)
              ..where((ps) => ps.playlistId.equals(playlistId))
              ..orderBy([(ps) => OrderingTerm.asc(ps.sortOrder)]))
            .get();

        if (oldIndex < 0 ||
            oldIndex >= rows.length ||
            newIndex < 0 ||
            newIndex >= rows.length) {
          return;
        }

        final moved = rows[oldIndex];
        final reordered = List<PlaylistSong>.from(rows)
          ..removeAt(oldIndex)
          ..insert(newIndex, moved);

        for (var i = 0; i < reordered.length; i++) {
          await (update(playlistSongs)
                ..where(
                  (ps) =>
                      ps.playlistId.equals(playlistId) &
                      ps.songId.equals(reordered[i].songId),
                ))
              .write(PlaylistSongsCompanion(sortOrder: Value(i)));
        }

        await _touchPlaylist(playlistId);
      });

  /// Returns the database ID of a song with the given [path], or null.
  /// Used during M3U import to resolve file paths to song IDs.
  Future<int?> getSongIdByPath(String path) async {
    final row = await (select(songs)..where((s) => s.filePath.equals(path)))
        .getSingleOrNull();
    return row?.id;
  }

  Future<void> updateCoverArt(int playlistId, String? artPath) =>
      (update(playlists)..where((p) => p.id.equals(playlistId))).write(
        PlaylistsCompanion(
          coverArtPath: Value(artPath),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<List<PlaylistRow>> searchPlaylists(
    String query, {
    int limit = 5,
  }) async {
    final q = '%${query.replaceAll('%', r'\%').replaceAll('_', r'\_')}%';
    final rows = await customSelect(
      '''
      SELECT
        p.id,
        p.name,
        p.cover_art_path,
        p.created_at,
        p.updated_at,
        p.is_smart,
        p.smart_rule,
        COUNT(ps.song_id)               AS song_count,
        COALESCE(SUM(s.duration_ms), 0) AS total_duration_ms
      FROM playlists p
      LEFT JOIN playlist_songs ps ON ps.playlist_id = p.id
      LEFT JOIN songs s           ON s.id = ps.song_id
      WHERE p.name LIKE ? ESCAPE '\\'
      GROUP BY p.id
      LIMIT $limit
      ''',
      variables: [Variable.withString(q)],
      readsFrom: {playlists, playlistSongs, songs},
    ).get();
    return rows.map(_playlistRowFromQuery).toList();
  }

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  String _playlistOrderClause(String? sortBy) => switch (sortBy) {
        'updatedAt' => 'p.updated_at DESC',
        'createdAt' => 'p.created_at DESC',
        'songCount' => 'song_count DESC, p.name ASC',
        _ => 'p.name ASC',
      };

  /// Updates [updatedAt] on a playlist after any mutation.
  Future<void> _touchPlaylist(int playlistId) =>
      (update(playlists)..where((p) => p.id.equals(playlistId))).write(
        PlaylistsCompanion(updatedAt: Value(DateTime.now())),
      );

  /// Re-numbers sort_order values to be contiguous starting from 0.
  Future<void> _reindexSortOrder(int playlistId) async {
    final rows = await (select(playlistSongs)
          ..where((ps) => ps.playlistId.equals(playlistId))
          ..orderBy([(ps) => OrderingTerm.asc(ps.sortOrder)]))
        .get();

    for (var i = 0; i < rows.length; i++) {
      if (rows[i].sortOrder != i) {
        await (update(playlistSongs)
              ..where(
                (ps) =>
                    ps.playlistId.equals(playlistId) &
                    ps.songId.equals(rows[i].songId),
              ))
            .write(PlaylistSongsCompanion(sortOrder: Value(i)));
      }
    }
  }

  PlaylistRow _playlistRowFromQuery(QueryRow row) {
    final data = row.data;
    return PlaylistRow(
      playlist: Playlist(
        id: data['id'] as int,
        name: data['name'] as String,
        coverArtPath: data['cover_art_path'] as String?,
        createdAt: _parseDateTime(data['created_at']),
        updatedAt: _parseDateTime(data['updated_at']),
        isSmart: (data['is_smart'] as int? ?? 0) == 1,
        smartRule: data['smart_rule'] as String?,
      ),
      songCount: data['song_count'] as int? ?? 0,
      totalDurationMs: data['total_duration_ms'] as int? ?? 0,
    );
  }

  DateTime _parseDateTime(Object? value) {
    if (value == null) return DateTime.now();
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value * 1000);
    }
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
