import 'package:drift/drift.dart';

import 'database.dart';

part 'playback_dao.g.dart';

@DriftAccessor(tables: [PlaybackStates, EqPresets])
class PlaybackDao extends DatabaseAccessor<AppDatabase>
    with _$PlaybackDaoMixin {
  PlaybackDao(super.db);

  /// Returns the singleton playback state row (id = 1).
  /// Returns null if no row exists yet (fresh install).
  Future<PlaybackState?> getPlaybackState() =>
      (select(playbackStates)..where((p) => p.id.equals(1)))
          .getSingleOrNull();

  /// Upserts the singleton row so the provider never has to worry about
  /// whether the row already exists.
  Future<void> savePlaybackState(PlaybackStatesCompanion companion) =>
      into(playbackStates).insertOnConflictUpdate(companion);
}
