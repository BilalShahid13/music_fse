import '../../core/errors/app_error.dart';
import '../../core/errors/result.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/eq_preset.dart';
import '../../domain/repositories/eq_preset_repository.dart';
import '../datasources/local/eq_preset_dao.dart';
import '../models/eq_preset_mapper.dart';

/// Concrete implementation of [EqPresetRepository] backed by [EqPresetDao].
final class EqPresetRepositoryImpl implements EqPresetRepository {
  const EqPresetRepositoryImpl(this._dao);

  final EqPresetDao _dao;

  @override
  Future<Result<List<EqPreset>>> getAll() async {
    try {
      final rows = await _dao.getAll();
      return Result.success(rows.map((r) => r.toEntity()).toList());
    } catch (e, st) {
      AppLogger.error('getAll failed',
          tag: 'EqPresetRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<EqPreset>> getById(int id) async {
    try {
      final row = await _dao.getById(id);
      if (row == null) {
        return Result.failure(
          AppError.notFound(message: 'EQ preset not found: id=$id'),
        );
      }
      return Result.success(row.toEntity());
    } catch (e, st) {
      AppLogger.error('getById($id) failed',
          tag: 'EqPresetRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<int>> createPreset(String name, List<double> bands) async {
    try {
      final id = await _dao.createPreset(name, eqBandsToJson(bands));
      return Result.success(id);
    } catch (e, st) {
      AppLogger.error('createPreset failed',
          tag: 'EqPresetRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> updatePreset(int id, List<double> bands) async {
    try {
      await _dao.updatePreset(id, eqBandsToJson(bands));
      return const Result.success(null);
    } catch (e, st) {
      AppLogger.error('updatePreset($id) failed',
          tag: 'EqPresetRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> deletePreset(int id) async {
    try {
      await _dao.deletePreset(id);
      return const Result.success(null);
    } catch (e, st) {
      AppLogger.error('deletePreset($id) failed',
          tag: 'EqPresetRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }
}
