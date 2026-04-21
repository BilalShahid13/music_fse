import 'package:mocktail/mocktail.dart';
import 'package:music_fse/domain/repositories/song_repository.dart';
import 'package:music_fse/domain/repositories/playlist_repository.dart';
import 'package:music_fse/domain/repositories/playback_repository.dart';
import 'package:music_fse/domain/repositories/settings_repository.dart';
import 'package:music_fse/domain/repositories/play_history_repository.dart';
import 'package:music_fse/domain/repositories/scan_folder_repository.dart';
import 'package:music_fse/domain/repositories/recommendations_repository.dart';
import 'package:music_fse/domain/repositories/eq_preset_repository.dart';

class MockSongRepository extends Mock implements SongRepository {}

class MockPlaylistRepository extends Mock implements PlaylistRepository {}

class MockPlaybackRepository extends Mock implements PlaybackRepository {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

class MockPlayHistoryRepository extends Mock implements PlayHistoryRepository {}

class MockScanFolderRepository extends Mock implements ScanFolderRepository {}

class MockRecommendationsRepository extends Mock implements RecommendationsRepository {}

class MockEqPresetRepository extends Mock implements EqPresetRepository {}
