import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:smtc_windows/smtc_windows.dart' if (dart.library.html) 'smtc_stub.dart';

import '../../core/utils/logger.dart';
import 'smtc_binding.dart';

// ---------------------------------------------------------------------------
// SmtcController — high-level SMTC interface consumed by providers
// ---------------------------------------------------------------------------

/// High-level adapter between the app's playback state and the Windows System
/// Media Transport Controls (SMTC) surface.
///
/// **Architecture**: Belongs to the platform layer. Zero Riverpod dependency.
/// Callers (a keepAlive Riverpod provider) wire up action callbacks:
///
/// ```dart
/// smtcController.onPlay     = () => playbackNotifier.play();
/// smtcController.onPause    = () => playbackNotifier.pause();
/// smtcController.onNext     = () => playbackNotifier.skipNext();
/// smtcController.onPrevious = () => playbackNotifier.skipPrevious();
/// smtcController.onSeekRelative = (delta) => playbackNotifier.seek(...);
/// await smtcController.initialize();
/// ```
///
/// The presentation layer should call [updateNowPlaying], [updatePlaybackState],
/// and [clearNowPlaying] as the playback state changes.
final class SmtcController {
  SmtcController(this._binding);

  final SmtcBinding _binding;
  StreamSubscription<PressedButton>? _buttonSub;

  // -------------------------------------------------------------------------
  // Action callbacks (presentation layer provides these)
  // -------------------------------------------------------------------------

  VoidCallback? onPlay;
  VoidCallback? onPause;
  VoidCallback? onNext;
  VoidCallback? onPrevious;

  /// Seek forward (+) or backward (−) by [delta] seconds.
  void Function(double delta)? onSeekRelative;

  // -------------------------------------------------------------------------
  // Lifecycle
  // -------------------------------------------------------------------------

  Future<void> initialize() async {
    await _binding.initialize();

    final buttonStream = _binding.buttonPressStream;
    if (buttonStream == null) return; // Non-Windows platform.

    _buttonSub = buttonStream.listen(_handleButtonPress, onError: (Object e) {
      AppLogger.warn(
        'SmtcController: buttonPressStream error',
        tag: 'SmtcController',
        error: e,
      );
    });
  }

  void dispose() {
    _buttonSub?.cancel();
    _buttonSub = null;
    _binding.dispose();
  }

  // -------------------------------------------------------------------------
  // OS button events → callbacks
  // -------------------------------------------------------------------------

  void _handleButtonPress(PressedButton button) {
    switch (button) {
      case PressedButton.play:
        onPlay?.call();
      case PressedButton.pause:
        onPause?.call();
      case PressedButton.next:
        onNext?.call();
      case PressedButton.previous:
        onPrevious?.call();
      case PressedButton.fastForward:
        onSeekRelative?.call(10.0);
      case PressedButton.rewind:
        onSeekRelative?.call(-10.0);
      default:
        break;
    }
  }

  // -------------------------------------------------------------------------
  // Playback state → OS overlay
  // -------------------------------------------------------------------------

  /// Pushes current track metadata to the OS media overlay.
  ///
  /// Call whenever the current song changes.
  void updateNowPlaying({
    required String title,
    required String artist,
    required String album,
    String? artFilePath,
  }) {
    _binding.updateMetadata(
      title: title,
      artist: artist,
      album: album,
      artFilePath: artFilePath,
    );
  }

  /// Pushes play/pause state and seek position to the OS overlay.
  ///
  /// Call on every position tick and whenever play/pause toggles.
  void updatePlaybackState({
    required bool isPlaying,
    required Duration position,
  }) {
    _binding.updatePlaybackStatus(isPlaying: isPlaying);
    _binding.updatePosition(position);
  }

  /// Resets the SMTC overlay to an idle state (no track loaded).
  void clearNowPlaying() {
    _binding.updateMetadata(
      title: '',
      artist: '',
      album: '',
    );
    _binding.updatePlaybackStatus(isPlaying: false);
  }
}
