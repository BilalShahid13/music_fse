import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:just_audio/just_audio.dart';
import 'package:riverpod/riverpod.dart' show ProviderListenableSelect;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/play_history_entry.dart';
import '../../domain/entities/playback_state.dart';
import '../../domain/entities/queue_item.dart';
import '../../domain/entities/song.dart';
import '../../platform/media_keys/media_key_handler.dart';
import 'scan_provider.dart';
import 'settings_provider.dart';
import 'toast_provider.dart';
import 'use_case_providers.dart';

part 'playback_provider.g.dart';

// ---------------------------------------------------------------------------
// Playback notifier
// ---------------------------------------------------------------------------

/// The central audio-engine state machine.
///
/// Architecture decisions:
/// - Dual [AudioPlayer] (A / B) supports crossfade without interrupting
///   the outgoing track.
/// - The internal [_queue] is a plain [List<Song>] mirrored from the
///   [PlaybackState] value object for performance. The value object is the
///   source of truth consumers observe; the list is the engine's working set.
/// - Queue persistence is debounced 2 s to avoid hammering the DB on rapid
///   track changes (e.g. skip-hold).
/// - Play-count accounting runs in-notifier so no separate isolate is needed.
@Riverpod(keepAlive: true)
class PlaybackNotifier extends _$PlaybackNotifier {
  // -------------------------------------------------------------------------
  // Engine fields (not exposed in state)
  // -------------------------------------------------------------------------

  AudioPlayer? _playerA;
  AudioPlayer? _playerB; // active only during crossfade

  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<ProcessingState>? _processingStateSub;

  /// Ordered list of songs in the current queue.
  final List<Song> _queue = [];

  /// The pre-shuffle order, preserved so we can restore on disable.
  final List<Song> _originalQueue = [];

  int _currentIndex = -1;

  /// When playback of the current track started (wall-clock).
  DateTime? _trackStartTime;

  /// Accumulated milliseconds listened to the current track.
  int _listenedMs = 0;

  /// Whether the play-count threshold has already been credited this track.
  bool _playCountCredited = false;

  /// Integer session identifier — groups play-history entries per launch.
  int _sessionId = 0;

  Timer? _crossfadeTimer;
  Timer? _saveDebounceTimer;

  int _consecutiveMissCount = 0;

  late final MediaKeyHandler _mediaKeyHandler;

  // -------------------------------------------------------------------------
  // Riverpod lifecycle
  // -------------------------------------------------------------------------

  @override
  PlaybackState build() {
    ref.onDispose(_dispose);
    _sessionId = DateTime.now().millisecondsSinceEpoch;
    _mediaKeyHandler = MediaKeyHandler.create();
    _mediaKeyHandler.onPlayPause = togglePlayPause;
    _mediaKeyHandler.onPlay = play;
    _mediaKeyHandler.onPause = pause;
    _mediaKeyHandler.onNext = skipNext;
    _mediaKeyHandler.onPrevious = skipPrevious;
    _mediaKeyHandler.onStop = clearQueue;
    _mediaKeyHandler.initialize();
    _initPlayer();
    _restoreState();
    return const PlaybackState();
  }

  // -------------------------------------------------------------------------
  // Initialisation helpers
  // -------------------------------------------------------------------------

  void _initPlayer() {
    _playerA = AudioPlayer();

    // just_audio streams are backed by BehaviorSubject and emit their current
    // value synchronously on subscription. If _initPlayer() is called during
    // the widget build phase (because a widget first watches this provider
    // inside its build()), those synchronous emissions would call
    // `state = state.copyWith(...)` while the tree is building, triggering
    // Riverpod's "Tried to modify a provider while the widget tree was
    // building" error. Deferring via Future.microtask() ensures subscriptions
    // are set up after the current build phase completes.
    Future.microtask(() {
      if (_playerA == null) return; // disposed before microtask ran
      _positionSub = _playerA!.positionStream.listen(_onPosition);
      _durationSub = _playerA!.durationStream.listen(_onDuration);
      _playerStateSub = _playerA!.playerStateStream.listen(_onPlayerState);
    });
  }

