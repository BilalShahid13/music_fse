import 'dart:io' show Platform;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/utils/logger.dart';
import '../../domain/entities/playback_state.dart';
import '../../platform/smtc/smtc_binding.dart';
import '../../platform/smtc/smtc_controller.dart';
import '../../platform/system_tray/system_tray_handler.dart';
import '../../platform/xinput/gamepad_input_handler.dart';
import '../../platform/xinput/xinput_binding.dart';
import '../../platform/xinput/xinput_controller.dart';
import 'playback_provider.dart';

part 'platform_providers.g.dart';

// =============================================================================
// XInput Controller
// =============================================================================

/// Manages the [XInputController] + [GamepadInputHandler] lifecycle.
///
/// State is `true` when polling is active, `false` when stopped or
/// unavailable. On non-Windows platforms the controller is not created and
/// state is always `false`.
///
/// Lifecycle:
/// ```dart
/// // Start polling (resumed from background)
/// ref.read(xinputControllerNotifierProvider.notifier).start();
/// // Stop polling (app backgrounded)
/// ref.read(xinputControllerNotifierProvider.notifier).stop();
/// ```
@Riverpod(keepAlive: true)
class XInputControllerNotifier extends _$XInputControllerNotifier {
  XInputController? _controller;
  GamepadInputHandler? _handler;

  @override
  bool build() {
    ref.onDispose(_cleanup);
    if (!Platform.isWindows) return false;
    _setup();
    return _controller != null;
  }

  // -------------------------------------------------------------------------
  // Lifecycle
  // -------------------------------------------------------------------------

  void _setup() {
    final binding = XInputBinding();
    if (!binding.isAvailable) {
      AppLogger.warn(
        'XInput unavailable on this machine — gamepad support disabled',
        tag: 'XInputControllerNotifier',
      );
      return;
    }

    _controller = XInputController(binding);
    _handler = GamepadInputHandler();
    _wireCallbacks(_handler!);
    _handler!.attach(_controller!);
    _controller!.start();

    AppLogger.info('XInput polling started at ~62 Hz', tag: 'XInputControllerNotifier');
  }

  void _cleanup() {
    _handler?.dispose();
    _controller?.dispose();
    _handler = null;
    _controller = null;
    AppLogger.info('XInput resources disposed', tag: 'XInputControllerNotifier');
  }

  // -------------------------------------------------------------------------
  // Callback wiring
  // -------------------------------------------------------------------------

  /// Wires [GamepadInputHandler] action callbacks to the playback layer.
  ///
  /// Callbacks that depend on navigation context (back, context menu,
  /// favourite toggle) are intentionally left null here — individual widgets
  /// and pages handle those via their own [KeyboardListener] or by reading
  /// the [GamepadEvent] stream directly.
  void _wireCallbacks(GamepadInputHandler handler) {
    handler.onTogglePlayPause = () {
      ref.read(playbackProvider.notifier).togglePlayPause();
    };

    // LB/RB global defaults: previous/next track.
    // Tabbed pages override these by intercepting the keyboard events that
    // GamepadInputHandler injects (arrow keys from D-pad pass through Focus).
    handler.onPreviousTab = () {
      ref.read(playbackProvider.notifier).skipPrevious();
    };

    handler.onNextTab = () {
      ref.read(playbackProvider.notifier).skipNext();
    };

    // Right stick X: GamepadInputHandler emits ±5 s at full deflection.
    handler.onSeekRelative = (double seconds) {
      final ps = ref.read(playbackProvider);
      if (ps.duration == Duration.zero) return;
      final delta = Duration(milliseconds: (seconds * 1000).round());
      final raw = ps.position + delta;
      final target = raw < Duration.zero
          ? Duration.zero
          : (raw > ps.duration ? ps.duration : raw);
      ref.read(playbackProvider.notifier).seek(target);
    };
  }

  // -------------------------------------------------------------------------
  // Public control surface
  // -------------------------------------------------------------------------

  /// Resumes 60 Hz XInput polling. Call when the app returns to foreground.
  void start() {
    _controller?.start();
    if (_controller != null && !state) state = true;
  }

