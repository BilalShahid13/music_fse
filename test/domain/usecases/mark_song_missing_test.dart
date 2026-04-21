import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:music_fse/core/errors/app_error.dart';
import 'package:music_fse/core/errors/result.dart';
import 'package:music_fse/domain/usecases/mark_song_missing.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockSongRepository mockRepo;
  late MarkSongMissing useCase;

  setUp(() {
    mockRepo = MockSongRepository();
    useCase = MarkSongMissing(mockRepo);
  });

  test('marks song as missing', () async {
    when(() => mockRepo.markMissing(1, isMissing: true)).thenAnswer((_) async => const Result.success(null));

    final result = await useCase.call(1, isMissing: true);

    expect(result.isSuccess, true);
    verify(() => mockRepo.markMissing(1, isMissing: true)).called(1);
  });

  test('unmarks song as missing', () async {
    when(() => mockRepo.markMissing(1, isMissing: false)).thenAnswer((_) async => const Result.success(null));

    final result = await useCase.call(1, isMissing: false);

    expect(result.isSuccess, true);
  });

  test('returns failure on error', () async {
    when(() => mockRepo.markMissing(any(), isMissing: any(named: 'isMissing'))).thenAnswer((_) async => const Result.failure(
          AppError.database(message: 'error'),
        ));

    final result = await useCase.call(99, isMissing: true);

    expect(result.isFailure, true);
  });
}