  Future<void> _restoreState() async {
    final shouldResume = (await ref.read(resumeOnLaunchProvider.future));
    if (!shouldResume) return;

    final queueResult = await ref.read(getSavedQueueProvider).call();
    final pbResult = await ref.read(getSavedPlaybackStateProvider).call();

    final savedQueue = queueResult.valueOrNull ?? [];
    final savedPb = pbResult.valueOrNull;

    if (savedQueue.isEmpty) return;

    _queue
      ..clear()
      ..addAll(savedQueue.map((qi) => qi.song));

    _currentIndex = savedQueue.indexWhere((qi) => qi.isCurrent);
    if (_currentIndex < 0) _currentIndex = 0;

    final restoredSong = _queue[_currentIndex];

    try {
      await _playerA!.setAudioSource(
        AudioSource.file(restoredSong.filePath),
      );

      final resumePos = savedQueue[_currentIndex].positionMs;
      if (resumePos > 0) {
        await _playerA!.seek(Duration(milliseconds: resumePos));
      }
    } catch (e, st) {
      AppLogger.error(
        'PlaybackNotifier: restore failed',
        tag: 'PlaybackNotifier',
        error: e,
        stackTrace: st,
      );
      return;
    }

    state = state.copyWith(
      currentSong: restoredSong,
      volume: savedPb?.volume ?? AppConstants.defaultVolume,
      isShuffle: savedPb?.isShuffle ?? false,
      repeatMode: savedPb?.repeatMode ?? RepeatMode.off,
      crossfadeSeconds: savedPb?.crossfadeSeconds ?? 0,
      isEqEnabled: savedPb?.isEqEnabled ?? false,
    );

    await _playerA!.setVolume(state.volume);
  }

  // -------------------------------------------------------------------------
  // Stream handlers
  // -------------------------------------------------------------------------

  void _onPosition(Duration position) {
    // Accumulate listening time only while actually playing.
    if (state.isPlaying && _trackStartTime != null) {
      final now = DateTime.now();
      _listenedMs += now.difference(_trackStartTime!).inMilliseconds.clamp(0, 5000);
      _trackStartTime = now;
      _maybeCreditPlayCount();
    }

    state = state.copyWith(position: position);
    _maybeTriggerCrossfade(position);
  }

  void _onDuration(Duration? duration) {
    if (duration != null) {
      state = state.copyWith(duration: duration);
    }
  }

  void _onPlayerState(PlayerState ps) {
    final nowPlaying = ps.playing;
    if (nowPlaying && _trackStartTime == null) {
      _trackStartTime = DateTime.now();
    } else if (!nowPlaying) {
      _trackStartTime = null;
    }

    state = state.copyWith(isPlaying: nowPlaying);
    _mediaKeyHandler.updatePlaybackStatus(nowPlaying);

    if (ps.processingState == ProcessingState.completed && _playerB == null) {
      _onTrackComplete();
    }
  }

  // -------------------------------------------------------------------------
  // Track completion
  // -------------------------------------------------------------------------

  void _onTrackComplete() {
    switch (state.repeatMode) {
      case RepeatMode.one:
        _replayCurrentTrack();
      case RepeatMode.all:
        final nextIndex = (_currentIndex + 1) % _queue.length;
        _playAtIndex(nextIndex);
      case RepeatMode.off:
        if (_currentIndex < _queue.length - 1) {
          _playAtIndex(_currentIndex + 1);
        } else {
          // End of queue — stop and park at position 0.
          state = state.copyWith(isPlaying: false, position: Duration.zero);
        }
    }
  }

  Future<void> _replayCurrentTrack() async {
    await _playerA?.seek(Duration.zero);
    await _playerA?.play();
  }

  // -------------------------------------------------------------------------
  // Play count / history
  // -------------------------------------------------------------------------

  void _maybeCreditPlayCount() {
    if (_playCountCredited) return;
    final song = state.currentSong;
    if (song == null) return;
    final durationMs = song.durationMs;
    final thresholdMet =
        _listenedMs >= AppConstants.playCountThresholdMs || (durationMs > 0 && _listenedMs >= durationMs * AppConstants.playCountThresholdPercent);
    if (!thresholdMet) return;

    _playCountCredited = true;
    _creditPlayCount(song);
  }