  /// Pauses XInput polling. Call when the app is backgrounded to save CPU.
  void stop() {
    _controller?.stop();
    if (state) state = false;
  }
}

// =============================================================================
// SMTC (System Media Transport Controls — Windows)
// =============================================================================

/// Manages the Windows SMTC overlay lifecycle and keeps it in sync with
/// [PlaybackNotifier] state.
///
/// Triggers async init on first read:
/// ```dart
/// ref.read(smtcHandlerProvider);
/// ```
///
/// On non-Windows platforms [SmtcBinding] and [SmtcController] are safe
/// no-ops (conditional import).
@Riverpod(keepAlive: true)
class SmtcHandlerNotifier extends _$SmtcHandlerNotifier {
  SmtcController? _controller;

  @override
  Future<void> build() async {
    final controller = SmtcController(SmtcBinding());

    // ── OS button → playback callbacks ──────────────────────────────────────
    controller.onPlay = () => ref.read(playbackProvider.notifier).play();
    controller.onPause = () => ref.read(playbackProvider.notifier).pause();
    controller.onNext = () => ref.read(playbackProvider.notifier).skipNext();
    controller.onPrevious = () => ref.read(playbackProvider.notifier).skipPrevious();
    controller.onSeekRelative = (double deltaSeconds) {
      final ps = ref.read(playbackProvider);
      if (ps.duration == Duration.zero) return;
      final delta = Duration(milliseconds: (deltaSeconds * 1000).round());
      final raw = ps.position + delta;
      final target = raw < Duration.zero
          ? Duration.zero
          : (raw > ps.duration ? ps.duration : raw);
      ref.read(playbackProvider.notifier).seek(target);
    };

    await controller.initialize();
    _controller = controller;
    ref.onDispose(controller.dispose);

    // ── Playback state → OS overlay ─────────────────────────────────────────
    // Sync immediately with the current state so the overlay isn't blank.
    _syncSmtc(ref.read(playbackProvider));

    // Then keep in sync on every playback state change.
    ref.listen<PlaybackState>(playbackProvider, (_, next) => _syncSmtc(next));
  }

  void _syncSmtc(PlaybackState ps) {
    final c = _controller;
    if (c == null) return;

    final song = ps.currentSong;
    if (song == null) {
      c.clearNowPlaying();
      return;
    }

    c.updateNowPlaying(
      title: song.title,
      artist: song.artist,
      album: song.album,
      // Art thumbnail is expensive to resolve here; SMTC can live without it.
    );
    c.updatePlaybackState(
      isPlaying: ps.isPlaying,
      position: ps.position,
    );
  }
}

// =============================================================================
// System tray handler
// =============================================================================

/// Manages the system-tray icon and its context menu, and routes tray actions
/// to the playback layer.
///
/// Triggers async init on first read:
/// ```dart
/// ref.read(systemTrayHandlerProvider);
/// ```
@Riverpod(keepAlive: true)
class SystemTrayHandlerNotifier extends _$SystemTrayHandlerNotifier {
  @override
  Future<void> build() async {
    final handler = SystemTrayHandler();

    // ── Tray menu → playback / window callbacks ──────────────────────────────
    handler.onTogglePlayPause = () {
      ref.read(playbackProvider.notifier).togglePlayPause();
    };
    handler.onNext = () => ref.read(playbackProvider.notifier).skipNext();
    handler.onPrevious = () => ref.read(playbackProvider.notifier).skipPrevious();
    handler.onShowWindow = () async {
      await windowManager.show();
      await windowManager.focus();
    };
    handler.onQuit = windowManager.close;

    await handler.initialize();
    ref.onDispose(handler.dispose);

    // ── Track changes → tray tooltip ────────────────────────────────────────
    ref.listen<PlaybackState>(
      playbackProvider,
      (_, next) {
        final song = next.currentSong;
        if (song != null) {
          final artist = song.artist;
          final tooltip = artist.isNotEmpty
              ? '$artist \u2014 ${song.title}'
              : song.title;
          handler.updateTooltip(tooltip);
        } else {
          handler.updateTooltip(null);
        }
      },
    );
  }
}
