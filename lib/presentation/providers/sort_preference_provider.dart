import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/utils/logger.dart';
import 'use_case_providers.dart';

part 'sort_preference_provider.g.dart';

/// Per-tab sort preference loaded from the settings store.
///
/// Family parameter [tab] identifies the library tab (e.g. 'songs', 'albums').
/// Returns `(sortBy, ascending)`.
@riverpod
class SortPreferenceNotifier extends _$SortPreferenceNotifier {
  @override
  Future<({String sortBy, bool ascending})> build(
    String tab, {
    String defaultSortBy = 'title',
  }) async {
    final useCase = ref.watch(getSortPreferenceProvider);
    final result = await useCase.call(tab, defaultSortBy: defaultSortBy);
    return result.when(
      success: (pref) => pref,
      failure: (error) {
        AppLogger.error(
          'SortPreferenceNotifier: failed to load for tab=$tab',
          tag: 'SortPreferenceNotifier',
          error: error,
        );
        return (sortBy: defaultSortBy, ascending: true);
      },
    );
  }

  /// Updates both sort field and direction and persists them.
  Future<void> setSort({required String sortBy, required bool ascending}) async {
    final useCase = ref.read(setSortPreferenceProvider);
    final result = await useCase.call(tab, sortBy: sortBy, ascending: ascending);
    result.when(
      success: (_) {
        state = AsyncData((sortBy: sortBy, ascending: ascending));
      },
      failure: (error) => AppLogger.error(
        'SortPreferenceNotifier: failed to save for tab=$tab',
        tag: 'SortPreferenceNotifier',
        error: error,
      ),
    );
  }
}