  Future<void> _creditPlayCount(Song song) async {
    final now = DateTime.now();

    // Update play count on the song.
    await ref.read(updatePlayCountProvider).call(
          song.id,
          playCount: song.playCount + 1,
          lastPlayedAt: now,
        );

    // Record in play history.
    await ref.read(addPlayHistoryProvider).call(
          PlayHistoryEntry(
            id: 0, // auto-assigned by DB (ignored on insert)
            songId: song.id,
            playedAt: now,
            durationListenedMs: _listenedMs,
            sessionId: _sessionId,
          ),
        );
  }

  // -------------------------------------------------------------------------
  // Crossfade
  // -------------------------------------------------------------------------

  void _maybeTriggerCrossfade(Duration position) {
    if (_playerB != null) return; // already crossfading
    final cf = state.crossfadeSeconds;
    if (cf == 0) return;
    final duration = state.duration;
    if (duration == Duration.zero) return;

    final remaining = duration - position;
    if (remaining.inSeconds > cf) return;

    // Peek at the next song; don't start crossfade if queue is at end.
    final nextIndex = _nextIndex;
    if (nextIndex == null) return;

    _startCrossfade(nextIndex);
  }

  Future<void> _startCrossfade(int nextIndex) async {
    final nextSong = _queue[nextIndex];
    _playerB = AudioPlayer();

    try {
      await _playerB!.setAudioSource(AudioSource.file(nextSong.filePath));
      await _playerB!.setVolume(0.0);
      await _playerB!.play();
    } catch (e, st) {
      AppLogger.error(
        'PlaybackNotifier: crossfade init failed',
        tag: 'PlaybackNotifier',
        error: e,
        stackTrace: st,
      );
      await _playerB?.dispose();
      _playerB = null;
      return;
    }

    const tickInterval = Duration(milliseconds: 50);
    final steps = (state.crossfadeSeconds * 1000) ~/ 50;
    int tick = 0;

    _crossfadeTimer = Timer.periodic(tickInterval, (timer) async {
      tick++;
      final progress = tick / steps;
      final clampedProgress = progress.clamp(0.0, 1.0);

      await _playerA?.setVolume(
        (state.volume * (1 - clampedProgress)).clamp(0.0, 1.0),
      );
      await _playerB?.setVolume(
        (state.volume * clampedProgress).clamp(0.0, 1.0),
      );

      if (progress >= 1.0) {
        timer.cancel();
        _crossfadeTimer = null;
        await _finishCrossfade(nextIndex);
      }
    });
  }

  Future<void> _finishCrossfade(int nextIndex) async {
    final outgoing = _playerA;

    // Swap players.
    _playerA = _playerB;
    _playerB = null;

    // Re-attach subscriptions to the new primary player.
    await _cancelSubscriptions();
    _positionSub = _playerA!.positionStream.listen(_onPosition);
    _durationSub = _playerA!.durationStream.listen(_onDuration);
    _playerStateSub = _playerA!.playerStateStream.listen(_onPlayerState);

    await outgoing?.dispose();

    _currentIndex = nextIndex;
    _resetTrackAccounting();

    state = state.copyWith(
      currentSong: _queue[nextIndex],
      position: Duration.zero,
    );
  }

  // -------------------------------------------------------------------------
  // Public playback API
  // -------------------------------------------------------------------------

  /// Replaces the queue and starts playback from [startIndex].
  Future<void> playQueue(
    List<Song> songs, {
    int startIndex = 0,
    QueueSourceType? sourceType,
    int? sourceId,
  }) async {
    _queue
      ..clear()
      ..addAll(songs);
    _originalQueue
      ..clear()
      ..addAll(songs);

    if (state.isShuffle) {
      _shuffleQueueKeepingIndex(startIndex);
    } else {
      _currentIndex = startIndex.clamp(0, songs.length - 1);
    }

    await _loadAndPlay(_currentIndex, sourceType: sourceType, sourceId: sourceId);
    _scheduleSaveQueue();
  }

