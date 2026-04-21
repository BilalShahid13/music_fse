import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:music_fse/core/errors/result.dart';
import 'package:music_fse/domain/entities/play_history_entry.dart';
import 'package:music_fse/domain/usecases/add_play_history.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockPlayHistoryRepository mockRepo;
  late AddPlayHistory useCase;

  setUpAll(() {
    registerFallbackValue(PlayHistoryEntry(
      id: 0,
      songId: 0,
      playedAt: DateTime(2024),
      durationListenedMs: 0,
      sessionId: 0,
    ));
  });

  setUp(() {
    mockRepo = MockPlayHistoryRepository();
    useCase = AddPlayHistory(mockRepo);
  });

  test('records play event', () async {
    when(() => mockRepo.addEntry(any())).thenAnswer((_) async => const Result.success(null));

    final entry = PlayHistoryEntry(
      id: 0,
      songId: 1,
      playedAt: DateTime.now(),
      durationListenedMs: 30000,
      sessionId: 1,
    );

    final result = await useCase.call(entry);
    expect(result.isSuccess, true);
  });
}
