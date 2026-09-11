import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/file_system/file_scanner_impl.dart';
import '../../data/metadata/metadata_extractor_impl.dart';
import '../../domain/usecases/add_play_history.dart';
import '../../domain/usecases/add_scan_folder.dart';
import '../../domain/usecases/add_song_to_playlist.dart';
import '../../domain/usecases/create_playlist.dart';
import '../../domain/usecases/delete_eq_preset.dart';
import '../../domain/usecases/delete_playlist.dart';
import '../../domain/usecases/duplicate_playlist.dart';
import '../../domain/usecases/export_m3u.dart';
import '../../domain/usecases/get_all_albums.dart';
import '../../domain/usecases/get_all_artists.dart';
import '../../domain/usecases/get_all_genres.dart';
import '../../domain/usecases/get_all_playlists.dart';
import '../../domain/usecases/get_all_songs.dart';
import '../../domain/usecases/get_eq_presets.dart';
import '../../domain/usecases/get_favorites.dart';
import '../../domain/usecases/get_folder_contents.dart';
import '../../domain/usecases/get_library_stats.dart';
import '../../domain/usecases/get_most_played.dart';
import '../../domain/usecases/get_play_history.dart';
import '../../domain/usecases/get_playlist_songs.dart';
import '../../domain/usecases/get_recently_added.dart';
import '../../domain/usecases/get_recently_played.dart';
import '../../domain/usecases/get_resume_context.dart';
import '../../domain/usecases/get_saved_playback_state.dart';
import '../../domain/usecases/get_saved_queue.dart';
import '../../domain/usecases/get_scan_folders.dart';
import '../../domain/usecases/get_song_by_id.dart';
import '../../domain/usecases/get_songs_by_album.dart';
import '../../domain/usecases/get_songs_by_artist.dart';
import '../../domain/usecases/get_songs_by_genre.dart';
import '../../domain/usecases/import_m3u.dart';
import '../../domain/usecases/remove_scan_folder.dart';
import '../../domain/usecases/remove_song_from_playlist.dart';
import '../../domain/usecases/rename_playlist.dart';
import '../../domain/usecases/reorder_playlist_song.dart';
import '../../domain/usecases/reset_library.dart';
import '../../domain/usecases/save_eq_preset.dart';
import '../../domain/usecases/save_playback_state.dart';
import '../../domain/usecases/save_queue.dart';
import '../../domain/usecases/save_queue_as_playlist.dart';
import '../../domain/usecases/scan_library.dart';
import '../../domain/usecases/search_library.dart';
import '../../domain/usecases/set_sort_preference.dart';
import '../../domain/usecases/generate_recommendations.dart';
import '../../domain/usecases/get_recommendations.dart';
import '../../domain/usecases/get_sort_preference.dart';
import '../../domain/usecases/mark_song_missing.dart';
import '../../domain/usecases/toggle_favorite.dart';
import '../../domain/usecases/update_play_count.dart';
import 'repository_providers.dart';

part 'use_case_providers.g.dart';

// ---------------------------------------------------------------------------
// Song / Library
// ---------------------------------------------------------------------------

@riverpod
GetAllSongs getAllSongs(Ref ref) => GetAllSongs(ref.watch(songRepositoryProvider));

@riverpod
GetSongById getSongById(Ref ref) => GetSongById(ref.watch(songRepositoryProvider));

@riverpod
GetAllAlbums getAllAlbums(Ref ref) => GetAllAlbums(ref.watch(songRepositoryProvider));

@riverpod
GetAllArtists getAllArtists(Ref ref) => GetAllArtists(ref.watch(songRepositoryProvider));

@riverpod
GetAllGenres getAllGenres(Ref ref) => GetAllGenres(ref.watch(songRepositoryProvider));

@riverpod
GetFavorites getFavorites(Ref ref) => GetFavorites(ref.watch(songRepositoryProvider));

@riverpod
GetMostPlayed getMostPlayed(Ref ref) => GetMostPlayed(ref.watch(songRepositoryProvider));

@riverpod
GetRecentlyAdded getRecentlyAdded(Ref ref) => GetRecentlyAdded(ref.watch(songRepositoryProvider));

