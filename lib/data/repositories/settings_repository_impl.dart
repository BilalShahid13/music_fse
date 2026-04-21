import '../../core/errors/app_error.dart';
import '../../core/errors/result.dart';
import '../../core/utils/logger.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/local/settings_dao.dart';

/// Concrete implementation of [SettingsRepository] backed by [SettingsDao].
///
/// All values are stored as strings. Type conversion is handled here so
/// callers can work with typed values.
final class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._dao);

  final SettingsDao _dao;

  // -------------------------------------------------------------------------
  // Readers
  // -------------------------------------------------------------------------

  @override
  Future<Result<String?>> getString(String key) async {
    try {
      final value = await _dao.getValue(key);
      return Result.success(value);
    } catch (e, st) {
      AppLogger.error('getString($key) failed',
          tag: 'SettingsRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<bool?>> getBool(String key) async {
    try {
      final raw = await _dao.getValue(key);
      if (raw == null) return const Result.success(null);
      return Result.success(raw == 'true');
    } catch (e, st) {
      AppLogger.error('getBool($key) failed',
          tag: 'SettingsRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<int?>> getInt(String key) async {
    try {
      final raw = await _dao.getValue(key);
      if (raw == null) return const Result.success(null);
      final parsed = int.tryParse(raw);
      return Result.success(parsed);
    } catch (e, st) {
      AppLogger.error('getInt($key) failed',
          tag: 'SettingsRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<double?>> getDouble(String key) async {
    try {
      final raw = await _dao.getValue(key);
      if (raw == null) return const Result.success(null);
      final parsed = double.tryParse(raw);
      return Result.success(parsed);
    } catch (e, st) {
      AppLogger.error('getDouble($key) failed',
          tag: 'SettingsRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  // -------------------------------------------------------------------------
  // Writers
  // -------------------------------------------------------------------------

  @override
  Future<Result<void>> setString(String key, String value) async {
    try {
      await _dao.setValue(key, value);
      return const Result.success(null);
    } catch (e, st) {
      AppLogger.error('setString($key) failed',
          tag: 'SettingsRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> setBool(String key, {required bool value}) async {
    try {
      await _dao.setValue(key, value.toString());
      return const Result.success(null);
    } catch (e, st) {
      AppLogger.error('setBool($key) failed',
          tag: 'SettingsRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> setInt(String key, int value) async {
    try {
      await _dao.setValue(key, value.toString());
      return const Result.success(null);
    } catch (e, st) {
      AppLogger.error('setInt($key) failed',
          tag: 'SettingsRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> setDouble(String key, double value) async {
    try {
      await _dao.setValue(key, value.toString());
      return const Result.success(null);
    } catch (e, st) {
      AppLogger.error('setDouble($key) failed',
          tag: 'SettingsRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> remove(String key) async {
    try {
      await _dao.remove(key);
      return const Result.success(null);
    } catch (e, st) {
      AppLogger.error('remove($key) failed',
          tag: 'SettingsRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }
}
