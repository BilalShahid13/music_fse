import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:music_fse/core/errors/app_error.dart';
import 'package:music_fse/core/errors/result.dart';
import 'package:music_fse/domain/usecases/get_all_songs.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockSongRepository mockRepo;
  late GetAllSongs useCase;

  setUp(() {
    mockRepo = MockSongRepository();
    useCase = GetAllSongs(mockRepo);
  });

  test('returns songs from repository', () async {
    final songs = TestSongs.songs(3);
    when(() => mockRepo.getAllSongs(sortBy: 'title', ascending: true)).thenAnswer((_) async => Result.success(songs));

    final result = await useCase.call(sortBy: 'title', ascending: true);

    expect(result.isSuccess, true);
    expect(result.valueOrNull, songs);
    verify(() => mockRepo.getAllSongs(sortBy: 'title', ascending: true)).called(1);
  });

  test('passes sort parameters through', () async {
    when(() => mockRepo.getAllSongs(sortBy: 'artist', ascending: false)).thenAnswer((_) async => const Result.success([]));

    await useCase.call(sortBy: 'artist', ascending: false);

    verify(() => mockRepo.getAllSongs(sortBy: 'artist', ascending: false)).called(1);
  });

  test('returns failure on repository error', () async {
    when(() => mockRepo.getAllSongs()).thenAnswer((_) async => const Result.failure(
          AppError.database(message: 'db error'),
        ));

    final result = await useCase.call();

    expect(result.isFailure, true);
  });
}
