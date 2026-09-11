import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

// ---------------------------------------------------------------------------
// KeyboardGamepadEmulator
// ---------------------------------------------------------------------------

/// Translates keyboard letter keys into gamepad-equivalent actions so the
/// app can be tested on macOS (or Linux) without a physical XInput controller.
///
/// **Mapping:**
///
/// | Key | Emulated gamepad button | Notes |
/// |-----|------------------------|-------|
/// | A | gameButtonA (Enter) | Select / Confirm |
/// | B | Escape | Back / Cancel |
/// | X | gameButtonX | Context menu |
/// | Y | gameButtonY | Toggle favourite |
/// | Q | gameButtonLeft1 (LB) | Previous tab / track |
/// | E | gameButtonRight1 (RB) | Next tab / track |
/// | P | gameButtonStart | Play/Pause toggle |
///
/// Arrow keys already map naturally to D-pad via Flutter's focus system.
///
/// When the currently focused widget is an [EditableText] (text field), the
/// emulator is disabled so normal typing works.
///
/// Place this widget once near the root of the widget tree, wrapping the
/// main content. Uses a root-level [Focus] with `onKeyEvent` to intercept
/// mapped letter keys and dispatch the emulated key events via a
/// post-frame callback (avoids re-entrancy with [HardwareKeyboard]).
class KeyboardGamepadEmulator extends StatelessWidget {
  const KeyboardGamepadEmulator({super.key, required this.child});

  final Widget child;

  /// Map from keyboard letter key → emulated gamepad key pair.
  /// For A and B we inject Enter / Escape instead because that's what
  /// [GamepadInputHandler] does and all widgets already handle those.
  static final _keyMap = <LogicalKeyboardKey, _EmulatedKey>{
    LogicalKeyboardKey.keyA: const _EmulatedKey(
      LogicalKeyboardKey.enter,
      PhysicalKeyboardKey.enter,
    ),
    LogicalKeyboardKey.keyB: const _EmulatedKey(
      LogicalKeyboardKey.escape,
      PhysicalKeyboardKey.escape,
    ),
    LogicalKeyboardKey.keyX: const _EmulatedKey(
      LogicalKeyboardKey.gameButtonX,
      PhysicalKeyboardKey.gameButtonX,
    ),
    LogicalKeyboardKey.keyY: const _EmulatedKey(
      LogicalKeyboardKey.gameButtonY,
      PhysicalKeyboardKey.gameButtonY,
    ),
    LogicalKeyboardKey.keyQ: const _EmulatedKey(
      LogicalKeyboardKey.gameButtonLeft1,
      PhysicalKeyboardKey.gameButtonLeft1,
    ),
    LogicalKeyboardKey.keyE: const _EmulatedKey(
      LogicalKeyboardKey.gameButtonRight1,
      PhysicalKeyboardKey.gameButtonRight1,
    ),
    LogicalKeyboardKey.keyP: const _EmulatedKey(
      LogicalKeyboardKey.gameButtonStart,
      PhysicalKeyboardKey.gameButtonStart,
    ),
  };

  /// Returns `true` if the currently focused widget is an [EditableText]
  /// (i.e. a text input). We must not intercept letter keys in that case.
  static bool get _isTextFieldFocused {
    final focus = FocusManager.instance.primaryFocus;
    if (focus == null) return false;
    final ctx = focus.context;
    if (ctx == null) return false;
    bool found = false;
    ctx.visitAncestorElements((element) {
      if (element.widget is EditableText) {
        found = true;
        return false;
      }
      return true;
    });
    return found;
  }

  /// Dispatch the emulated key event on the next microtask to avoid
  /// re-entrancy with Flutter's key event pipeline.
  static void _scheduleKeyEvent(KeyEvent event) {
    Future.microtask(() {
      // Dispatch via the current focus tree.
      final primary = FocusManager.instance.primaryFocus;
      if (primary != null) {
        // Walk up from the primary focus, letting each node handle the event.
        _dispatchToFocusTree(primary, event);
      }
    });
  }

  /// Walk the focus tree from [node] upward, dispatching [event] to each
  /// node's onKeyEvent handler until one consumes it.
  static void _dispatchToFocusTree(FocusNode node, KeyEvent event) {
    FocusNode? current = node;
    while (current != null) {
      final result = current.onKeyEvent?.call(current, event);
      if (result == KeyEventResult.handled) return;
      current = current.parent;
    }
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    // Don't intercept when typing in a text field.
    if (_isTextFieldFocused) return KeyEventResult.ignored;

    // Don't intercept if any modifier is held (allow Ctrl+A, Cmd+B, etc.).
    if (HardwareKeyboard.instance.isControlPressed || HardwareKeyboard.instance.isMetaPressed || HardwareKeyboard.instance.isAltPressed) {
      return KeyEventResult.ignored;
    }

    final mapped = _keyMap[event.logicalKey];
    if (mapped == null) return KeyEventResult.ignored;

    if (event is KeyDownEvent) {
      _scheduleKeyEvent(KeyDownEvent(
        physicalKey: mapped.physical,
        logicalKey: mapped.logical,
        timeStamp: event.timeStamp,
        synthesized: true,
      ));
      return KeyEventResult.handled;
    }

    if (event is KeyRepeatEvent) {
      _scheduleKeyEvent(KeyDownEvent(
        physicalKey: mapped.physical,
        logicalKey: mapped.logical,
        timeStamp: event.timeStamp,
        synthesized: true,
      ));
      return KeyEventResult.handled;
    }

    if (event is KeyUpEvent) {
      _scheduleKeyEvent(KeyUpEvent(
        physicalKey: mapped.physical,
        logicalKey: mapped.logical,
        timeStamp: event.timeStamp,
        synthesized: true,
      ));
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: false,
      canRequestFocus: false,
      onKeyEvent: _handleKey,
      child: child,
    );
  }
}

/// A pair of logical + physical keys representing the emulated gamepad button.
class _EmulatedKey {
  const _EmulatedKey(this.logical, this.physical);
  final LogicalKeyboardKey logical;
  final PhysicalKeyboardKey physical;
}
