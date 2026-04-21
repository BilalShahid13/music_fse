import '../repositories/settings_repository.dart';
import '../../core/errors/result.dart';

/// Persists a typed setting value by key.
///
/// Type parameter [T] must be one of: [String], [bool], [int], [double].
final class SetSetting<T> {
  const SetSetting(this._repository);

  final SettingsRepository _repository;

  Future<Result<void>> call(String key, T value) {
    if (T == String) {
      return _repository.setString(key, value as String);
    } else if (T == bool) {
      return _repository.setBool(key, value: value as bool);
    } else if (T == int) {
      return _repository.setInt(key, value as int);
    } else if (T == double) {
      return _repository.setDouble(key, value as double);
    }
    return Future.value(const Result.success(null));
  }
}
