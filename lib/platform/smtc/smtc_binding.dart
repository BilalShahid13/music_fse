import 'dart:async';
import 'dart:io' show Platform;

// Conditional import: smtc_windows is a Windows-only package.
// On other platforms the class is replaced by a no-op stub.
import 'package:smtc_windows/smtc_windows.dart' if (dart.library.html) 'smtc_stub.dart';

import '../../core/utils/logger.dart';

// ---------------------------------------------------------------------------
// SmtcBinding — thin wrapper around the smtc_windows package
// ---------------------------------------------------------------------------

/// Thin, testable wrapper around [SMTCWindows].
///
/// Responsible only for:
///   1. Creating and configuring the [SMTCWindows] instance.
///   2. Exposing [buttonPressStream] so [SmtcController] can react to OS
///      media transport events.
///   3. Providing typed update methods for metadata and playback state.
///
/// On non-Windows platforms every method is a safe no-op.
final class SmtcBinding {
  SMTCWindows? _smtc;

  bool get isAvailable => Platform.isWindows && _smtc != null;

  // -------------------------------------------------------------------------
  // Lifecycle
  // -------------------------------------------------------------------------

  /// Initialises the SMTC session.
  ///
  /// Must be called on the main isolate. Safe to await at app startup.
  Future<void> initialize() async {
    if (!Platform.isWindows) return;

    try {
      _smtc = SMTCWindows(
        config: const SMTCConfig(
          fastForwardEnabled: true,
          rewindEnabled: true,
          nextEnabled: true,
          prevEnabled: true,
          playEnabled: true,
          pauseEnabled: true,
          stopEnabled: false,
        ),
      );
      AppLogger.info('SMTC initialised', tag: 'SmtcBinding');
    } catch (e, st) {
      AppLogger.error(
        'SmtcBinding: failed to initialise SMTC',
        tag: 'SmtcBinding',
        error: e,
        stackTrace: st,
      );
      _smtc = null;
    }
  }

  /// Stream of transport control button presses from the OS / lock screen.
  Stream<PressedButton>? get buttonPressStream => _smtc?.buttonPressStream;

  // -------------------------------------------------------------------------
  // Metadata update
  // -------------------------------------------------------------------------

  /// Updates the SMTC metadata overlay (title bar, lock screen, taskbar).
  ///
  /// [artFilePath] should be an absolute file-system path to the album art
  /// thumbnail (the cached 300×300 PNG). Pass `null` when no art is available.
  void updateMetadata({
    required String title,
    required String artist,
    required String album,
    String? artFilePath,
  }) {
    if (_smtc == null) return;
    try {
      _smtc!.updateMetadata(MusicMetadata(
        title: title,
        artist: artist,
        album: album,
        thumbnail: artFilePath != null ? 'file://$artFilePath' : null,
      ));
    } catch (e) {
      AppLogger.warn('SmtcBinding: updateMetadata failed', tag: 'SmtcBinding', error: e);
    }
  }

  // -------------------------------------------------------------------------
  // Playback state update
  // -------------------------------------------------------------------------

  /// Updates the SMTC playback status.
  void updatePlaybackStatus({required bool isPlaying}) {
    if (_smtc == null) return;
    try {
      _smtc!.setPlaybackStatus(
        isPlaying ? PlaybackStatus.playing : PlaybackStatus.paused,
      );
    } catch (e) {
      AppLogger.warn('SmtcBinding: updatePlaybackStatus failed', tag: 'SmtcBinding', error: e);
    }
  }

  /// Updates the SMTC playback position (for the seek bar in the OS overlay).
  void updatePosition(Duration position) {
    if (_smtc == null) return;
    try {
      _smtc!.setPosition(position);
    } catch (e) {
      AppLogger.warn('SmtcBinding: updatePosition failed', tag: 'SmtcBinding', error: e);
    }
  }

  // -------------------------------------------------------------------------
  // Cleanup
  // -------------------------------------------------------------------------

  void dispose() {
    try {
      _smtc?.dispose();
    } catch (e) {
      AppLogger.debug('SmtcBinding: dispose failed', tag: 'SmtcBinding', error: e);
    }
    _smtc = null;
  }
}
