import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';

import '../../core/utils/logger.dart';

// ---------------------------------------------------------------------------
// MediaKeyHandler — cross-platform abstract interface
// ---------------------------------------------------------------------------

/// Unified interface for receiving OS-level media key / transport events on
/// platforms where XInput / SMTC is unavailable (macOS, Linux, or Windows
/// without a gamepad).
///
/// Implementations:
/// - [_MacOsMediaKeyHandler] — `MPRemoteCommandCenter` via a [MethodChannel]
///   to the Swift `macos/Runner/` host code.
/// - [_LinuxMediaKeyHandler] — D-Bus MPRIS via a [MethodChannel] to native
///   Linux host code.
/// - [_NoOpMediaKeyHandler] — returned on Windows (SMTC handles it there).
///
/// Usage:
/// ```dart
/// final handler = MediaKeyHandler.create();
/// handler.onPlayPause = () => ref.read(playbackProvider.notifier).togglePlayPause();
/// await handler.initialize();
/// ```
abstract class MediaKeyHandler {

  // ---------------------------------------------------------------------------
  // Factory
  // ---------------------------------------------------------------------------

  /// Returns the platform-appropriate implementation.
  ///
  /// Windows returns a [_NoOpMediaKeyHandler] because SMTC (via
  /// [SmtcController]) handles transport events there.
  factory MediaKeyHandler.create() {
    if (Platform.isMacOS) return _MacOsMediaKeyHandler();
    if (Platform.isLinux) return _LinuxMediaKeyHandler();
    return _NoOpMediaKeyHandler();
  }
  MediaKeyHandler._();

  /// Called when the Play key / command is received.
  VoidCallback? onPlay;

  /// Called when the Pause key / command is received.
  VoidCallback? onPause;

  /// Called when the Play/Pause toggle key / command is received.
  VoidCallback? onPlayPause;

  /// Called when the Next Track key / command is received.
  VoidCallback? onNext;

  /// Called when the Previous Track key / command is received.
  VoidCallback? onPrevious;

  /// Called when the Stop key / command is received.
  VoidCallback? onStop;

  /// Registers with the OS and begins delivering events.
  ///
  /// Must be called before any callbacks fire.
  Future<void> initialize();

  /// Updates the Now Playing metadata on the OS media overlay.
  Future<void> updateMetadata({
    required String title,
    required String artist,
    required String album,
    String? artUri,
    required int durationMs,
  }) async {}

  /// Updates the playback status on the OS media overlay.
  Future<void> updatePlaybackStatus(bool isPlaying) async {}

  /// Deregisters from the OS. Subsequent key events are no longer delivered.
  void dispose();
}

// ---------------------------------------------------------------------------
// macOS implementation — MPRemoteCommandCenter via MethodChannel
// ---------------------------------------------------------------------------

/// Receives `MPRemoteCommandCenter` events forwarded by Swift via the
/// `com.musicfse.player/media_keys` method channel.
///
/// The Swift side must implement `FlutterMethodChannel` in
/// `macos/Runner/MediaKeysPlugin.swift` and call the channel methods
/// when command centre events fire. See `NowPlayingHandler` for the
/// companion metadata side.
class _MacOsMediaKeyHandler extends MediaKeyHandler {
  _MacOsMediaKeyHandler() : super._();
  static const _channel = MethodChannel('com.musicfse.player/media_keys');

  @override
  Future<void> initialize() async {
    _channel.setMethodCallHandler(_handleMethod);
    try {
      await _channel.invokeMethod<void>('registerMediaKeys');
      AppLogger.info('macOS media keys registered', tag: 'MediaKeyHandler');
    } catch (e, st) {
      AppLogger.error(
        'MediaKeyHandler: failed to register macOS media keys',
        tag: 'MediaKeyHandler',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'play':
        onPlay?.call();
      case 'pause':
        onPause?.call();
      case 'playPause':
        onPlayPause?.call();
      case 'next':
        onNext?.call();
      case 'previous':
        onPrevious?.call();
      case 'stop':
        onStop?.call();
      default:
        AppLogger.debug(
          'MediaKeyHandler: unhandled method ${call.method}',
          tag: 'MediaKeyHandler',
        );
    }
    return null;
  }

  @override
  void dispose() {
    _channel.setMethodCallHandler(null);
  }
}

// ---------------------------------------------------------------------------
// Linux implementation — MPRIS D-Bus via MethodChannel
// ---------------------------------------------------------------------------

/// Receives MPRIS D-Bus events forwarded by a native Linux plugin via the
/// `com.musicfse.player/mpris` method channel.
///
/// The Linux host code (CMake/C++) must implement the corresponding
/// `FlMethodChannel` and route D-Bus method calls to it.
class _LinuxMediaKeyHandler extends MediaKeyHandler {
  _LinuxMediaKeyHandler() : super._();
  static const _channel = MethodChannel('com.musicfse.player/mpris');

  @override
  Future<void> initialize() async {
    _channel.setMethodCallHandler(_handleMethod);
    try {
      await _channel.invokeMethod<void>('registerMpris');
      AppLogger.info('Linux MPRIS registered', tag: 'MediaKeyHandler');
    } catch (e, st) {
      AppLogger.error(
        'MediaKeyHandler: failed to register MPRIS',
        tag: 'MediaKeyHandler',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'play':
        onPlay?.call();
      case 'pause':
        onPause?.call();
      case 'playPause':
        onPlayPause?.call();
      case 'next':
        onNext?.call();
      case 'previous':
        onPrevious?.call();
      case 'stop':
        onStop?.call();
      default:
        AppLogger.debug(
          'MediaKeyHandler: unhandled MPRIS method ${call.method}',
          tag: 'MediaKeyHandler',
        );
    }
    return null;
  }

  @override
  void dispose() {
    _channel.setMethodCallHandler(null);
  }

  @override
  Future<void> updateMetadata({
    required String title,
    required String artist,
    required String album,
    String? artUri,
    required int durationMs,
  }) async {
    try {
      await _channel.invokeMethod<void>('updateMetadata', {
        'title': title,
        'artist': artist,
        'album': album,
        'artUri': artUri,
        'durationMs': durationMs,
      });
    } catch (e) {
      AppLogger.warn('MPRIS: updateMetadata failed', tag: 'MediaKeyHandler', error: e);
    }
  }

  @override
  Future<void> updatePlaybackStatus(bool isPlaying) async {
    try {
      await _channel.invokeMethod<void>('updatePlaybackStatus', {
        'isPlaying': isPlaying,
      });
    } catch (e) {
      AppLogger.warn('MPRIS: updatePlaybackStatus failed', tag: 'MediaKeyHandler', error: e);
    }
  }
}

// ---------------------------------------------------------------------------
// No-op implementation (Windows — SMTC owns transport events there)
// ---------------------------------------------------------------------------

class _NoOpMediaKeyHandler extends MediaKeyHandler {
  _NoOpMediaKeyHandler() : super._();

  @override
  Future<void> initialize() async {}

  @override
  void dispose() {}
}
