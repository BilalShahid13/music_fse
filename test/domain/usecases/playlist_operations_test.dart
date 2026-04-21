import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:music_fse/core/errors/app_error.dart';
import 'package:music_fse/core/errors/result.dart';
import 'package:music_fse/domain/usecases/add_song_to_playlist.dart';
import 'package:music_fse/domain/usecases/remove_song_from_playlist.dart';
import 'package:music_fse/domain/usecases/delete_playlist.dart';
import 'package:music_fse/domain/usecases/rename_playlist.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockPlaylistRepository mockRepo;

  setUp(() {
    mockRepo = MockPlaylistRepository();
  });

  group('AddSongToPlaylist', () {
    late AddSongToPlaylist useCase;
    setUp(() => useCase = AddSongToPlaylist(mockRepo));

    test('delegates to repository', () async {
      when(() => mockRepo.addSongToPlaylist(1, 2)).thenAnswer((_) async => const Result.success(null));

      final result = await useCase.call(1, 2);

      expect(result.isSuccess, true);
      verify(() => mockRepo.addSongToPlaylist(1, 2)).called(1);
    });

    test('returns failure on error', () async {
      when(() => mockRepo.addSongToPlaylist(any(), any())).thenAnswer((_) async => const Result.failure(AppError.database(message: 'err')));

      expect((await useCase.call(1, 2)).isFailure, true);
    });
  });

  group('RemoveSongFromPlaylist', () {
    late RemoveSongFromPlaylist useCase;
    setUp(() => useCase = RemoveSongFromPlaylist(mockRepo));

    test('delegates to repository', () async {
      when(() => mockRepo.removeSongFromPlaylist(1, 2)).thenAnswer((_) async => const Result.success(null));

      final result = await useCase.call(1, 2);

      expect(result.isSuccess, true);
    });
  });

  group('DeletePlaylist', () {
    late DeletePlaylist useCase;
    setUp(() => useCase = DeletePlaylist(mockRepo));

    test('delegates to repository', () async {
      when(() => mockRepo.deletePlaylist(5)).thenAnswer((_) async => const Result.success(null));

      final result = await useCase.call(5);

      expect(result.isSuccess, true);
    });
  });

  group('RenamePlaylist', () {
    late RenamePlaylist useCase;
    setUp(() => useCase = RenamePlaylist(mockRepo));

    test('delegates to repository', () async {
      when(() => mockRepo.renamePlaylist(1, 'New Name')).thenAnswer((_) async => const Result.success(null));

      final result = await useCase.call(1, 'New Name');

      expect(result.isSuccess, true);
    });
  });
}
