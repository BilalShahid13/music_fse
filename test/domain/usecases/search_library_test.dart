import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:music_fse/core/errors/result.dart';
import 'package:music_fse/domain/usecases/search_library.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockSongRepository mockSongRepo;
  late MockPlaylistRepository mockPlaylistRepo;
  late SearchLibrary useCase;

  setUp(() {
    mockSongRepo = MockSongRepository();
    mockPlaylistRepo = MockPlaylistRepository();
    useCase = SearchLibrary(
      songRepository: mockSongRepo,
      playlistRepository: mockPlaylistRepo,
    );
  });

  test('returns empty results for blank query', () async {
    final result = await useCase.call('   ');

    expect(result.isSuccess, true);
    expect(result.valueOrNull!.isEmpty, true);
    verifyNever(() => mockSongRepo.searchSongs(any(), limit: any(named: 'limit')));
  });

  test('runs all four searches concurrently', () async {
    final songs = TestSongs.songs(2);
    when(() => mockSongRepo.searchSongs('rock', limit: 5)).thenAnswer((_) async => Result.success(songs));
    when(() => mockSongRepo.searchAlbums('rock', limit: 5)).thenAnswer((_) async => const Result.success([]));
    when(() => mockSongRepo.searchArtists('rock', limit: 5)).thenAnswer((_) async => const Result.success([]));
    when(() => mockPlaylistRepo.searchPlaylists('rock', limit: 5)).thenAnswer((_) async => const Result.success([]));

    final result = await useCase.call('rock');

    expect(result.isSuccess, true);
    expect(result.valueOrNull!.songs.length, 2);
    expect(result.valueOrNull!.albums, isEmpty);
  });

  test('treats failed sub-search as empty', () async {
    when(() => mockSongRepo.searchSongs(any(), limit: any(named: 'limit'))).thenAnswer((_) async => const Result.success([]));
    when(() => mockSongRepo.searchAlbums(any(), limit: any(named: 'limit'))).thenAnswer((_) async => const Result.success([]));
    when(() => mockSongRepo.searchArtists(any(), limit: any(named: 'limit'))).thenAnswer((_) async => const Result.success([]));
    when(() => mockPlaylistRepo.searchPlaylists(any(), limit: any(named: 'limit'))).thenAnswer((_) async => const Result.success([]));

    final result = await useCase.call('test');

    expect(result.isSuccess, true);
    expect(result.valueOrNull!.totalCount, 0);
  });
}
