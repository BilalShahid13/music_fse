import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../core/utils/logger.dart';
import 'xinput_controller.dart';

// ---------------------------------------------------------------------------
// GamepadInputHandler — bridges XInputController with Flutter's input system
// ---------------------------------------------------------------------------

/// Translates [GamepadEvent]s from [XInputController] into Flutter focus
/// traversal calls, synthesised key events, and high-level action callbacks.
///
/// **Architecture**: This class belongs to the platform layer and has zero
/// dependency on Riverpod. Callers (e.g. a top-level Riverpod provider or an
/// AppShell widget) wire up the action callbacks:
///
/// ```dart
/// handler.onTogglePlayPause = () => ref.read(playbackProvider.notifier).togglePlayPause();
/// handler.onSkipNext        = () => ref.read(playbackProvider.notifier).skipNext();
/// // …
/// handler.attach(controller);
/// ```
///
/// D-pad directions are forwarded directly to Flutter's [FocusManager] so
/// existing focus traversal continues to work without modification.
///
/// A / Enter → activates the primary focused element via a synthesised Enter
/// key event, which every [FocusHighlight] already handles.
///
/// B / Escape → triggers [onBack] (presentation layer navigates back).
///
/// X → triggers [onContextMenu].
///
/// Y → triggers [onToggleFavorite].
///
/// LB / RB → triggers [onPreviousTab] / [onNextTab].
///
/// Start → toggles play/pause.
///
/// LT / RT (triggers) → adjust volume via [onVolumeChange] (delta ±5 %).
///
/// Left Stick → scrollable list navigation (forwarded as arrow key events).
///
/// Right Stick X → seek relative via [onSeekRelative] (±10 s per full deflection).
final class GamepadInputHandler {
  GamepadInputHandler();

  static const _dpadInitialRepeatDelay = Duration(milliseconds: 280);
  static const _dpadRepeatInterval = Duration(milliseconds: 90);

  // -------------------------------------------------------------------------
  // Configurable callbacks (presentation layer wires these up)
  // -------------------------------------------------------------------------

  /// Called when the Start button is pressed.
  VoidCallback? onTogglePlayPause;

  /// Called when the Back/Select button is pressed.
  VoidCallback? onBack;

  /// Called when the X button is pressed (context menu).
  VoidCallback? onContextMenu;

  /// Called when the Y button is pressed (toggle favourite).
  VoidCallback? onToggleFavorite;

  /// Called when LB is pressed (previous tab / previous track).
  VoidCallback? onPreviousTab;

  /// Called when RB is pressed (next tab / next track).
  VoidCallback? onNextTab;

  /// Called repeatedly while LT/RT are held.
  /// [delta] is −1.0 (full LT = volume down) to +1.0 (full RT = volume up).
  void Function(double delta)? onVolumeChange;

  /// Called when the right stick X axis is deflected.
  /// [seconds] is how many seconds to seek (positive = forward, negative = back).
  void Function(double seconds)? onSeekRelative;

  // -------------------------------------------------------------------------
  // Internal state
  // -------------------------------------------------------------------------

  StreamSubscription<GamepadEvent>? _sub;
  final Map<DpadDirection, Timer> _dpadRepeatTimers = <DpadDirection, Timer>{};

  // Debounce left-stick D-pad repeats so they don't fire at 60 Hz.
  DateTime _lastLeftStickX = DateTime(0);
  DateTime _lastLeftStickY = DateTime(0);
  static const _stickNavDebounce = Duration(milliseconds: 150);

  // -------------------------------------------------------------------------
  // Lifecycle
  // -------------------------------------------------------------------------

  /// Starts listening to [controller] events.
  void attach(XInputController controller) {
    _sub?.cancel();
    _sub = controller.events.listen(_handle);
  }

  /// Stops listening to events. Safe to call multiple times.
  void detach() {
    _sub?.cancel();
    _sub = null;
    _cancelAllDpadRepeats();
  }

  void dispose() {
    detach();
  }

  // -------------------------------------------------------------------------
  // Event dispatch
  // -------------------------------------------------------------------------

  void _handle(GamepadEvent event) {
    switch (event) {
      case GamepadButtonEvent(:final button, :final pressed):
        _handleButton(button, pressed);
      case GamepadDpadEvent(:final direction, :final pressed):
        _handleDpadEvent(direction, pressed);
      case GamepadTriggerEvent(:final leftTrigger, :final rightTrigger):
        _handleTriggers(leftTrigger, rightTrigger);
      case GamepadStickEvent(:final leftX, :final leftY, :final rightX, :final rightY):
        _handleSticks(leftX, leftY, rightX, rightY);
    }
  }

  void _handleButton(GamepadButton button, bool pressed) {
    if (!pressed) return; // Only act on button-down events.

    switch (button) {
      case GamepadButton.a:
        _injectKey(LogicalKeyboardKey.enter, PhysicalKeyboardKey.enter);
      case GamepadButton.b:
        onBack?.call();
        _injectKey(LogicalKeyboardKey.escape, PhysicalKeyboardKey.escape);
      case GamepadButton.x:
        onContextMenu?.call();
      case GamepadButton.y:
        onToggleFavorite?.call();
      case GamepadButton.leftShoulder:
        onPreviousTab?.call();
      case GamepadButton.rightShoulder:
        onNextTab?.call();
      case GamepadButton.start:
        onTogglePlayPause?.call();
      case GamepadButton.back:
        // Back/Select → open search (same as Ctrl+F keyboard shortcut).
        _injectKey(LogicalKeyboardKey.slash, PhysicalKeyboardKey.slash);
      case GamepadButton.leftThumb:
      case GamepadButton.rightThumb:
        break; // Not used globally; individual screens may handle via events.
    }
  }

