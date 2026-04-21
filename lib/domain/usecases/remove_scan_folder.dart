import '../repositories/scan_folder_repository.dart';
import '../../core/errors/result.dart';

/// Removes a scan folder by ID.
///
/// Does NOT delete songs that were sourced from this folder. That is handled
/// by a separate cleanup step in the scan workflow.
final class RemoveScanFolder {
  const RemoveScanFolder(this._repository);

  final ScanFolderRepository _repository;

  Future<Result<void>> call(int id) => _repository.removeFolder(id);
}
