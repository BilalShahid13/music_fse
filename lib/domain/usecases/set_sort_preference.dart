import '../repositories/settings_repository.dart';
import '../../core/errors/result.dart';

/// Persists the sort preference for a given library tab.
final class SetSortPreference {
  const SetSortPreference(this._repository);

  final SettingsRepository _repository;

  Future<Result<void>> call(
    String tab, {
    required String sortBy,
    required bool ascending,
  }) async {
    final r1 = await _repository.setString(SettingsKeys.sortByKey(tab), sortBy);
    if (r1.isFailure) return r1;
    return _repository.setBool(SettingsKeys.sortAscKey(tab), value: ascending);
  }
}