  void _handleDpad(DpadDirection direction) {
    final key = switch (direction) {
      DpadDirection.up => (
          logical: LogicalKeyboardKey.arrowUp,
          physical: PhysicalKeyboardKey.arrowUp,
        ),
      DpadDirection.down => (
          logical: LogicalKeyboardKey.arrowDown,
          physical: PhysicalKeyboardKey.arrowDown,
        ),
      DpadDirection.left => (
          logical: LogicalKeyboardKey.arrowLeft,
          physical: PhysicalKeyboardKey.arrowLeft,
        ),
      DpadDirection.right => (
          logical: LogicalKeyboardKey.arrowRight,
          physical: PhysicalKeyboardKey.arrowRight,
        ),
    };

    final primary = FocusManager.instance.primaryFocus;
    AppLogger.debug(
      'Dpad ${direction.name} -> inject ${key.logical.keyLabel}, primary=${primary?.debugLabel ?? primary?.runtimeType}',
      tag: 'GamepadInput',
    );

    // Always inject arrow keys so gamepad D-pad follows the exact same
    // navigation pipeline as keyboard arrows (shell routing + widget handlers).
    _injectKey(key.logical, key.physical);
  }

  void _handleDpadEvent(DpadDirection direction, bool pressed) {
    if (pressed) {
      _handleDpad(direction);
      _startDpadRepeat(direction);
      return;
    }

    _stopDpadRepeat(direction);
  }

  void _startDpadRepeat(DpadDirection direction) {
    _stopDpadRepeat(direction);
    _dpadRepeatTimers[direction] = Timer(_dpadInitialRepeatDelay, () {
      _handleDpad(direction);
      _dpadRepeatTimers[direction] = Timer.periodic(_dpadRepeatInterval, (_) {
        _handleDpad(direction);
      });
    });
  }

  void _stopDpadRepeat(DpadDirection direction) {
    _dpadRepeatTimers.remove(direction)?.cancel();
  }

  void _cancelAllDpadRepeats() {
    for (final timer in _dpadRepeatTimers.values) {
      timer.cancel();
    }
    _dpadRepeatTimers.clear();
  }

  void _handleTriggers(double left, double right) {
    final delta = right - left; // positive = volume up, negative = volume down
    if (delta.abs() < 0.05) return; // Ignore noise near zero crossing.
    // Scale so full trigger deflection = ±5 % per poll tick (mapped in caller).
    onVolumeChange?.call(delta * 0.05);
  }

  void _handleSticks(double leftX, double leftY, double rightX, double rightY) {
    final now = DateTime.now();

    // ── Left stick → D-pad navigation (all 4 directions, debounced) ─────
    if (leftY.abs() > 0.3 && now.difference(_lastLeftStickY) >= _stickNavDebounce) {
      _handleDpad(leftY > 0 ? DpadDirection.up : DpadDirection.down);
      _lastLeftStickY = now;
    }

    if (leftX.abs() > 0.3 && now.difference(_lastLeftStickX) >= _stickNavDebounce) {
      _handleDpad(leftX > 0 ? DpadDirection.right : DpadDirection.left);
      _lastLeftStickX = now;
    }

    // ── Right stick Y → vertical scroll ─────────────────────────────────
    if (rightY.abs() > 0.2) {
      _scrollVertically(-rightY);
    }

    // ── Right stick X → seek relative ───────────────────────────────────
    if (rightX.abs() > 0.3) {
      onSeekRelative?.call(rightX * 10.0);
    }
  }

  /// Injects a [PointerScrollEvent] at the focused widget's position so any
  /// ancestor [Scrollable] receives a scroll delta.
  ///
  /// [normalizedDelta] ranges from roughly −1.0 to +1.0. Positive = scroll
  /// down (content moves up), negative = scroll up.
  void _scrollVertically(double normalizedDelta) {
    // Target the focused widget's position so the hit-test finds the correct
    // scrollable ancestor.
    Offset position = const Offset(400, 300);
    final focusNode = FocusManager.instance.primaryFocus;
    if (focusNode?.context != null) {
      try {
        final box = focusNode!.context!.findRenderObject() as RenderBox?;
        if (box != null && box.hasSize) {
          position = box.localToGlobal(box.size.center(Offset.zero));
        }
      } catch (_) {
        // Node not yet laid out — use fallback position.
      }
    }

    WidgetsBinding.instance.handlePointerEvent(
      PointerScrollEvent(
        position: position,
        scrollDelta: Offset(0, normalizedDelta * 15.0),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Key event injection
  // -------------------------------------------------------------------------

  /// Injects a synthetic [KeyDownEvent] into Flutter's hardware keyboard
  /// pipeline so widgets that already handle keyboard input (including
  /// [FocusHighlight]) respond naturally.
  ///
  /// A paired [KeyUpEvent] is injected on the next microtask to complete the
  /// key lifecycle.
  void _injectKey(
    LogicalKeyboardKey logicalKey,
    PhysicalKeyboardKey physicalKey,
  ) {
    final timestamp = ServicesBinding.instance.currentSystemFrameTimeStamp;

    HardwareKeyboard.instance.handleKeyEvent(
      KeyDownEvent(
        physicalKey: physicalKey,
        logicalKey: logicalKey,
        timeStamp: timestamp,
        synthesized: true,
      ),
    );

    // Schedule the key-up one microtask later so widgets see a full press cycle.
    Future.microtask(() {
      if (!HardwareKeyboard.instance.isLogicalKeyPressed(logicalKey)) return;
      HardwareKeyboard.instance.handleKeyEvent(
        KeyUpEvent(
          physicalKey: physicalKey,
          logicalKey: logicalKey,
          timeStamp: ServicesBinding.instance.currentSystemFrameTimeStamp,
          synthesized: true,
        ),
      );
    });
  }
}
