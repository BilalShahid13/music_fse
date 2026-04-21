import 'dart:ffi';
import 'dart:io' show Platform;

import 'package:ffi/ffi.dart';

// ---------------------------------------------------------------------------
// XInput Structs (packed to match Win32 memory layout)
// ---------------------------------------------------------------------------

/// Mirrors XINPUT_GAMEPAD from xinput.h.
base class XInputGamepad extends Struct {
  @Uint16()
  external int wButtons;

  @Uint8()
  external int bLeftTrigger;

  @Uint8()
  external int bRightTrigger;

  @Int16()
  external int sThumbLX;

  @Int16()
  external int sThumbLY;

  @Int16()
  external int sThumbRX;

  @Int16()
  external int sThumbRY;
}

/// Mirrors XINPUT_STATE from xinput.h.
base class XInputState extends Struct {
  @Uint32()
  external int dwPacketNumber;

  external XInputGamepad gamepad;
}

// ---------------------------------------------------------------------------
// Native function typedefs
// ---------------------------------------------------------------------------

typedef _XInputGetStateNative = Int32 Function(
  Uint32 dwUserIndex,
  Pointer<XInputState> pState,
);
typedef _XInputGetStateDart = int Function(
  int dwUserIndex,
  Pointer<XInputState> pState,
);

// ---------------------------------------------------------------------------
// XInput digital button bitmasks (wButtons field)
// ---------------------------------------------------------------------------

/// Constants for every digital button on an XInput controller.
abstract final class XInputButtons {
  static const int dpadUp = 0x0001;
  static const int dpadDown = 0x0002;
  static const int dpadLeft = 0x0004;
  static const int dpadRight = 0x0008;
  static const int start = 0x0010;
  static const int back = 0x0020;
  static const int leftThumb = 0x0040;
  static const int rightThumb = 0x0080;
  static const int leftShoulder = 0x0100;
  static const int rightShoulder = 0x0200;
  static const int a = 0x1000;
  static const int b = 0x2000;
  static const int x = 0x4000;
  static const int y = 0x8000;
}

// ---------------------------------------------------------------------------
// Analog dead-zone thresholds (per Microsoft XInput documentation)
// ---------------------------------------------------------------------------

abstract final class XInputDeadZones {
  /// Thumb-stick dead zone — smaller sticks require larger zone.
  static const int thumbStick = 7849;

  /// Trigger dead zone — values below this are treated as zero.
  static const int trigger = 30;
}

// ---------------------------------------------------------------------------
// XInputBinding — wraps xinput1_4.dll via dart:ffi
// ---------------------------------------------------------------------------

/// Low-level FFI wrapper around `xinput1_4.dll`.
///
/// Instantiate once and reuse — creating multiple instances each loads the
/// DLL. On non-Windows platforms [isAvailable] is always `false`.
///
/// Usage:
/// ```dart
/// final binding = XInputBinding();
/// if (binding.isAvailable) {
///   final state = binding.getState(0); // player 1
///   if (state != null) { /* controller connected */ }
/// }
/// ```
final class XInputBinding {
  XInputBinding() {
    if (!Platform.isWindows) return;
    try {
      final dll = DynamicLibrary.open('xinput1_4.dll');
      _getState = dll.lookupFunction<_XInputGetStateNative, _XInputGetStateDart>(
        'XInputGetState',
      );
      _isAvailable = true;
    } catch (_) {
      // DLL missing (unlikely on Windows 8+) or running under wine with no
      // xinput. Soft-fail — app functions normally without gamepad input.
      _isAvailable = false;
    }
  }

  late final _XInputGetStateDart _getState;
  bool _isAvailable = false;

  /// Whether the `xinput1_4.dll` was successfully loaded.
  bool get isAvailable => _isAvailable;

  /// Reads the current state of controller at [controllerIndex] (0–3).
  ///
  /// Returns `null` when the controller is disconnected or XInput is not
  /// available. The returned [XInputState] value is a *copy* of the struct —
  /// the underlying native memory is freed before returning.
  XInputStateSnapshot? getState(int controllerIndex) {
    if (!_isAvailable) return null;

    final pState = calloc<XInputState>();
    try {
      final result = _getState(controllerIndex, pState);
      if (result != 0) return null; // ERROR_DEVICE_NOT_CONNECTED

      final ref = pState.ref;
      return XInputStateSnapshot(
        packetNumber: ref.dwPacketNumber,
        buttons: ref.gamepad.wButtons,
        leftTrigger: ref.gamepad.bLeftTrigger,
        rightTrigger: ref.gamepad.bRightTrigger,
        thumbLX: ref.gamepad.sThumbLX,
        thumbLY: ref.gamepad.sThumbLY,
        thumbRX: ref.gamepad.sThumbRX,
        thumbRY: ref.gamepad.sThumbRY,
      );
    } finally {
      calloc.free(pState);
    }
  }
}

// ---------------------------------------------------------------------------
// XInputStateSnapshot — plain Dart copy of XInputState (GC-managed)
// ---------------------------------------------------------------------------

/// An immutable snapshot of an XInput controller state.
///
/// Created by [XInputBinding.getState] so callers never handle native pointers.
final class XInputStateSnapshot {
  const XInputStateSnapshot({
    required this.packetNumber,
    required this.buttons,
    required this.leftTrigger,
    required this.rightTrigger,
    required this.thumbLX,
    required this.thumbLY,
    required this.thumbRX,
    required this.thumbRY,
  });

  /// Increments whenever any controller state changes.
  final int packetNumber;

  /// Bitmask of pressed digital buttons. Compare against [XInputButtons].
  final int buttons;

  /// Left trigger depth: 0–255.
  final int leftTrigger;

  /// Right trigger depth: 0–255.
  final int rightTrigger;

  /// Left stick X axis: -32768 to 32767.
  final int thumbLX;

  /// Left stick Y axis: -32768 to 32767.
  final int thumbLY;

  /// Right stick X axis: -32768 to 32767.
  final int thumbRX;

  /// Right stick Y axis: -32768 to 32767.
  final int thumbRY;

  /// Returns `true` if any bit in [mask] is set in [buttons].
  bool isButtonPressed(int mask) => (buttons & mask) != 0;
}
