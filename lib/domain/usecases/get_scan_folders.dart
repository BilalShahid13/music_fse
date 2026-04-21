import '../entities/scan_folder.dart';
import '../repositories/scan_folder_repository.dart';
import '../../core/errors/result.dart';

/// Returns the list of registered scan folders.
final class GetScanFolders {
  const GetScanFolders(this._repository);

  final ScanFolderRepository _repository;

  Future<Result<List<ScanFolder>>> call() => _repository.getAll();
}
