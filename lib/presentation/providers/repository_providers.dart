import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/eq_preset_repository_impl.dart';
import '../../data/repositories/play_history_repository_impl.dart';
import '../../data/repositories/playback_repository_impl.dart';
import '../../data/repositories/playlist_repository_impl.dart';
import '../../data/repositories/recommendations_repository_impl.dart';
import '../../data/repositories/scan_folder_repository_impl.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../data/repositories/song_repository_impl.dart';
import '../../domain/repositories/eq_preset_repository.dart';
import '../../domain/repositories/play_history_repository.dart';
import '../../domain/repositories/playback_repository.dart';
import '../../domain/repositories/playlist_repository.dart';
import '../../domain/repositories/recommendations_repository.dart';
import '../../domain/repositories/scan_folder_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/repositories/song_repository.dart';
import 'database_provider.dart';

part 'repository_providers.g.dart';

// ---------------------------------------------------------------------------
// Song / Album / Artist / Genre / Folder — all served by SongRepositoryImpl
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
SongRepository songRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  return SongRepositoryImpl(db.songDao);
}

// ---------------------------------------------------------------------------
// Playlist
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
PlaylistRepository playlistRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  return PlaylistRepositoryImpl(db.playlistDao);
}

// ---------------------------------------------------------------------------
// Playback (queue + state persistence)
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
PlaybackRepository playbackRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  return PlaybackRepositoryImpl(db.playbackDao, db.queueDao);
}

// ---------------------------------------------------------------------------
// Play History
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
PlayHistoryRepository playHistoryRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  return PlayHistoryRepositoryImpl(db.playHistoryDao);
}

// ---------------------------------------------------------------------------
// Settings (key-value store)
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  return SettingsRepositoryImpl(db.settingsDao);
}

// ---------------------------------------------------------------------------
// Scan Folders
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
ScanFolderRepository scanFolderRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  return ScanFolderRepositoryImpl(db.scanFolderDao);
}

// ---------------------------------------------------------------------------
// EQ Presets
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
EqPresetRepository eqPresetRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  return EqPresetRepositoryImpl(db.eqPresetDao);
}

// ---------------------------------------------------------------------------
// Recommendations
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
RecommendationsRepository recommendationsRepository(
  Ref ref,
) {
  final db = ref.watch(databaseProvider);
  return RecommendationsRepositoryImpl(db.recommendationsDao, db.songDao);
}
