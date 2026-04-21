import 'dart:convert';

import 'package:drift/drift.dart';

import 'eq_preset_dao.dart';
import 'play_history_dao.dart';
import 'playback_dao.dart';
import 'playlist_dao.dart';
import 'queue_dao.dart';
import 'recommendations_dao.dart';
import 'scan_folder_dao.dart';
import 'settings_dao.dart';
import 'song_dao.dart';

part 'database.g.dart';

// ---------------------------------------------------------------------------
// Table definitions
// ---------------------------------------------------------------------------

class Songs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get filePath => text().unique()();
  TextColumn get title => text()();
  TextColumn get artist => text().withDefault(const Constant('Unknown Artist'))();
  TextColumn get album => text().withDefault(const Constant('Unknown Album'))();
  TextColumn get albumArtist => text().withDefault(const Constant(''))();
  TextColumn get genre => text().withDefault(const Constant(''))();
  IntColumn get year => integer().nullable()();
  IntColumn get trackNumber => integer().nullable()();
  IntColumn get discNumber => integer().nullable()();
  IntColumn get durationMs => integer().withDefault(const Constant(0))();
  IntColumn get fileSize => integer().withDefault(const Constant(0))();
  DateTimeColumn get fileModifiedAt => dateTime()();
  TextColumn get artCachePath => text().nullable()();
  DateTimeColumn get dateAdded => dateTime().withDefault(currentDateAndTime)();
  IntColumn get playCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastPlayedAt => dateTime().nullable()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  BoolColumn get isMissing => boolean().withDefault(const Constant(false))();
}

class Playlists extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get coverArtPath => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isSmart => boolean().withDefault(const Constant(false))();
  TextColumn get smartRule => text().nullable()();
}

