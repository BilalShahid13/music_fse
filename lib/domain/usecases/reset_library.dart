import '../../core/errors/result.dart';
import '../repositories/play_history_repository.dart';
import '../repositories/playlist_repository.dart';
import '../repositories/recommendations_repository.dart';
import '../repositories/scan_folder_repository.dart';
import '../repositories/song_repository.dart';

/// Clears all library-derived data and returns the app to first-run content state.
final class ResetLibrary {
  const ResetLibrary({
    required SongRepository songRepository,
    required ScanFolderRepository scanFolderRepository,
    required PlaylistRepository playlistRepository,
    required PlayHistoryRepository playHistoryRepository,
    required RecommendationsRepository recommendationsRepository,
  })  : _songRepository = songRepository,
        _scanFolderRepository = scanFolderRepository,
        _playlistRepository = playlistRepository,
        _playHistoryRepository = playHistoryRepository,
        _recommendationsRepository = recommendationsRepository;

  final SongRepository _songRepository;
  final ScanFolderRepository _scanFolderRepository;
  final PlaylistRepository _playlistRepository;
  final PlayHistoryRepository _playHistoryRepository;
  final RecommendationsRepository _recommendationsRepository;

  Future<Result<void>> call() async {
    final historyResult = await _playHistoryRepository.clearHistory();
    if (historyResult.isFailure) return Result.failure(historyResult.errorOrNull!);

    final recommendationsResult = await _recommendationsRepository.clearAll();
    if (recommendationsResult.isFailure) {
      return Result.failure(recommendationsResult.errorOrNull!);
    }

    final playlistsResult = await _playlistRepository.clearAllPlaylists();
    if (playlistsResult.isFailure) return Result.failure(playlistsResult.errorOrNull!);

    final songsResult = await _songRepository.clearAllSongs();
    if (songsResult.isFailure) return Result.failure(songsResult.errorOrNull!);

    final foldersResult = await _scanFolderRepository.clearAllFolders();
    if (foldersResult.isFailure) return Result.failure(foldersResult.errorOrNull!);

    return const Result.success(null);
  }
}