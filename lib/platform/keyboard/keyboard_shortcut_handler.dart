import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:window_manager/window_manager.dart';

import '../../presentation/providers/keyboard_shortcuts_provider.dart';
import '../../presentation/providers/playback_provider.dart';
import '../window/window_manager_helper.dart';

// ---------------------------------------------------------------------------
// Intent definitions — one per global keyboard action.
// These are declared here so screens can register additional handlers via
// [Actions.of(context)] if needed (e.g. to override Space while search
// input is focused).
// ---------------------------------------------------------------------------

class TogglePlayPauseIntent extends Intent {
  const TogglePlayPauseIntent();
}

class SkipNextIntent extends Intent {
  const SkipNextIntent();
}

class SkipPreviousIntent extends Intent {
  const SkipPreviousIntent();
}

class VolumeUpIntent extends Intent {
  const VolumeUpIntent();
}

class VolumeDownIntent extends Intent {
  const VolumeDownIntent();
}

class FocusSearchIntent extends Intent {
  const FocusSearchIntent();
}

class QuitAppIntent extends Intent {
  const QuitAppIntent();
}

class ToggleFullscreenIntent extends Intent {
  const ToggleFullscreenIntent();
}

// ---------------------------------------------------------------------------
// KeyboardShortcutHandler
// ---------------------------------------------------------------------------

/// Wraps [child] with a global [Shortcuts] + [Actions] tree for keyboard
/// users.
///
/// **Place once** at the root of the widget tree, inside [ProviderScope].
/// All descendant screens inherit the bindings automatically.
///
/// | Shortcut          | Action                        |
/// |-------------------|-------------------------------|
/// | Space             | Play / Pause toggle           |
/// | Ctrl + →          | Next track                    |
/// | Ctrl + ←          | Previous track                |
/// | Ctrl + ↑          | Volume up 5 %                 |
/// | Ctrl + ↓          | Volume down 5 %               |
/// | Ctrl + F  or  /   | Navigate to search            |
/// | Ctrl + Q          | Close / quit (cancelable)     |
/// | F11               | Toggle fullscreen             |
///
/// Escape is handled natively by Flutter's [NavigatorPopKeyHandler].
class KeyboardShortcutHandler extends ConsumerWidget {
  const KeyboardShortcutHandler({
    super.key,
    required this.child,
  });

  final Widget child;

  static const double _volumeStep = 0.05;

  /// Maps action IDs to their Intent types.
  static const _actionIntents = <String, Intent>{
    'playPause': TogglePlayPauseIntent(),
    'nextTrack': SkipNextIntent(),
    'previousTrack': SkipPreviousIntent(),
    'volumeUp': VolumeUpIntent(),
    'volumeDown': VolumeDownIntent(),
    'focusSearch': FocusSearchIntent(),
    'quitApp': QuitAppIntent(),
    'toggleFullscreen': ToggleFullscreenIntent(),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shortcutsAsync = ref.watch(keyboardShortcutsProvider);
    final configs = shortcutsAsync.value ?? [];

    // Build shortcuts map from configurable shortcuts
    final shortcuts = <ShortcutActivator, Intent>{};
    for (final config in configs) {
      final intent = _actionIntents[config.actionId];
      if (intent != null) {
        shortcuts[config.keySet] = intent;
      }
    }

    // Always include slash as secondary search shortcut
    shortcuts[const SingleActivator(LogicalKeyboardKey.slash)] = const FocusSearchIntent();

    return Shortcuts(
      shortcuts: shortcuts,
      child: Actions(
        actions: <Type, Action<Intent>>{
          TogglePlayPauseIntent: _TogglePlayPauseAction(ref),
          SkipNextIntent: _SkipNextAction(ref),
          SkipPreviousIntent: _SkipPreviousAction(ref),
          VolumeUpIntent: _VolumeUpAction(ref, _volumeStep),
          VolumeDownIntent: _VolumeDownAction(ref, _volumeStep),
          FocusSearchIntent: _FocusSearchAction(context),
          QuitAppIntent: _QuitAppAction(),
          ToggleFullscreenIntent: _ToggleFullscreenAction(),
        },
        child: child,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Action implementations
// ---------------------------------------------------------------------------

class _TogglePlayPauseAction extends Action<TogglePlayPauseIntent> {
  _TogglePlayPauseAction(this._ref);
  final WidgetRef _ref;

  @override
  Future<void> invoke(TogglePlayPauseIntent intent) => _ref.read(playbackProvider.notifier).togglePlayPause();
}

class _SkipNextAction extends Action<SkipNextIntent> {
  _SkipNextAction(this._ref);
  final WidgetRef _ref;

  @override
  Future<void> invoke(SkipNextIntent intent) => _ref.read(playbackProvider.notifier).skipNext();
}

class _SkipPreviousAction extends Action<SkipPreviousIntent> {
  _SkipPreviousAction(this._ref);
  final WidgetRef _ref;

  @override
  Future<void> invoke(SkipPreviousIntent intent) => _ref.read(playbackProvider.notifier).skipPrevious();
}

/// Handles [VolumeUpIntent] — increases volume by [_delta].
class _VolumeUpAction extends Action<VolumeUpIntent> {
  _VolumeUpAction(this._ref, this._delta);
  final WidgetRef _ref;
  final double _delta;

  @override
  Future<void> invoke(VolumeUpIntent intent) async {
    final current = _ref.read(playbackProvider).volume;
    await _ref.read(playbackProvider.notifier).setVolume((current + _delta).clamp(0.0, 1.0));
  }
}

/// Handles [VolumeDownIntent] — decreases volume by [_delta].
class _VolumeDownAction extends Action<VolumeDownIntent> {
  _VolumeDownAction(this._ref, this._delta);
  final WidgetRef _ref;
  final double _delta;

  @override
  Future<void> invoke(VolumeDownIntent intent) async {
    final current = _ref.read(playbackProvider).volume;
    await _ref.read(playbackProvider.notifier).setVolume((current - _delta).clamp(0.0, 1.0));
  }
}

class _FocusSearchAction extends Action<FocusSearchIntent> {
  _FocusSearchAction(this._context);
  final BuildContext _context;

  @override
  void invoke(FocusSearchIntent intent) {
    if (_context.mounted) _context.go('/search');
  }
}

class _QuitAppAction extends Action<QuitAppIntent> {
  _QuitAppAction();

  @override
  void invoke(QuitAppIntent intent) {
    // Fires AppLifecycleListener.onExitRequested so AppShell can decide
    // whether to minimise to tray or actually quit.
    windowManager.close();
  }
}

class _ToggleFullscreenAction extends Action<ToggleFullscreenIntent> {
  _ToggleFullscreenAction();

  @override
  void invoke(ToggleFullscreenIntent intent) {
    WindowManagerHelper.toggleFullscreen();
  }
}
