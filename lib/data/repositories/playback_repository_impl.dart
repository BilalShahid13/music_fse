import '../../core/errors/app_error.dart';
import '../../core/errors/result.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/playback_state.dart';
import '../../domain/entities/queue_item.dart';
import '../../domain/repositories/playback_repository.dart';
import '../datasources/local/playback_dao.dart';
import '../datasources/local/queue_dao.dart';
import '../models/playback_state_mapper.dart';
import '../models/queue_mapper.dart';

/// Concrete implementation of [PlaybackRepository] backed by [PlaybackDao]
/// and [QueueDao].
final class PlaybackRepositoryImpl implements PlaybackRepository {
  const PlaybackRepositoryImpl(this._playbackDao, this._queueDao);

  final PlaybackDao _playbackDao;
  final QueueDao _queueDao;

  // -------------------------------------------------------------------------
  // Queue
  // -------------------------------------------------------------------------

  @override
  Future<Result<List<QueueItem>>> getQueue() async {
    try {
      final rows = await _queueDao.getQueue();
      return Result.success(rows.map((r) => r.toEntity()).toList());
    } catch (e, st) {
      AppLogger.error('getQueue failed', tag: 'PlaybackRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> saveQueue(List<QueueItem> items) async {
    try {
      final companions = List.generate(
        items.length,
        (i) => queueItemToCompanion(items[i], sortOrder: i),
      );
      await _queueDao.saveQueue(companions);
      return const Result.success(null);
    } catch (e, st) {
      AppLogger.error('saveQueue failed', tag: 'PlaybackRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> clearQueue() async {
    try {
      await _queueDao.clearQueue();
      return const Result.success(null);
    } catch (e, st) {
      AppLogger.error('clearQueue failed', tag: 'PlaybackRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  // -------------------------------------------------------------------------
  // Playback State
  // -------------------------------------------------------------------------

  @override
  Future<Result<PlaybackState>> getSavedPlaybackState() async {
    try {
      final row = await _playbackDao.getPlaybackState();
      if (row == null) return Result.success(PlaybackState.initial());
      return Result.success(row.toEntity());
    } catch (e, st) {
      AppLogger.error('getSavedPlaybackState failed', tag: 'PlaybackRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> savePlaybackState(PlaybackState state) async {
    try {
      await _playbackDao.savePlaybackState(state.toCompanion());
      return const Result.success(null);
    } catch (e, st) {
      AppLogger.error('savePlaybackState failed', tag: 'PlaybackRepo', error: e, stackTrace: st);
      return Result.failure(AppError.database(message: e.toString()));
    }
  }
}
