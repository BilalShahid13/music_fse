import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:music_fse/core/errors/result.dart';
import 'package:music_fse/domain/usecases/generate_recommendations.dart';
import 'package:music_fse/domain/usecases/get_recommendations.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockRecommendationsRepository mockRepo;

  setUp(() {
    mockRepo = MockRecommendationsRepository();
  });

  group('GenerateRecommendations', () {
    late GenerateRecommendations useCase;

    setUp(() {
      useCase = GenerateRecommendations(mockRepo);
    });

    test('delegates to repository', () async {
      when(() => mockRepo.generateRecommendations()).thenAnswer((_) async => const Result.success(null));

      final result = await useCase.call();

      expect(result.isSuccess, true);
      verify(() => mockRepo.generateRecommendations()).called(1);
    });
  });

  group('GetRecommendations', () {
    late GetRecommendations useCase;

    setUp(() {
      useCase = GetRecommendations(mockRepo);
    });

    test('returns recommendations by category', () async {
      final data = {
        'recently_liked': TestSongs.songs(3),
        'hidden_gems': TestSongs.songs(2),
      };
      when(() => mockRepo.getRecommendationsByCategory(limitPerCategory: 20)).thenAnswer((_) async => Result.success(data));

      final result = await useCase.call();

      expect(result.isSuccess, true);
      expect(result.valueOrNull!.keys, containsAll(['recently_liked', 'hidden_gems']));
    });

    test('passes limit parameter', () async {
      when(() => mockRepo.getRecommendationsByCategory(limitPerCategory: 10)).thenAnswer((_) async => const Result.success({}));

      await useCase.call(limitPerCategory: 10);

      verify(() => mockRepo.getRecommendationsByCategory(limitPerCategory: 10)).called(1);
    });
  });
}
