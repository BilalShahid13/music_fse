import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:music_fse/core/errors/result.dart';
import 'package:music_fse/domain/usecases/reset_library.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockSongRepository songRepository;
  late MockScanFolderRepository scanFolderRepository;
  late MockPlaylistRepository playlistRepository;
  late MockPlayHistoryRepository playHistoryRepository;
  late MockRecommendationsRepository recommendationsRepository;
  late ResetLibrary useCase;

  setUp(() {
    songRepository = MockSongRepository();
    scanFolderRepository = MockScanFolderRepository();
    playlistRepository = MockPlaylistRepository();
    playHistoryRepository = MockPlayHistoryRepository();
    recommendationsRepository = MockRecommendationsRepository();

    when(() => playHistoryRepository.clearHistory()).thenAnswer((_) async => const Result.success(null));
    when(() => recommendationsRepository.clearAll()).thenAnswer((_) async => const Result.success(null));
    when(() => playlistRepository.clearAllPlaylists()).thenAnswer((_) async => const Result.success(null));
    when(() => songRepository.clearAllSongs()).thenAnswer((_) async => const Result.success(null));
    when(() => scanFolderRepository.clearAllFolders()).thenAnswer((_) async => const Result.success(null));

    useCase = ResetLibrary(
      songRepository: songRepository,
      scanFolderRepository: scanFolderRepository,
      playlistRepository: playlistRepository,
      playHistoryRepository: playHistoryRepository,
      recommendationsRepository: recommendationsRepository,
    );
  });

  test('clears library-derived data in dependency-safe order', () async {
    final result = await useCase.call();

    expect(result.isSuccess, isTrue);
    verifyInOrder([
      () => playHistoryRepository.clearHistory(),
      () => recommendationsRepository.clearAll(),
      () => playlistRepository.clearAllPlaylists(),
      () => songRepository.clearAllSongs(),
      () => scanFolderRepository.clearAllFolders(),
    ]);
  });
}