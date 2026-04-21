import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/utils/logger.dart';
import '../../domain/entities/scan_folder.dart';
import 'use_case_providers.dart';

part 'scan_folder_provider.g.dart';

// ---------------------------------------------------------------------------
// Scan folder list
// ---------------------------------------------------------------------------

/// All registered scan directories, ordered by path.
@riverpod
class ScanFoldersNotifier extends _$ScanFoldersNotifier {
  @override
  Future<List<ScanFolder>> build() async {
    final useCase = ref.watch(getScanFoldersProvider);
    final result = await useCase.call();
    return result.when(
      success: List.unmodifiable,
      failure: (error) {
        AppLogger.error(
          'ScanFoldersNotifier: failed to load scan folders',
          tag: 'ScanFoldersNotifier',
          error: error,
        );
        return const [];
      },
    );
  }

  /// Registers [path] as a new scan folder and refreshes.
  ///
  /// Returns the new folder's ID, or -1 on failure.
  Future<int> addFolder(String path) async {
    final useCase = ref.read(addScanFolderProvider);
    final result = await useCase.call(path);
    return result.when(
      success: (id) {
        ref.invalidateSelf();
        return id;
      },
      failure: (error) {
        AppLogger.error(
          'ScanFoldersNotifier: failed to add folder $path',
          tag: 'ScanFoldersNotifier',
          error: error,
        );
        return -1;
      },
    );
  }

  /// Removes scan folder [id] and refreshes.
  Future<void> removeFolder(int id) async {
    final useCase = ref.read(removeScanFolderProvider);
    final result = await useCase.call(id);
    result.when(
      success: (_) => ref.invalidateSelf(),
      failure: (error) => AppLogger.error(
        'ScanFoldersNotifier: failed to remove folder id=$id',
        tag: 'ScanFoldersNotifier',
        error: error,
      ),
    );
  }

}

// ---------------------------------------------------------------------------
// Derived
// ---------------------------------------------------------------------------

/// True when at least one scan folder is configured.
///
/// Used by the onboarding flow to decide whether to show the folder picker.
@riverpod
bool hasScanFolders(Ref ref) {
  final folders = ref.watch(scanFoldersProvider).value ?? [];
  return folders.isNotEmpty;
}
