import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:music_fse/core/errors/app_error.dart';
import 'package:music_fse/core/errors/result.dart';
import 'package:music_fse/domain/usecases/get_favorites.dart';
import 'package:music_fse/domain/usecases/get_song_by_id.dart';
import 'package:music_fse/domain/usecases/update_play_count.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockSongRepository mockRepo;

  setUp(() {
    mockRepo = MockSongRepository();
  });

  group('GetFavorites', () {
    late GetFavorites useCase;
    setUp(() => useCase = GetFavorites(mockRepo));

    test('returns favorite songs', () async {
      final songs = TestSongs.songs(3);
      when(() => mockRepo.getFavorites(sortBy: any(named: 'sortBy'), ascending: any(named: 'ascending')))
          .thenAnswer((_) async => Result.success(songs));

      final result = await useCase.call();

      expect(result.isSuccess, true);
      expect(result.valueOrNull!.length, 3);
    });

    test('passes sort parameters', () async {
      when(() => mockRepo.getFavorites(sortBy: 'title', ascending: false)).thenAnswer((_) async => const Result.success([]));

      await useCase.call(sortBy: 'title', ascending: false);

      verify(() => mockRepo.getFavorites(sortBy: 'title', ascending: false)).called(1);
    });
  });

  group('GetSongById', () {
    late GetSongById useCase;
    setUp(() => useCase = GetSongById(mockRepo));

    test('returns song', () async {
      final song = TestSongs.song(id: 42);
      when(() => mockRepo.getSongById(42)).thenAnswer((_) async => Result.success(song));

      final result = await useCase.call(42);

      expect(result.isSuccess, true);
      expect(result.valueOrNull!.id, 42);
    });

    test('returns failure for missing id', () async {
      when(() => mockRepo.getSongById(any())).thenAnswer((_) async => const Result.failure(AppError.notFound(message: 'not found')));

      expect((await useCase.call(999)).isFailure, true);
    });
  });

  group('UpdatePlayCount', () {
    late UpdatePlayCount useCase;
    setUp(() => useCase = UpdatePlayCount(mockRepo));

    test('delegates to repository', () async {
      final now = DateTime.now();
      when(() => mockRepo.updatePlayCount(1, playCount: 5, lastPlayedAt: now)).thenAnswer((_) async => const Result.success(null));

      final result = await useCase.call(1, playCount: 5, lastPlayedAt: now);

      expect(result.isSuccess, true);
    });
  });
}
