import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:music_fse/core/errors/app_error.dart';
import 'package:music_fse/core/errors/result.dart';
import 'package:music_fse/domain/usecases/create_playlist.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockPlaylistRepository mockRepo;
  late CreatePlaylist useCase;

  setUp(() {
    mockRepo = MockPlaylistRepository();
    useCase = CreatePlaylist(mockRepo);
  });

  test('creates playlist and returns id', () async {
    when(() => mockRepo.createPlaylist('My Playlist')).thenAnswer((_) async => const Result.success(42));

    final result = await useCase.call('My Playlist');

    expect(result.isSuccess, true);
    expect(result.valueOrNull, 42);
  });

  test('returns failure on error', () async {
    when(() => mockRepo.createPlaylist(any())).thenAnswer((_) async => const Result.failure(
          AppError.database(message: 'duplicate'),
        ));

    final result = await useCase.call('Dup');

    expect(result.isFailure, true);
  });
}
