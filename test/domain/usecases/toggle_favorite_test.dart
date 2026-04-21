import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:music_fse/core/errors/app_error.dart';
import 'package:music_fse/core/errors/result.dart';
import 'package:music_fse/domain/usecases/toggle_favorite.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockSongRepository mockRepo;
  late ToggleFavorite useCase;

  setUp(() {
    mockRepo = MockSongRepository();
    useCase = ToggleFavorite(mockRepo);
  });

  test('toggles favorite to true', () async {
    when(() => mockRepo.toggleFavorite(1, isFavorite: true)).thenAnswer((_) async => const Result.success(null));

    final result = await useCase.call(1, isFavorite: true);

    expect(result.isSuccess, true);
    verify(() => mockRepo.toggleFavorite(1, isFavorite: true)).called(1);
  });

  test('toggles favorite to false', () async {
    when(() => mockRepo.toggleFavorite(1, isFavorite: false)).thenAnswer((_) async => const Result.success(null));

    final result = await useCase.call(1, isFavorite: false);

    expect(result.isSuccess, true);
    verify(() => mockRepo.toggleFavorite(1, isFavorite: false)).called(1);
  });

  test('returns failure on error', () async {
    when(() => mockRepo.toggleFavorite(any(), isFavorite: any(named: 'isFavorite'))).thenAnswer((_) async => const Result.failure(
          AppError.database(message: 'failed'),
        ));

    final result = await useCase.call(1, isFavorite: true);

    expect(result.isFailure, true);
  });
}
