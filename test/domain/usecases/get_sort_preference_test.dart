import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:music_fse/core/errors/app_error.dart';
import 'package:music_fse/core/errors/result.dart';
import 'package:music_fse/domain/usecases/get_sort_preference.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockSettingsRepository mockRepo;
  late GetSortPreference useCase;

  setUp(() {
    mockRepo = MockSettingsRepository();
    useCase = GetSortPreference(mockRepo);
  });

  test('returns stored sort preference', () async {
    when(() => mockRepo.getString('sort_songs_by')).thenAnswer((_) async => const Result.success('artist'));
    when(() => mockRepo.getBool('sort_songs_asc')).thenAnswer((_) async => const Result.success(false));

    final result = await useCase.call('songs');

    expect(result.isSuccess, true);
    expect(result.valueOrNull!.sortBy, 'artist');
    expect(result.valueOrNull!.ascending, false);
  });

  test('returns defaults when nothing stored', () async {
    when(() => mockRepo.getString(any())).thenAnswer((_) async => const Result.success(null));
    when(() => mockRepo.getBool(any())).thenAnswer((_) async => const Result.success(null));

    final result = await useCase.call('songs');

    expect(result.isSuccess, true);
    expect(result.valueOrNull!.sortBy, 'title');
    expect(result.valueOrNull!.ascending, true);
  });

  test('returns defaults on failure', () async {
    when(() => mockRepo.getString(any())).thenAnswer((_) async => const Result.failure(
          AppError.database(message: 'error'),
        ));
    when(() => mockRepo.getBool(any())).thenAnswer((_) async => const Result.failure(
          AppError.database(message: 'error'),
        ));

    final result = await useCase.call('songs', defaultSortBy: 'dateAdded');

    expect(result.isSuccess, true);
    expect(result.valueOrNull!.sortBy, 'dateAdded');
    expect(result.valueOrNull!.ascending, true);
  });
}
