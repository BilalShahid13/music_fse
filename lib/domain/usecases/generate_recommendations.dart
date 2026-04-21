import '../repositories/recommendations_repository.dart';
import '../../core/errors/result.dart';

final class GenerateRecommendations {
  const GenerateRecommendations(this._repository);

  final RecommendationsRepository _repository;

  Future<Result<void>> call() => _repository.generateRecommendations();
}
