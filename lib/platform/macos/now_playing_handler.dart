import 'dart:io' show Platform;

import 'package:flutter/services.dart';

import '../../core/utils/logger.dart';

// ---------------------------------------------------------------------------
// NowPlayingHandler — macOS MPNowPlayingInfoCenter bridge
// ---------------------------------------------------------------------------

/// Updates the macOS `MPNowPlayingInfoCenter` with the current track's
/// metadata and playback state.
///
/// Communicates via the `com.musicfse.player/now_playing` [MethodChannel]
/// to native Swift code in `macos/Runner/NowPlayingPlugin.swift`.
///
/// On non-macOS platforms every method is a safe no-op.
///
/// **Swift side** must implement the channel and:
///   1. Set `MPNowPlayingInfoPropertyMediaType` to `.audio`.
///   2. Populate `MPNowPlayingInfoCenter.default().nowPlayingInfo` from the
///      dictionary sent by `updateNowPlaying`.
///   3. Clear the info dictionary on `clearNowPlaying`.
///
/// **Usage**:
/// ```dart
/// final handler = NowPlayingHandler();
/// await handler.initialize();
/// handler.updateNowPlaying(title: 'Song', artist: 'Artist', album: 'Album');
/// handler.updatePlaybackState(isPlaying: true, positionSeconds: 42.0,
///     durationSeconds: 180.0, rate: 1.0);
/// ```
final class NowPlayingHandler {
  static const _channel = MethodChannel('com.musicfse.player/now_playing');

  bool get _isMacOs => Platform.isMacOS;

  // -------------------------------------------------------------------------
  // Lifecycle
  // -------------------------------------------------------------------------

  /// Registers the channel and enables the remote command centre.
  ///
  /// Must be called once before any update methods.
  Future<void> initialize() async {
    if (!_isMacOs) return;
    try {
      await _channel.invokeMethod<void>('initialize');
      AppLogger.info('NowPlayingHandler initialised', tag: 'NowPlayingHandler');
    } catch (e, st) {
      AppLogger.error(
        'NowPlayingHandler: failed to initialise',
        tag: 'NowPlayingHandler',
        error: e,
        stackTrace: st,
      );
    }
  }

  void dispose() {
    if (!_isMacOs) return;
    try {
      _channel.invokeMethod<void>('dispose');
    } catch (e) {
      AppLogger.debug('NowPlayingHandler: dispose failed', tag: 'NowPlayingHandler', error: e);
    }
  }

  // -------------------------------------------------------------------------
  // Metadata update
  // -------------------------------------------------------------------------

  /// Pushes track metadata to `MPNowPlayingInfoCenter`.
  ///
  /// [artFilePath] — absolute path to the cached album art thumbnail or null.
  /// [durationSeconds] — total track length in seconds.
  void updateNowPlaying({
    required String title,
    required String artist,
    required String album,
    String? artFilePath,
    double durationSeconds = 0.0,
  }) {
    if (!_isMacOs) return;
    try {
      _channel.invokeMethod<void>('updateNowPlaying', <String, dynamic>{
        'title': title,
        'artist': artist,
        'album': album,
        if (artFilePath != null) 'artFilePath': artFilePath,
        'durationSeconds': durationSeconds,
      });
    } catch (e) {
      AppLogger.warn(
        'NowPlayingHandler: updateNowPlaying failed',
        tag: 'NowPlayingHandler',
        error: e,
      );
    }
  }

  // -------------------------------------------------------------------------
  // Playback state update
  // -------------------------------------------------------------------------

  /// Updates the playback state in `MPNowPlayingInfoCenter`.
  ///
  /// [positionSeconds] — current seek position in seconds.
  /// [rate] — 1.0 when playing, 0.0 when paused.
  void updatePlaybackState({
    required bool isPlaying,
    required double positionSeconds,
    double rate = 1.0,
  }) {
    if (!_isMacOs) return;
    try {
      _channel.invokeMethod<void>('updatePlaybackState', <String, dynamic>{
        'isPlaying': isPlaying,
        'positionSeconds': positionSeconds,
        'rate': isPlaying ? rate : 0.0,
      });
    } catch (e) {
      AppLogger.warn(
        'NowPlayingHandler: updatePlaybackState failed',
        tag: 'NowPlayingHandler',
        error: e,
      );
    }
  }

  // -------------------------------------------------------------------------
  // Clear
  // -------------------------------------------------------------------------

  /// Clears the now-playing info (e.g. when playback stops entirely).
  void clearNowPlaying() {
    if (!_isMacOs) return;
    try {
      _channel.invokeMethod<void>('clearNowPlaying');
    } catch (e) {
      AppLogger.warn(
        'NowPlayingHandler: clearNowPlaying failed',
        tag: 'NowPlayingHandler',
        error: e,
      );
    }
  }
}
