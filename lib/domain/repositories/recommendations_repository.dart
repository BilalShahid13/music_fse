import '../entities/song.dart';
import '../../core/errors/result.dart';

/// Contract for reading and refreshing song recommendations.
///
/// The recommendation engine (data layer) groups songs into named categories
/// (e.g., 'recently_liked', 'hidden_gems') and scores them by relevance.
/// The presentation layer reads pre-computed results — generation is
/// triggered explicitly via [generateRecommendations].
abstract class RecommendationsRepository {
  /// Returns all recommendation categories and their top songs.
  ///
  /// The map key is the category name; the value is the list of songs ordered
  /// by score descending. Each category is limited to [limitPerCategory].
  Future<Result<Map<String, List<Song>>>> getRecommendationsByCategory({
    int limitPerCategory = 20,
  });

  /// Runs the recommendation algorithm on the current library.
  /// This is a potentially expensive operation — call from a background isolate
  /// or via compute() in the data layer implementation.
  Future<Result<void>> generateRecommendations();

  /// Clears all stored recommendations. Called before regenerating.
  Future<Result<void>> clearAll();
}
