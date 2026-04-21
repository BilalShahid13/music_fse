import '../entities/scan_folder.dart';
import '../../core/errors/result.dart';

/// Contract for managing which directories the library scanner watches.
abstract class ScanFolderRepository {
  /// Returns all scan folder entries ordered by path.
  Future<Result<List<ScanFolder>>> getAll();

  /// Adds [path] as a new scan folder and returns its new ID.
  /// Fails if the path is already registered.
  Future<Result<int>> addFolder(String path);

  /// Removes the scan folder with [id].
  Future<Result<void>> removeFolder(int id);

  /// Enables or disables scanning for folder [id].
  Future<Result<void>> toggleEnabled(int id, {required bool enabled});

  /// Sets the [lastScannedAt] timestamp for folder [id].
  Future<Result<void>> updateLastScanned(int id, DateTime time);
}