  /// Adds [song] to the end of the current queue.
  Future<void> addToQueue(Song song) async {
    _queue.add(song);
    _originalQueue.add(song);
    _scheduleSaveQueue();
    state = state.copyWith(queue: List.unmodifiable(_queue));
  }

  /// Inserts [song] immediately after the current track.
  Future<void> playNext(Song song) async {
    final insertAt = (_currentIndex + 1).clamp(0, _queue.length);
    _queue.insert(insertAt, song);
    _originalQueue.insert(insertAt, song);
    _scheduleSaveQueue();
    state = state.copyWith(queue: List.unmodifiable(_queue));
  }

  /// Removes the song at [queueIndex].
  Future<void> removeFromQueue(int queueIndex) async {
    if (queueIndex < 0 || queueIndex >= _queue.length) return;
    _queue.removeAt(queueIndex);
    if (queueIndex < _currentIndex) _currentIndex--;
    _scheduleSaveQueue();
    state = state.copyWith(queue: List.unmodifiable(_queue));
  }

  /// Moves the queue item at [oldIndex] to [newIndex].
  void reorderQueue(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    final song = _queue.removeAt(oldIndex);
    _queue.insert(newIndex, song);
    if (_currentIndex == oldIndex) {
      _currentIndex = newIndex;
    } else if (oldIndex < _currentIndex && newIndex >= _currentIndex) {
      _currentIndex--;
    } else if (oldIndex > _currentIndex && newIndex <= _currentIndex) {
      _currentIndex++;
    }
    _scheduleSaveQueue();
    state = state.copyWith(queue: List.unmodifiable(_queue));
  }

  Future<void> play() async {
    if (state.currentSong == null && _queue.isNotEmpty) {
      await _loadAndPlay(0);
    } else {
      await _playerA?.play();
    }
  }

  Future<void> pause() => _playerA?.pause() ?? Future.value();

  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> skipNext() async {
    final next = _nextIndex;
    if (next == null) return;
    await _loadAndPlay(next);
  }

  Future<void> skipPrevious() async {
    if (state.position.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }
    final prev = _previousIndex;
    if (prev == null) return;
    await _loadAndPlay(prev);
  }

  Future<void> seek(Duration position) async {
    await _playerA?.seek(position);
    state = state.copyWith(position: position);
  }

  Future<void> setVolume(double volume) async {
    final clamped = volume.clamp(0.0, 1.0);
    state = state.copyWith(volume: clamped, isMuted: false);
    await _playerA?.setVolume(clamped);
  }

  Future<void> toggleMute() async {
    if (state.isMuted) {
      state = state.copyWith(isMuted: false);
      await _playerA?.setVolume(state.volume);
    } else {
      state = state.copyWith(isMuted: true);
      await _playerA?.setVolume(0.0);
    }
  }

  void toggleShuffle() {
    if (state.isShuffle) {
      // Restore original order; preserve current song position.
      _queue
        ..clear()
        ..addAll(_originalQueue);
      _currentIndex = _queue.indexWhere((s) => s.id == state.currentSong?.id);
      if (_currentIndex < 0) _currentIndex = 0;
      state = state.copyWith(
        isShuffle: false,
        queue: List.unmodifiable(_queue),
      );
    } else {
      _originalQueue
        ..clear()
        ..addAll(_queue);
      _shuffleQueueKeepingIndex(_currentIndex);
      state = state.copyWith(
        isShuffle: true,
        queue: List.unmodifiable(_queue),
      );
    }
    _scheduleSaveQueue();
  }

  void cycleRepeatMode() {
    final next = switch (state.repeatMode) {
      RepeatMode.off => RepeatMode.all,
      RepeatMode.all => RepeatMode.one,
      RepeatMode.one => RepeatMode.off,
    };
    state = state.copyWith(repeatMode: next);
  }

