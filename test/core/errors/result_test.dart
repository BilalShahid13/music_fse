import 'package:flutter_test/flutter_test.dart';
import 'package:music_fse/core/errors/app_error.dart';
import 'package:music_fse/core/errors/result.dart';

void main() {
  group('Result', () {
    test('Success holds value', () {
      const result = Result.success(42);
      expect(result.isSuccess, true);
      expect(result.isFailure, false);
      expect(result.valueOrNull, 42);
      expect(result.errorOrNull, isNull);
    });

    test('Failure holds error', () {
      const result = Result<int>.failure(AppError.database(message: 'oops'));
      expect(result.isFailure, true);
      expect(result.isSuccess, false);
      expect(result.valueOrNull, isNull);
      expect(result.errorOrNull, isA<DatabaseError>());
    });

    test('when dispatches correctly', () {
      const success = Result.success('hello');
      final r1 = success.when(
        success: (v) => v.length,
        failure: (_) => -1,
      );
      expect(r1, 5);

      const failure = Result<String>.failure(AppError.notFound(message: 'x'));
      final r2 = failure.when(
        success: (v) => v.length,
        failure: (_) => -1,
      );
      expect(r2, -1);
    });

    test('map transforms success value', () {
      const result = Result.success(10);
      final mapped = result.map((v) => v * 2);
      expect(mapped.valueOrNull, 20);
    });

    test('map preserves failure', () {
      const result = Result<int>.failure(AppError.database(message: 'e'));
      final mapped = result.map((v) => v * 2);
      expect(mapped.isFailure, true);
    });

    test('flatMap chains results', () {
      const result = Result.success(5);
      final chained = result.flatMap((v) => Result.success(v.toString()));
      expect(chained.valueOrNull, '5');
    });

    test('toString on Success', () {
      const result = Result.success(42);
      expect(result.toString(), 'Success(42)');
    });

    test('toString on Failure', () {
      const result = Result<int>.failure(AppError.database(message: 'err'));
      expect(result.toString(), startsWith('Failure('));
    });
  });

  group('AppError', () {
    test('all variants construct', () {
      expect(const AppError.database(message: 'a'), isA<DatabaseError>());
      expect(const AppError.fileSystem(message: 'b'), isA<FileSystemError>());
      expect(const AppError.metadata(message: 'c'), isA<MetadataError>());
      expect(const AppError.playback(message: 'd'), isA<PlaybackError>());
      expect(const AppError.platform(message: 'e'), isA<PlatformError>());
      expect(const AppError.notFound(message: 'f'), isA<NotFoundError>());
      expect(const AppError.validation(message: 'g'), isA<ValidationError>());
    });
  });
}
