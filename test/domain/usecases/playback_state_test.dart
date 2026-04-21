import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:music_fse/core/errors/result.dart';
import 'package:music_fse/domain/entities/playback_state.dart';
import 'package:music_fse/domain/entities/queue_item.dart';
import 'package:music_fse/domain/usecases/save_playback_state.dart';
import 'package:music_fse/domain/usecases/get_saved_playback_state.dart';
import 'package:music_fse/domain/usecases/save_queue.dart';
import 'package:music_fse/domain/usecases/get_saved_queue.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockPlaybackRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(const PlaybackState());
    registerFallbackValue(<QueueItem>[]);
  });

  setUp(() {
    mockRepo = MockPlaybackRepository();
  });

  group('SavePlaybackState', () {
    test('delegates to repository', () async {
      when(() => mockRepo.savePlaybackState(any())).thenAnswer((_) async => const Result.success(null));

      final useCase = SavePlaybackState(mockRepo);
      final result = await useCase.call(const PlaybackState());

      expect(result.isSuccess, true);
    });
  });

  group('GetSavedPlaybackState', () {
    test('returns saved state', () async {
      when(() => mockRepo.getSavedPlaybackState()).thenAnswer((_) async => const Result.success(PlaybackState()));

      final useCase = GetSavedPlaybackState(mockRepo);
      final result = await useCase.call();

      expect(result.isSuccess, true);
    });
  });

  group('SaveQueue', () {
    test('delegates to repository', () async {
      when(() => mockRepo.saveQueue(any())).thenAnswer((_) async => const Result.success(null));

      final useCase = SaveQueue(mockRepo);
      final items = [TestSongs.queueItem()];
      final result = await useCase.call(items);

      expect(result.isSuccess, true);
    });
  });

  group('GetSavedQueue', () {
    test('returns saved queue', () async {
      final items = [TestSongs.queueItem()];
      when(() => mockRepo.getQueue()).thenAnswer((_) async => Result.success(items));

      final useCase = GetSavedQueue(mockRepo);
      final result = await useCase.call();

      expect(result.isSuccess, true);
      expect(result.valueOrNull!.length, 1);
    });
  });
}
