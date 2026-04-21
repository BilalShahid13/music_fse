import '../../core/errors/app_error.dart';
import '../../core/errors/result.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/song.dart' as domain;
import '../../domain/repositories/recommendations_repository.dart';
import '../datasources/local/database.dart' show Song, RecommendationsCompanion;
import '../datasources/local/recommendations_dao.dart';
import '../datasources/local/song_dao.dart';
import '../models/song_mapper.dart';

/// Concrete implementation of [RecommendationsRepository].
///
/// Reads pre-computed recommendations from the database and exposes a
/// [generateRecommendations] method that runs the scoring algorithm and
/// persists results via [RecommendationsDao.replaceCategory].
///
/// The generation algorithm is intentionally simple and runs fully in Dart —
/// no ML, no network. It is designed to be fast enough to run on first launch
/// (<500ms for a 10K library) and on-demand from the settings screen.
final class RecommendationsRepositoryImpl implements RecommendationsRepository {
  const RecommendationsRepositoryImpl(this._dao, this._songDao);

  final RecommendationsDao _dao;
  final SongDao _songDao;

  // -------------------------------------------------------------------------
  // Read
  // -------------------------------------------------------------------------

  @override
  Future<Result<Map<String, List<domain.Song>>>> getRecommendationsByCategory({
    int limitPerCategory = 20,
  }) async {
    try {
      final categories = await _dao.getAllCategories();
      final result = <String, List<domain.Song>>{};

      for (final category in categories) {
        final rows = await _dao.getByCategory(category, limit: limitPerCategory);
        result[category] = rows.map((r) => r.song.toEntity()).toList();
      }

      return Result.success(result);
    } catch (e, st) {
      AppLogger.error('getRecommendationsByCategory failed', tag: 'RecommendationsRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  // -------------------------------------------------------------------------
  // Generation
  // -------------------------------------------------------------------------

  @override
  Future<Result<void>> generateRecommendations() async {
    try {
      final allSongs = await _songDao.getAllSongs();
      final now = DateTime.now();

      await Future.wait([
        _generateRecentlyLiked(allSongs, now),
        _generateHiddenGems(allSongs, now),
        _generateTopPlayed(allSongs),
      ]);

      return const Result.success(null);
    } catch (e, st) {
      AppLogger.error('generateRecommendations failed', tag: 'RecommendationsRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> clearAll() async {
    try {
      await _dao.clearAll();
      return const Result.success(null);
    } catch (e, st) {
      AppLogger.error('clearAll failed', tag: 'RecommendationsRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  // -------------------------------------------------------------------------
  // Private algorithm helpers
  // -------------------------------------------------------------------------

  /// Category: songs the user has marked as favorite, ordered by how recently
  /// they were last played. Score = recency normalised to 0.0–1.0.
  Future<void> _generateRecentlyLiked(
    List<Song> allSongs,
    DateTime now,
  ) async {
    const category = 'recently_liked';
    final favorites = allSongs.where((s) => s.isFavorite).toList()
      ..sort((a, b) => (b.lastPlayedAt ?? DateTime(1970)).compareTo(a.lastPlayedAt ?? DateTime(1970)));

    final companions = favorites.take(50).map((s) {
      final daysSince = s.lastPlayedAt != null ? now.difference(s.lastPlayedAt!).inDays.toDouble() : 9999.0;
      final score = (1.0 - (daysSince / 365.0)).clamp(0.0, 1.0);
      return RecommendationsCompanion.insert(
        songId: s.id,
        category: category,
        score: score,
        generatedAt: now,
      );
    }).toList();

    await _dao.replaceCategory(category, companions);
  }

  /// Category: songs added more than 30 days ago with fewer than 3 plays —
  /// music the user imported but has barely listened to.
  Future<void> _generateHiddenGems(
    List<Song> allSongs,
    DateTime now,
  ) async {
    const category = 'hidden_gems';
    final cutoff = now.subtract(const Duration(days: 30));

    final gems = allSongs
        .where(
          (s) => s.dateAdded.isBefore(cutoff) && s.playCount < 3 && !s.isMissing,
        )
        .toList()
      ..sort((a, b) => b.dateAdded.compareTo(a.dateAdded));

    final companions = gems.take(50).map((s) {
      final ageDays = now.difference(s.dateAdded).inDays.clamp(30, 365).toDouble();
      final playPenalty = s.playCount * 0.2;
      final score = ((1.0 - (ageDays / 365.0)) - playPenalty).clamp(0.0, 1.0);
      return RecommendationsCompanion.insert(
        songId: s.id,
        category: category,
        score: score,
        generatedAt: now,
      );
    }).toList();

    await _dao.replaceCategory(category, companions);
  }

  /// Category: the user's most-played tracks, scored by play count normalised
  /// to the max play count in the library.
  Future<void> _generateTopPlayed(List<Song> allSongs) async {
    const category = 'top_played';
    final played = allSongs.where((s) => s.playCount > 0 && !s.isMissing).toList()..sort((a, b) => b.playCount.compareTo(a.playCount));

    if (played.isEmpty) {
      await _dao.replaceCategory(category, []);
      return;
    }

    final maxPlays = played.first.playCount.toDouble();
    final now = DateTime.now();
    final companions = played.take(50).map((s) {
      final score = (s.playCount / maxPlays).clamp(0.0, 1.0);
      return RecommendationsCompanion.insert(
        songId: s.id,
        category: category,
        score: score,
        generatedAt: now,
      );
    }).toList();

    await _dao.replaceCategory(category, companions);
  }
}
