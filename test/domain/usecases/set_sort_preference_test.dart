import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:music_fse/core/errors/app_error.dart';
import 'package:music_fse/core/errors/result.dart';
import 'package:music_fse/domain/usecases/set_sort_preference.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockSettingsRepository mockRepo;
  late SetSortPreference useCase;

  setUp(() {
    mockRepo = MockSettingsRepository();
    useCase = SetSortPreference(mockRepo);
  });

  test('persists sort preference', () async {
    when(() => mockRepo.setString('sort_songs_by', 'artist')).thenAnswer((_) async => const Result.success(null));
    when(() => mockRepo.setBool('sort_songs_asc', value: false)).thenAnswer((_) async => const Result.success(null));

    final result = await useCase.call('songs', sortBy: 'artist', ascending: false);

    expect(result.isSuccess, true);
    verify(() => mockRepo.setString('sort_songs_by', 'artist')).called(1);
    verify(() => mockRepo.setBool('sort_songs_asc', value: false)).called(1);
  });

  test('returns failure if first write fails', () async {
    when(() => mockRepo.setString(any(), any())).thenAnswer((_) async => const Result.failure(
          AppError.database(message: 'write failed'),
        ));

    final result = await useCase.call('songs', sortBy: 'title', ascending: true);

    expect(result.isFailure, true);
    verifyNever(() => mockRepo.setBool(any(), value: any(named: 'value')));
  });
}