  Future<void> setCrossfadeSeconds(int seconds) async {
    state = state.copyWith(crossfadeSeconds: seconds.clamp(0, 12));
    // Persist via the dedicated settings notifier.
    await ref.read(crossfadeSecondsProvider.notifier).set(seconds);
  }

  /// Convenience wrapper: play [song] with an optional surrounding [queue]
  /// starting at [index]. Equivalent to `playQueue(queue, startIndex: index)`.
  Future<void> playSong(
    Song song, {
    List<Song>? queue,
    int index = 0,
    QueueSourceType? sourceType,
    int? sourceId,
  }) =>
      playQueue(
        queue ?? [song],
        startIndex: index,
        sourceType: sourceType,
        sourceId: sourceId,
      );

  /// Stops playback and empties the queue.
  Future<void> clearQueue() async {
    _queue.clear();
    _originalQueue.clear();
    _currentIndex = -1;
    await _playerA?.stop();
    state = PlaybackState.initial();
  }

  /// Re-runs the saved state restore (useful for the home screen resume card).
  Future<void> resumeFromSaved() => _restoreState();

  /// Saves current state to the database (e.g., on app close).
  Future<void> persistState() async {
    await ref.read(savePlaybackStateProvider).call(state);
    _saveQueueNow();
  }

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  Future<void> _loadAndPlay(
    int index, {
    QueueSourceType? sourceType,
    int? sourceId,
  }) async {
    if (index < 0 || index >= _queue.length) return;

    _currentIndex = index;
    _resetTrackAccounting();

    final song = _queue[index];

    // Pre-check: does the file exist?
    if (!File(song.filePath).existsSync()) {
      await _handleMissingSong(song);
      return;
    }

    // Update state immediately so the mini player bar appears while the audio
    // engine loads the track. The _onPlayerState stream handler will flip
    // isPlaying to true once AVPlayer actually starts.
    state = state.copyWith(
      currentSong: song,
      position: Duration.zero,
      duration: Duration.zero,
      queue: List.unmodifiable(_queue),
      queueSourceType: sourceType ?? state.queueSourceType,
      queueSourceId: sourceId ?? state.queueSourceId,
    );

    try {
      await _playerA?.stop();
      await _playerA?.setAudioSource(AudioSource.file(song.filePath));
      await _playerA?.setVolume(state.isMuted ? 0.0 : state.volume);
      await _playerA?.play();
    } on PlayerException catch (e) {
      AppLogger.warn(
        'Playback failed for ${song.filePath}: $e',
        tag: 'PlaybackNotifier',
      );
      await _handleMissingSong(song);
      return;
    } catch (e, st) {
      AppLogger.error(
        'PlaybackNotifier: load failed for ${song.filePath}',
        tag: 'PlaybackNotifier',
        error: e,
        stackTrace: st,
      );
      state = state.copyWith(isPlaying: false);
      return;
    }

    _consecutiveMissCount = 0;

    _mediaKeyHandler.updateMetadata(
      title: song.title,
      artist: song.artist,
      album: song.album,
      artUri: song.artCachePath,
      durationMs: song.durationMs,
    );
  }

  Future<void> _handleMissingSong(Song song) async {
    _consecutiveMissCount++;

    // Mark song as missing in DB
    await ref.read(markSongMissingProvider).call(song.id, isMissing: true);

    // Show toast
    ref.read(toastProvider.notifier).show(
          'File not found: ${song.title}',
          isError: true,
        );

    // Check consecutive miss threshold
    if (_consecutiveMissCount >= AppConstants.consecutiveMissingThreshold) {
      ref.read(toastProvider.notifier).show(
            "Several tracks couldn't be found. Consider rescanning your library.",
            isError: true,
            undoLabel: 'Rescan',
            undoAction: () => ref.read(scanProvider.notifier).startScan(),
          );
      _consecutiveMissCount = 0;
      state = state.copyWith(isPlaying: false);
      return;
    }

    // Auto-skip to next
    final next = _nextIndex;
    if (next != null) {
      await _loadAndPlay(next);
    } else {
      state = state.copyWith(isPlaying: false);
    }
  }

  Future<void> _playAtIndex(int index) => _loadAndPlay(index);

