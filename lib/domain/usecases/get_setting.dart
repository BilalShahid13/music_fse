import '../repositories/settings_repository.dart';
import '../../core/errors/result.dart';

/// Reads a typed setting value by key.
///
/// Type parameter [T] must be one of: [String], [bool], [int], [double].
/// Returns null if the key has never been set.
final class GetSetting<T> {
  const GetSetting(this._repository);

  final SettingsRepository _repository;

  Future<Result<T?>> call(String key) {
    if (T == String) {
      return _repository.getString(key) as Future<Result<T?>>;
    } else if (T == bool) {
      return _repository.getBool(key) as Future<Result<T?>>;
    } else if (T == int) {
      return _repository.getInt(key) as Future<Result<T?>>;
    } else if (T == double) {
      return _repository.getDouble(key) as Future<Result<T?>>;
    }
    return Future.value(const Result.success(null));
  }
}
