import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';

// ---------------------------------------------------------------------------
// Nav sound types and level
// ---------------------------------------------------------------------------

/// The type of UI navigation sound to play.
enum NavSoundType {
  /// Soft tick played when focus moves between elements.
  navigate,

  /// Confirmation chirp played when the A button (Enter) activates an element.
  select,

  /// Descending tone played when the B button (Escape) goes back.
  back,

  /// Low buzz played when an invalid action is attempted.
  error,
}

// ---------------------------------------------------------------------------
// NavSoundPlayer
// ---------------------------------------------------------------------------

/// Plays short UI navigation sounds on a dedicated [AudioPlayer] instance
/// that is entirely separate from the music playback pipeline.
///
/// **Sound assets** (bundled in `assets/sounds/`):
/// - `navigate.wav` — ~50 ms soft tick, played on focus change
/// - `select.wav`   — ~80 ms confirmation chirp, played on A button press
/// - `back.wav`     — ~60 ms descending tone, played on B button press
/// - `error.wav`    — ~100 ms low buzz, played on invalid action
///
/// **Volume**: A linear 0.0–1.0 multiplier sourced from the
/// `nav_sound_level` setting (see `NavSoundLevelNotifier`).
/// - 0.0  → silent (sound disabled)
/// - 0.5  → quiet mode (50 % gain)
/// - 1.0  → normal mode (full gain)
///
/// **Usage**:
/// ```dart
/// final player = NavSoundPlayer();
/// await player.initialize();
/// player.setVolume(0.5); // from NavSoundLevelNotifier
/// player.play(NavSoundType.navigate);
/// // …
/// player.dispose();
/// ```
///
/// Play calls are fire-and-forget — if a previous sound is still playing
/// it is interrupted (seek to 0 + play), giving a responsive feel.
final class NavSoundPlayer {
  NavSoundPlayer();

  final Map<NavSoundType, AudioPlayer> _players = <NavSoundType, AudioPlayer>{};
  final Map<NavSoundType, String> _resolvedPaths = <NavSoundType, String>{};
  final Map<NavSoundType, Future<void>> _playOperations =
      <NavSoundType, Future<void>>{};
  final Map<NavSoundType, bool> _restartRequested = <NavSoundType, bool>{};
  double _volume = AppConstants.defaultNavSoundLevel;
  bool _suppressed = false;
  bool _initialized = false;
  Future<void>? _initializing;

  // Ordered to match [NavSoundType.index] for O(1) lookup.
  static const _assetPaths = <NavSoundType, String>{
    NavSoundType.navigate: 'assets/sounds/navigate.wav',
    NavSoundType.select: 'assets/sounds/select.wav',
    NavSoundType.back: 'assets/sounds/back.wav',
    NavSoundType.error: 'assets/sounds/error.wav',
  };

  // -------------------------------------------------------------------------
  // Lifecycle
  // -------------------------------------------------------------------------

  /// Creates the audio player and pre-loads all sound assets.
  ///
  /// Safe to call multiple times — subsequent calls are no-ops.
  Future<void> initialize() async {
    if (_initialized) return;
    if (_initializing != null) {
      await _initializing;
      return;
    }

    final initFuture = _initializeInternal();
    _initializing = initFuture;
    try {
      await initFuture;
    } finally {
      if (identical(_initializing, initFuture)) {
        _initializing = null;
      }
    }
  }

  Future<void> _initializeInternal() async {
    for (final type in _assetPaths.keys) {
      await _loadPlayer(type);
    }

    _initialized = _players.isNotEmpty;

    if (_initialized) {
      for (final player in _players.values) {
        await _runPlayerCommand(
          player.setVolume(_volume),
          action: 'setVolume',
          resetOnStaleChannel: true,
        );
      }
    }

    if (_initialized) {
      AppLogger.debug(
        'NavSoundPlayer initialised with ${_players.length}/${_assetPaths.length} sounds',
        tag: 'NavSoundPlayer',
      );
    } else {
      AppLogger.warn(
        'NavSoundPlayer: initialisation failed — nav sounds disabled',
        tag: 'NavSoundPlayer',
      );
    }
  }

  Future<void> _loadPlayer(NavSoundType type) async {
    if (_players.containsKey(type)) return;

    final assetPath = _assetPaths[type]!;
    final player = AudioPlayer();

    try {
      final resolvedPath = await _materializeAsset(type, assetPath);
      await player.setFilePath(resolvedPath);
      await player.setVolume(_volume);
      _players[type] = player;
    } catch (e, st) {
      AppLogger.warn(
        'NavSoundPlayer: failed to load $type from $assetPath',
        tag: 'NavSoundPlayer',
        error: e,
        stackTrace: st,
      );
      await player.dispose();
    }
  }

