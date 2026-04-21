import '../../core/errors/app_error.dart';
import '../../core/errors/result.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/play_history_entry.dart';
import '../../domain/repositories/play_history_repository.dart';
import '../datasources/local/play_history_dao.dart';
import '../models/play_history_mapper.dart';

/// Concrete implementation of [PlayHistoryRepository] backed by
/// [PlayHistoryDao].
final class PlayHistoryRepositoryImpl implements PlayHistoryRepository {
  const PlayHistoryRepositoryImpl(this._dao);

  final PlayHistoryDao _dao;

  @override
  Future<Result<void>> addEntry(PlayHistoryEntry entry) async {
    try {
      await _dao.addEntry(entry.toCompanion());
      return const Result.success(null);
    } catch (e, st) {
      AppLogger.error('addEntry failed',
          tag: 'PlayHistoryRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<List<PlayHistoryEntry>>> getHistory({int limit = 200}) async {
    try {
      final rows = await _dao.getHistory(limit: limit);
      return Result.success(rows.map((r) => r.toEntity()).toList());
    } catch (e, st) {
      AppLogger.error('getHistory failed',
          tag: 'PlayHistoryRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> clearHistory() async {
    try {
      await _dao.clearHistory();
      return const Result.success(null);
    } catch (e, st) {
      AppLogger.error('clearHistory failed',
          tag: 'PlayHistoryRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }
}
