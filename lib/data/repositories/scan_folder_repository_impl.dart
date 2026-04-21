import '../../core/errors/app_error.dart';
import '../../core/errors/result.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/scan_folder.dart';
import '../../domain/repositories/scan_folder_repository.dart';
import '../datasources/local/scan_folder_dao.dart';
import '../models/scan_folder_mapper.dart';

/// Concrete implementation of [ScanFolderRepository] backed by [ScanFolderDao].
final class ScanFolderRepositoryImpl implements ScanFolderRepository {
  const ScanFolderRepositoryImpl(this._dao);

  final ScanFolderDao _dao;

  @override
  Future<Result<List<ScanFolder>>> getAll() async {
    try {
      final rows = await _dao.getAll();
      return Result.success(rows.map((r) => r.toEntity()).toList());
    } catch (e, st) {
      AppLogger.error('getAll failed', tag: 'ScanFolderRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<int>> addFolder(String path) async {
    try {
      final id = await _dao.addFolder(path);
      return Result.success(id);
    } catch (e, st) {
      AppLogger.error('addFolder($path) failed', tag: 'ScanFolderRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> removeFolder(int id) async {
    try {
      await _dao.removeFolder(id);
      return const Result.success(null);
    } catch (e, st) {
      AppLogger.error('removeFolder($id) failed', tag: 'ScanFolderRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> toggleEnabled(
    int id, {
    required bool enabled,
  }) async {
    try {
      await _dao.toggleEnabled(id, enabled: enabled);
      return const Result.success(null);
    } catch (e, st) {
      AppLogger.error('toggleEnabled($id) failed', tag: 'ScanFolderRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> updateLastScanned(int id, DateTime time) async {
    try {
      await _dao.updateLastScanned(id, time);
      return const Result.success(null);
    } catch (e, st) {
      AppLogger.error('updateLastScanned($id) failed', tag: 'ScanFolderRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }
}