  Future<String> _materializeAsset(NavSoundType type, String assetPath) async {
    final existingPath = _resolvedPaths[type];
    if (existingPath != null && await File(existingPath).exists()) {
      return existingPath;
    }

    final tempDir = await getTemporaryDirectory();
    final fileName = '${type.name}_${p.basename(assetPath)}';
    final filePath = p.join(tempDir.path, fileName);
    final bytes = await rootBundle.load(assetPath);
    final file = File(filePath);
    await file.writeAsBytes(bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes), flush: true);
    _resolvedPaths[type] = file.path;
    return file.path;
  }

  /// Updates the playback volume.
  ///
  /// [volume] must be in 0.0–1.0. A value of 0.0 effectively silences all
  /// nav sounds without disposing the player.
  void setVolume(double volume) {
    _volume = volume.clamp(0.0, 1.0);
    for (final player in _players.values) {
      _dispatchPlayerCommand(
        player.setVolume(_volume),
        action: 'setVolume',
        resetOnStaleChannel: true,
      );
    }
  }

  /// Temporarily suppresses all nav sounds while keeping players ready.
  void setSuppressed(bool suppressed) {
    if (_suppressed == suppressed) return;
    _suppressed = suppressed;

    if (!suppressed) return;

    _restartRequested.clear();

    for (final player in _players.values) {
      _dispatchPlayerCommand(
        player.stop(),
        action: 'stop',
        resetOnStaleChannel: true,
      );
    }
  }

  // -------------------------------------------------------------------------
  // Playback
  // -------------------------------------------------------------------------

  /// Plays the sound associated with [type].
  ///
  /// This is a fire-and-forget call — it does not block the caller and
  /// does not throw on errors. If the volume is 0.0 the call is a no-op.
  void play(NavSoundType type) {
    if (_suppressed || _volume < 0.001) return;
    _schedulePlay(type);
  }

  void _schedulePlay(NavSoundType type) {
    final inFlight = _playOperations[type];
    if (inFlight != null) {
      _restartRequested[type] = true;
      return;
    }

    final operation = _drainPlayRequests(type);
    _playOperations[type] = operation;
    unawaited(operation.whenComplete(() {
      if (identical(_playOperations[type], operation)) {
        _playOperations.remove(type);
      }
    }));
  }

  Future<void> _drainPlayRequests(NavSoundType type) async {
    do {
      _restartRequested[type] = false;
      await _playSound(type);
    } while (_restartRequested[type] == true && !_suppressed && _volume >= 0.001);
    _restartRequested.remove(type);
  }

  Future<void> _playSound(NavSoundType type) async {
    if (!_initialized || _players.isEmpty) {
      await initialize();
    }

    if (!_players.containsKey(type)) {
      await _loadPlayer(type);
    }

    final player = _players[type];
    if (player == null || !_initialized) return;

    try {
      await player.setVolume(_volume);
      await player.stop();
      await player.seek(Duration.zero);
      await player.play();
    } catch (e) {
      // Nav sound failures are always silent — never crash or log at error
      // level, as sounds are optional UX sugar.
      AppLogger.debug(
        'NavSoundPlayer: failed to play $type — ${e.runtimeType}',
        tag: 'NavSoundPlayer',
      );
      if (_isStaleChannelError(e)) {
        await _resetPlayers();
      }
    }
  }

  void _dispatchPlayerCommand(
    Future<void> operation, {
    required String action,
    bool resetOnStaleChannel = false,
  }) {
    unawaited(
      _runPlayerCommand(
        operation,
        action: action,
        resetOnStaleChannel: resetOnStaleChannel,
      ),
    );
  }

  Future<void> _runPlayerCommand(
    Future<void> operation, {
    required String action,
    bool resetOnStaleChannel = false,
  }) async {
    try {
      await operation;
    } catch (e) {
      AppLogger.debug(
        'NavSoundPlayer: $action failed — ${e.runtimeType}',
        tag: 'NavSoundPlayer',
      );
      if (resetOnStaleChannel && _isStaleChannelError(e)) {
        await _resetPlayers();
      }
    }
  }

  bool _isStaleChannelError(Object error) {
    if (error is MissingPluginException) {
      return true;
    }
    if (error is PlatformException) {
      final message = error.message ?? '';
      return message.contains('No implementation found for method');
    }
    return false;
  }

  Future<void> _resetPlayers() async {
    final players = List<AudioPlayer>.from(_players.values);
    _players.clear();
    _playOperations.clear();
    _restartRequested.clear();
    _initialized = false;
    _initializing = null;

    for (final player in players) {
      try {
        await player.dispose();
      } catch (_) {
        // Best-effort only. Stale channels are expected here.
      }
    }
  }

  // -------------------------------------------------------------------------
  // Cleanup
  // -------------------------------------------------------------------------

  Future<void> _disposePlayers() async {
    final players = List<AudioPlayer>.from(_players.values);
    _players.clear();
    for (final player in players) {
      await player.dispose();
    }
  }

  Future<void> dispose() async {
    await _disposePlayers();
    _resolvedPaths.clear();
    _initialized = false;
    _initializing = null;
  }
}
