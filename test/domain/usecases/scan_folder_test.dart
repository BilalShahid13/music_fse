import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:music_fse/core/errors/app_error.dart';
import 'package:music_fse/core/errors/result.dart';
import 'package:music_fse/domain/usecases/add_scan_folder.dart';
import 'package:music_fse/domain/usecases/remove_scan_folder.dart';
import 'package:music_fse/domain/usecases/get_scan_folders.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockScanFolderRepository mockRepo;

  setUp(() {
    mockRepo = MockScanFolderRepository();
  });

  group('AddScanFolder', () {
    late AddScanFolder useCase;
    setUp(() => useCase = AddScanFolder(mockRepo));

    test('returns new folder id', () async {
      when(() => mockRepo.addFolder('/music')).thenAnswer((_) async => const Result.success(7));

      final result = await useCase.call('/music');

      expect(result.valueOrNull, 7);
    });

    test('returns failure for duplicate', () async {
      when(() => mockRepo.addFolder(any())).thenAnswer((_) async => const Result.failure(AppError.validation(message: 'duplicate')));

      expect((await useCase.call('/music')).isFailure, true);
    });
  });

  group('RemoveScanFolder', () {
    test('delegates to repository', () async {
      when(() => mockRepo.removeFolder(3)).thenAnswer((_) async => const Result.success(null));

      final useCase = RemoveScanFolder(mockRepo);
      expect((await useCase.call(3)).isSuccess, true);
    });
  });

  group('GetScanFolders', () {
    test('returns folder list', () async {
      when(() => mockRepo.getAll()).thenAnswer((_) async => const Result.success([]));

      final useCase = GetScanFolders(mockRepo);
      final result = await useCase.call();

      expect(result.isSuccess, true);
    });
  });
}