  int? get _nextIndex {
    if (_queue.isEmpty) return null;
    if (_currentIndex < _queue.length - 1) return _currentIndex + 1;
    if (state.repeatMode == RepeatMode.all) return 0;
    return null;
  }

  int? get _previousIndex {
    if (_queue.isEmpty) return null;
    if (_currentIndex > 0) return _currentIndex - 1;
    if (state.repeatMode == RepeatMode.all) return _queue.length - 1;
    return null;
  }

  void _resetTrackAccounting() {
    _trackStartTime = state.isPlaying ? DateTime.now() : null;
    _listenedMs = 0;
    _playCountCredited = false;
  }

  void _shuffleQueueKeepingIndex(int anchorIndex) {
    if (_queue.length <= 1) {
      _currentIndex = 0;
      return;
    }
    final anchor = _queue[anchorIndex];
    _queue.removeAt(anchorIndex);
    _queue.shuffle(math.Random());
    _queue.insert(0, anchor);
    _currentIndex = 0;
  }

  // -------------------------------------------------------------------------
  // Queue persistence (debounced)
  // -------------------------------------------------------------------------

  void _scheduleSaveQueue() {
    _saveDebounceTimer?.cancel();
    _saveDebounceTimer = Timer(
      const Duration(seconds: AppConstants.queueSaveDebounceSeconds),
      _saveQueueNow,
    );
  }

  Future<void> _saveQueueNow() async {
    _saveDebounceTimer?.cancel();
    _saveDebounceTimer = null;
    final items = [
      for (int i = 0; i < _queue.length; i++)
        QueueItem(
          song: _queue[i],
          sortOrder: i,
          isCurrent: i == _currentIndex,
          positionMs: i == _currentIndex ? state.position.inMilliseconds : 0,
        ),
    ];
    await ref.read(saveQueueProvider).call(items);
  }

  // -------------------------------------------------------------------------
  // Disposal
  // -------------------------------------------------------------------------

  Future<void> _cancelSubscriptions() async {
    await _positionSub?.cancel();
    await _durationSub?.cancel();
    await _playerStateSub?.cancel();
    await _processingStateSub?.cancel();
    _positionSub = null;
    _durationSub = null;
    _playerStateSub = null;
    _processingStateSub = null;
  }

  Future<void> _dispose() async {
    _saveDebounceTimer?.cancel();
    _crossfadeTimer?.cancel();
    await _cancelSubscriptions();
    await persistState();
    await _playerA?.dispose();
    await _playerB?.dispose();
    _playerA = null;
    _playerB = null;
    _mediaKeyHandler.dispose();
  }
}

// ---------------------------------------------------------------------------
// Derived selector providers
// ---------------------------------------------------------------------------

/// The song currently loaded in the player.
@riverpod
Song? currentSong(Ref ref) => ref.watch(playbackProvider.select((s) => s.currentSong));

/// Whether the player is currently playing.
@riverpod
bool isPlaying(Ref ref) => ref.watch(playbackProvider.select((s) => s.isPlaying));

/// Current playback position.
@riverpod
Duration playbackPosition(Ref ref) => ref.watch(playbackProvider.select((s) => s.position));

/// Duration of the current track.
@riverpod
Duration trackDuration(Ref ref) => ref.watch(playbackProvider.select((s) => s.duration));

/// Current master volume (0.0–1.0).
@riverpod
double playbackVolume(Ref ref) => ref.watch(playbackProvider.select((s) => s.volume));

/// Whether shuffle is active.
@riverpod
bool isShuffle(Ref ref) => ref.watch(playbackProvider.select((s) => s.isShuffle));

/// Current repeat mode.
@riverpod
RepeatMode repeatMode(Ref ref) => ref.watch(playbackProvider.select((s) => s.repeatMode));

/// A snapshot of the current queue.
@riverpod
List<Song> currentQueue(Ref ref) => ref.watch(playbackProvider.select((s) => s.queue));

/// Whether the player is muted.
@riverpod
bool isMuted(Ref ref) => ref.watch(playbackProvider.select((s) => s.isMuted));
