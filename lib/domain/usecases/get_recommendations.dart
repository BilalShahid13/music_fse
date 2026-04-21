import '../entities/song.dart';
import '../repositories/recommendations_repository.dart';
import '../../core/errors/result.dart';

final class GetRecommendations {
  const GetRecommendations(this._repository);

  final RecommendationsRepository _repository;

  Future<Result<Map<String, List<Song>>>> call({int limitPerCategory = 20}) =>
      _repository.getRecommendationsByCategory(limitPerCategory: limitPerCategory);
}