@riverpod
GetRecentlyPlayed getRecentlyPlayed(Ref ref) => GetRecentlyPlayed(ref.watch(songRepositoryProvider));

@riverpod
GetLibraryStats getLibraryStats(Ref ref) => GetLibraryStats(ref.watch(songRepositoryProvider));

@riverpod
GetFolderContents getFolderContents(Ref ref) => GetFolderContents(ref.watch(songRepositoryProvider));

@riverpod
GetSongsByAlbum getSongsByAlbum(Ref ref) => GetSongsByAlbum(ref.watch(songRepositoryProvider));

@riverpod
GetSongsByArtist getSongsByArtist(Ref ref) => GetSongsByArtist(ref.watch(songRepositoryProvider));

@riverpod
GetSongsByGenre getSongsByGenre(Ref ref) => GetSongsByGenre(ref.watch(songRepositoryProvider));

@riverpod
ToggleFavorite toggleFavorite(Ref ref) => ToggleFavorite(ref.watch(songRepositoryProvider));

@riverpod
MarkSongMissing markSongMissing(Ref ref) => MarkSongMissing(ref.watch(songRepositoryProvider));

@riverpod
UpdatePlayCount updatePlayCount(Ref ref) => UpdatePlayCount(ref.watch(songRepositoryProvider));

// ---------------------------------------------------------------------------
// Search
// ---------------------------------------------------------------------------

@riverpod
SearchLibrary searchLibrary(Ref ref) => SearchLibrary(
      songRepository: ref.watch(songRepositoryProvider),
      playlistRepository: ref.watch(playlistRepositoryProvider),
    );

// ---------------------------------------------------------------------------
// Playlists
// ---------------------------------------------------------------------------

@riverpod
GetAllPlaylists getAllPlaylists(Ref ref) => GetAllPlaylists(ref.watch(playlistRepositoryProvider));

@riverpod
GetPlaylistSongs getPlaylistSongs(Ref ref) => GetPlaylistSongs(ref.watch(playlistRepositoryProvider));

@riverpod
CreatePlaylist createPlaylist(Ref ref) => CreatePlaylist(ref.watch(playlistRepositoryProvider));

@riverpod
RenamePlaylist renamePlaylist(Ref ref) => RenamePlaylist(ref.watch(playlistRepositoryProvider));

@riverpod
DeletePlaylist deletePlaylist(Ref ref) => DeletePlaylist(ref.watch(playlistRepositoryProvider));

@riverpod
DuplicatePlaylist duplicatePlaylist(Ref ref) => DuplicatePlaylist(ref.watch(playlistRepositoryProvider));

@riverpod
AddSongToPlaylist addSongToPlaylist(Ref ref) => AddSongToPlaylist(ref.watch(playlistRepositoryProvider));

@riverpod
RemoveSongFromPlaylist removeSongFromPlaylist(Ref ref) => RemoveSongFromPlaylist(ref.watch(playlistRepositoryProvider));

@riverpod
ReorderPlaylistSong reorderPlaylistSong(Ref ref) => ReorderPlaylistSong(ref.watch(playlistRepositoryProvider));

@riverpod
ExportM3u exportM3u(Ref ref) => ExportM3u(ref.watch(playlistRepositoryProvider));

@riverpod
ImportM3u importM3u(Ref ref) => ImportM3u(ref.watch(playlistRepositoryProvider));

@riverpod
SaveQueueAsPlaylist saveQueueAsPlaylist(Ref ref) => SaveQueueAsPlaylist(ref.watch(playlistRepositoryProvider));

// ---------------------------------------------------------------------------
// Playback state persistence
// ---------------------------------------------------------------------------

@riverpod
GetSavedPlaybackState getSavedPlaybackState(Ref ref) => GetSavedPlaybackState(ref.watch(playbackRepositoryProvider));

@riverpod
SavePlaybackState savePlaybackState(Ref ref) => SavePlaybackState(ref.watch(playbackRepositoryProvider));

@riverpod
GetSavedQueue getSavedQueue(Ref ref) => GetSavedQueue(ref.watch(playbackRepositoryProvider));

