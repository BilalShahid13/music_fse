import 'package:flutter_test/flutter_test.dart';
import 'package:music_fse/core/errors/app_error.dart';
import 'package:music_fse/core/errors/result.dart';

/// Smoke tests for core types.
void main() {
  test('Result.success holds value and exposes accessors', () {
    const r = Result.success(42);
    expect(r.isSuccess, true);
    expect(r.isFailure, false);
    expect(r.valueOrNull, 42);
    expect(r.errorOrNull, isNull);
  });

  test('Result.failure holds error and exposes accessors', () {
    const r = Result<int>.failure(AppError.database(message: 'e'));
    expect(r.isFailure, true);
    expect(r.valueOrNull, isNull);
    expect(r.errorOrNull, isNotNull);
  });
}
