import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:music_fse/core/errors/app_error.dart';
import 'package:music_fse/core/errors/result.dart';
import 'package:music_fse/domain/usecases/save_queue_as_playlist.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockPlaylistRepository mockRepo;
  late SaveQueueAsPlaylist useCase;

  setUp(() {
    mockRepo = MockPlaylistRepository();
    useCase = SaveQueueAsPlaylist(mockRepo);
  });

  setUpAll(() {
    registerFallbackValue(TestSongs.queueItem());
  });

  test('creates playlist and adds all songs', () async {
    when(() => mockRepo.createPlaylist('Queue')).thenAnswer((_) async => const Result.success(10));
    when(() => mockRepo.addSongToPlaylist(any(), any())).thenAnswer((_) async => const Result.success(null));

    final items = [
      TestSongs.queueItem(song: TestSongs.song(id: 1), sortOrder: 0),
      TestSongs.queueItem(song: TestSongs.song(id: 2), sortOrder: 1),
    ];

    final result = await useCase.call('Queue', items);

    expect(result.isSuccess, true);
    expect(result.valueOrNull, 10);
    verify(() => mockRepo.addSongToPlaylist(10, 1)).called(1);
    verify(() => mockRepo.addSongToPlaylist(10, 2)).called(1);
  });

  test('returns failure if create fails', () async {
    when(() => mockRepo.createPlaylist(any())).thenAnswer((_) async => const Result.failure(
          AppError.database(message: 'error'),
        ));

    final result = await useCase.call('Queue', []);

    expect(result.isFailure, true);
  });

  test('returns failure if add song fails', () async {
    when(() => mockRepo.createPlaylist(any())).thenAnswer((_) async => const Result.success(5));
    when(() => mockRepo.addSongToPlaylist(any(), any())).thenAnswer((_) async => const Result.failure(
          AppError.database(message: 'add failed'),
        ));

    final items = [
      TestSongs.queueItem(song: TestSongs.song(id: 1), sortOrder: 0),
    ];

    final result = await useCase.call('Queue', items);

    expect(result.isFailure, true);
  });
}
