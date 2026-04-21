import '../repositories/settings_repository.dart';
import '../../core/errors/result.dart';

/// Reads the persisted sort preference for a given library tab.
final class GetSortPreference {
  const GetSortPreference(this._repository);

  final SettingsRepository _repository;

  /// Returns `(sortBy, ascending)` for the given [tab] name.
  /// Defaults to `(defaultSortBy, true)` if nothing is stored.
  Future<Result<({String sortBy, bool ascending})>> call(
    String tab, {
    String defaultSortBy = 'title',
  }) async {
    final sortByResult = await _repository.getString(SettingsKeys.sortByKey(tab));
    final ascResult = await _repository.getBool(SettingsKeys.sortAscKey(tab));

    final sortBy = sortByResult.when(
      success: (v) => v ?? defaultSortBy,
      failure: (_) => defaultSortBy,
    );
    final ascending = ascResult.when(
      success: (v) => v ?? true,
      failure: (_) => true,
    );

    return Result.success((sortBy: sortBy, ascending: ascending));
  }
}