@riverpod
SaveQueue saveQueue(Ref ref) => SaveQueue(ref.watch(playbackRepositoryProvider));

@riverpod
GetResumeContext getResumeContext(Ref ref) => GetResumeContext(playbackRepository: ref.watch(playbackRepositoryProvider));

// ---------------------------------------------------------------------------
// Play history
// ---------------------------------------------------------------------------

@riverpod
AddPlayHistory addPlayHistory(Ref ref) => AddPlayHistory(ref.watch(playHistoryRepositoryProvider));

@riverpod
GetPlayHistory getPlayHistory(Ref ref) => GetPlayHistory(ref.watch(playHistoryRepositoryProvider));

// ---------------------------------------------------------------------------
// Settings
// ---------------------------------------------------------------------------

// GetSetting and SetSetting are generic use cases. Providers are parameterised
// by type — callers call the use case directly by reading these providers.
// They are not wrapped per-setting here; instead, settings_provider.dart
// handles individual setting state.

// ---------------------------------------------------------------------------
// Scan Folders
// ---------------------------------------------------------------------------

@riverpod
GetScanFolders getScanFolders(Ref ref) => GetScanFolders(ref.watch(scanFolderRepositoryProvider));

@riverpod
AddScanFolder addScanFolder(Ref ref) => AddScanFolder(ref.watch(scanFolderRepositoryProvider));

@riverpod
RemoveScanFolder removeScanFolder(Ref ref) => RemoveScanFolder(ref.watch(scanFolderRepositoryProvider));

@riverpod
ResetLibrary resetLibrary(Ref ref) => ResetLibrary(
      songRepository: ref.watch(songRepositoryProvider),
      scanFolderRepository: ref.watch(scanFolderRepositoryProvider),
      playlistRepository: ref.watch(playlistRepositoryProvider),
      playHistoryRepository: ref.watch(playHistoryRepositoryProvider),
      recommendationsRepository: ref.watch(recommendationsRepositoryProvider),
    );

// ---------------------------------------------------------------------------
// Equalizer presets
// ---------------------------------------------------------------------------

@riverpod
GetEqPresets getEqPresets(Ref ref) => GetEqPresets(ref.watch(eqPresetRepositoryProvider));

@riverpod
SaveEqPreset saveEqPreset(Ref ref) => SaveEqPreset(ref.watch(eqPresetRepositoryProvider));

@riverpod
DeleteEqPreset deleteEqPreset(Ref ref) => DeleteEqPreset(ref.watch(eqPresetRepositoryProvider));

// ---------------------------------------------------------------------------
// Library scan
// ---------------------------------------------------------------------------

/// Lazily resolved art cache directory path. Resolved once and kept alive
/// so all providers sharing [ScanLibrary] get the same path.
@Riverpod(keepAlive: true)
Future<String> artCacheDir(Ref ref) async {
  final dir = await getApplicationSupportDirectory();
  return '${dir.path}/art_cache';
}

@riverpod
Future<ScanLibrary> scanLibrary(Ref ref) async {
  final cacheDir = await ref.watch(artCacheDirProvider.future);
  return ScanLibrary(
    songRepository: ref.watch(songRepositoryProvider),
    scanFolderRepository: ref.watch(scanFolderRepositoryProvider),
    fileScanner: const FileScannerImpl(),
    metadataExtractor: const MetadataExtractorImpl(),
    artCacheDir: cacheDir,
  );
}

// ---------------------------------------------------------------------------
// Sort preferences
// ---------------------------------------------------------------------------

@riverpod
GetSortPreference getSortPreference(Ref ref) => GetSortPreference(ref.watch(settingsRepositoryProvider));

@riverpod
SetSortPreference setSortPreference(Ref ref) => SetSortPreference(ref.watch(settingsRepositoryProvider));

// ---------------------------------------------------------------------------
// Recommendations
// ---------------------------------------------------------------------------

@riverpod
GetRecommendations getRecommendations(Ref ref) => GetRecommendations(ref.watch(recommendationsRepositoryProvider));

@riverpod
GenerateRecommendations generateRecommendations(Ref ref) =>
    GenerateRecommendations(ref.watch(recommendationsRepositoryProvider));
