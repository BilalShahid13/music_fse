import '../repositories/scan_folder_repository.dart';
import '../../core/errors/result.dart';

/// Registers a new directory as a scan folder.
///
/// Returns the new folder's ID. Fails if the path is already registered.
final class AddScanFolder {
  const AddScanFolder(this._repository);

  final ScanFolderRepository _repository;

  Future<Result<int>> call(String path) => _repository.addFolder(path);
}