class PlaylistSongs extends Table {
  IntColumn get playlistId => integer().references(Playlists, #id)();
  IntColumn get songId => integer().references(Songs, #id)();
  IntColumn get sortOrder => integer()();
  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {playlistId, songId};
}

class PlayHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get songId => integer().references(Songs, #id)();
  DateTimeColumn get playedAt => dateTime()();
  IntColumn get durationListenedMs => integer()();

  /// Numeric session identifier — each app launch produces a new value.
  IntColumn get sessionId => integer()();
}

class QueueItems extends Table {
  /// Auto-increment PK so the same song can appear multiple times.
  IntColumn get id => integer().autoIncrement()();
  IntColumn get songId => integer().references(Songs, #id)();
  IntColumn get sortOrder => integer()();
  BoolColumn get isCurrent => boolean().withDefault(const Constant(false))();
  IntColumn get positionMs => integer().withDefault(const Constant(0))();
}

class PlaybackStates extends Table {
  /// Always 1 — singleton row.
  IntColumn get id => integer().withDefault(const Constant(1))();
  BoolColumn get shuffle => boolean().withDefault(const Constant(false))();
  TextColumn get repeatMode => text().withDefault(const Constant('off'))();

  /// Master volume 0.0–1.0. Default 0.7 per REQUIREMENTS §7.1.
  RealColumn get volume => real().withDefault(const Constant(0.7))();
  IntColumn get crossfadeSeconds => integer().withDefault(const Constant(0))();
  BoolColumn get eqEnabled => boolean().withDefault(const Constant(false))();
  IntColumn get eqPresetId => integer().nullable().references(EqPresets, #id)();
  TextColumn get queueSourceType => text().nullable()();
  IntColumn get queueSourceId => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class EqPresets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  BoolColumn get isBuiltin => boolean().withDefault(const Constant(false))();

  /// JSON-encoded List<double> of 10 band gains in dB.
  TextColumn get bandsJson => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

class Recommendations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get category => text()();
  IntColumn get songId => integer().references(Songs, #id)();
  RealColumn get score => real()();
  DateTimeColumn get generatedAt => dateTime()();
}

class ScanFolders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get path => text().unique()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastScannedAt => dateTime().nullable()();
}

// ---------------------------------------------------------------------------
// Database class
// ---------------------------------------------------------------------------

@DriftDatabase(
  tables: [
    Songs,
    Playlists,
    PlaylistSongs,
    PlayHistory,
    QueueItems,
    PlaybackStates,
    EqPresets,
    Settings,
    Recommendations,
    ScanFolders,
  ],
  daos: [
    SongDao,
    PlaylistDao,
    PlaybackDao,
    QueueDao,
    PlayHistoryDao,
    SettingsDao,
    ScanFolderDao,
    EqPresetDao,
    RecommendationsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedBuiltinEqPresets();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // Songs indexes
            await m.createIndex(Index('idx_songs_artist', 'CREATE INDEX idx_songs_artist ON songs (artist)'));
            await m.createIndex(Index('idx_songs_album', 'CREATE INDEX idx_songs_album ON songs (album)'));
            await m.createIndex(Index('idx_songs_genre', 'CREATE INDEX idx_songs_genre ON songs (genre)'));
            await m.createIndex(Index('idx_songs_date_added', 'CREATE INDEX idx_songs_date_added ON songs (date_added)'));
            await m.createIndex(Index('idx_songs_play_count', 'CREATE INDEX idx_songs_play_count ON songs (play_count)'));
            await m.createIndex(Index('idx_songs_last_played_at', 'CREATE INDEX idx_songs_last_played_at ON songs (last_played_at)'));
            await m.createIndex(Index('idx_songs_is_favorite', 'CREATE INDEX idx_songs_is_favorite ON songs (is_favorite)'));
            await m.createIndex(Index('idx_songs_title_artist_album', 'CREATE INDEX idx_songs_title_artist_album ON songs (title, artist, album)'));

            // PlayHistory indexes
            await m.createIndex(Index('idx_play_history_played_at', 'CREATE INDEX idx_play_history_played_at ON play_history (played_at)'));
            await m.createIndex(Index('idx_play_history_song_id', 'CREATE INDEX idx_play_history_song_id ON play_history (song_id)'));

            // PlaylistSongs indexes
            await m
                .createIndex(Index('idx_playlist_songs_playlist_id', 'CREATE INDEX idx_playlist_songs_playlist_id ON playlist_songs (playlist_id)'));

            // QueueItems indexes
            await m.createIndex(Index('idx_queue_items_sort_order', 'CREATE INDEX idx_queue_items_sort_order ON queue_items (sort_order)'));
          }
          if (from < 3) {
            // Seed built-in EQ presets for existing databases.
            await _seedBuiltinEqPresets();
          }
        },
      );

  // ── Built-in EQ preset seeds ─────────────────────────────────────────────
  //
  // 10 bands: 60 Hz, 170 Hz, 310 Hz, 600 Hz, 1 kHz, 3 kHz, 6 kHz, 12 kHz,
  //           14 kHz, 16 kHz.  Gain values in dB.
  static const _builtinPresets = <String, List<double>>{
    'Flat': [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    'Rock': [4.0, 3.0, 1.0, -0.5, -1.0, 1.0, 3.0, 4.0, 4.0, 3.5],
    'Pop': [-1.5, 1.0, 3.0, 4.0, 3.0, 0.0, -1.0, -1.5, -1.5, -1.5],
    'Jazz': [3.0, 2.0, 0.5, 1.5, -1.0, -1.0, 0.5, 2.0, 3.0, 3.0],
    'Classical': [4.0, 3.0, 2.0, 1.0, -1.0, -1.0, 0.0, 2.0, 3.0, 4.0],
    'Hip-Hop': [5.0, 4.0, 1.0, 3.0, -1.0, -1.0, 2.0, 0.0, 2.0, 3.0],
    'Electronic': [4.0, 3.5, 1.0, 0.0, -1.5, 1.0, 0.0, 2.0, 4.0, 5.0],
    'R&B': [3.0, 5.0, 2.0, -1.0, -1.0, 1.0, 2.0, 3.0, 2.0, 2.0],
    'Bass Boost': [6.0, 5.0, 4.0, 2.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    'Treble Boost': [0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 2.0, 4.0, 5.0, 6.0],
    'Vocal': [-2.0, -1.0, 0.0, 3.0, 4.0, 4.0, 3.0, 1.0, 0.0, -2.0],
    'Acoustic': [3.0, 2.5, 1.0, 0.5, 0.0, 0.5, 1.5, 2.5, 3.0, 3.0],
  };

  Future<void> _seedBuiltinEqPresets() async {
    // Skip if builtins already exist (idempotent).
    final existing = await (select(eqPresets)
          ..where((p) => p.isBuiltin.equals(true))
          ..limit(1))
        .get();
    if (existing.isNotEmpty) return;

    for (final entry in _builtinPresets.entries) {
      await into(eqPresets).insert(
        EqPresetsCompanion.insert(
          name: entry.key,
          bandsJson: jsonEncode(entry.value),
        ).copyWith(isBuiltin: const Value(true)),
      );
    }
  }
}
