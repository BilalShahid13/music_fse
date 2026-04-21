import 'package:drift/drift.dart';

import 'database.dart';

part 'recommendations_dao.g.dart';

/// A typed result pairing a recommendation row with its full song row.
final class RecommendationWithSong {
  const RecommendationWithSong({
    required this.recommendation,
    required this.song,
  });

  final Recommendation recommendation;
  final Song song;
}

@DriftAccessor(tables: [Recommendations, Songs])
class RecommendationsDao extends DatabaseAccessor<AppDatabase>
    with _$RecommendationsDaoMixin {
  RecommendationsDao(super.db);

  /// Returns recommendations for a given [category], joined with songs,
  /// ordered by score descending. Limited to [limit] entries.
  Future<List<RecommendationWithSong>> getByCategory(
    String category, {
    int limit = 20,
  }) {
    final query = select(recommendations).join([
      innerJoin(songs, songs.id.equalsExp(recommendations.songId)),
    ])
      ..where(recommendations.category.equals(category))
      ..orderBy([OrderingTerm.desc(recommendations.score)])
      ..limit(limit);

    return query
        .map(
          (row) => RecommendationWithSong(
            recommendation: row.readTable(recommendations),
            song: row.readTable(songs),
          ),
        )
        .get();
  }

  /// Returns all distinct category names that have at least one recommendation.
  Future<List<String>> getAllCategories() async {
    final rows = await (selectOnly(recommendations)
          ..addColumns([recommendations.category])
          ..groupBy([recommendations.category]))
        .get();
    return rows
        .map((r) => r.read(recommendations.category))
        .whereType<String>()
        .toList();
  }

  /// Atomically removes all existing recommendations for [category] and
  /// inserts [items]. Used by the recommendation engine after a run.
  Future<void> replaceCategory(
    String category,
    List<RecommendationsCompanion> items,
  ) =>
      transaction(() async {
        await (delete(recommendations)
              ..where((r) => r.category.equals(category)))
            .go();
        if (items.isNotEmpty) {
          await batch((b) => b.insertAll(recommendations, items));
        }
      });

  Future<void> clearAll() => delete(recommendations).go();
}
