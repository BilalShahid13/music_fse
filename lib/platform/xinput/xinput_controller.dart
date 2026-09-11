import 'dart:async';
import 'dart:math' as math;

import 'xinput_binding.dart';

// ---------------------------------------------------------------------------
// Typed gamepad event model
// ---------------------------------------------------------------------------

/// A discrete digital button on an XInput controller.
enum GamepadButton {
  a,
  b,
  x,
  y,
  leftShoulder,
  rightShoulder,
  start,
  back,
  leftThumb,
  rightThumb,
}

/// A direction on the D-pad.
enum DpadDirection { up, down, left, right }

/// Base class for all events emitted by [XInputController].
sealed class GamepadEvent {
  const GamepadEvent();
}

/// Fired when a digital button is pressed or released.
final class GamepadButtonEvent extends GamepadEvent {
  const GamepadButtonEvent(this.button, {required this.pressed});

  final GamepadButton button;

  /// `true` = button down, `false` = button up.
  final bool pressed;
}

/// Fired when a D-pad direction is pressed or released.
final class GamepadDpadEvent extends GamepadEvent {
  const GamepadDpadEvent(this.direction, {required this.pressed});

  final DpadDirection direction;
  final bool pressed;
}

/// Fired periodically when either trigger is deflected beyond the dead zone.
///
/// Both values are in 0.0–1.0 range.
final class GamepadTriggerEvent extends GamepadEvent {
  const GamepadTriggerEvent({
    required this.leftTrigger,
    required this.rightTrigger,
  });

  final double leftTrigger;
  final double rightTrigger;
}

/// Fired periodically when a thumb-stick is outside its dead zone.
///
/// Axes are normalised to -1.0–1.0 with dead zone removed.
final class GamepadStickEvent extends GamepadEvent {
  const GamepadStickEvent({
    required this.leftX,
    required this.leftY,
    required this.rightX,
    required this.rightY,
  });

  final double leftX;
  final double leftY;
  final double rightX;
  final double rightY;
}

// ---------------------------------------------------------------------------
// XInputController — 60 Hz polling, event broadcast
// ---------------------------------------------------------------------------

/// Polls XInput at ~60 Hz and broadcasts strongly-typed [GamepadEvent]s.
///
/// Only player-1 controller (index 0) is tracked — this app is single-player.
///
/// Call [start] after creating and [stop] (or [dispose]) to clean up.
///
/// ```dart
/// final controller = XInputController(XInputBinding());
/// controller.events.listen((event) { ... });
/// controller.start();
/// ```
final class XInputController {
  XInputController(this._binding);

  final XInputBinding _binding;

  Timer? _pollTimer;
  int _previousPacket = -1;
  int _previousButtons = 0;

  final _streamController = StreamController<GamepadEvent>.broadcast();

  /// Stream of all gamepad events. Subscribe before calling [start].
  Stream<GamepadEvent> get events => _streamController.stream;

  // -------------------------------------------------------------------------
  // Lifecycle
  // -------------------------------------------------------------------------

  /// Begins polling the controller at ~60 Hz.
  ///
  /// No-op if XInput is unavailable or already started.
  void start() {
    if (!_binding.isAvailable || _pollTimer != null) return;
    _pollTimer = Timer.periodic(
      const Duration(milliseconds: 16), // ~62.5 Hz
      (_) => _poll(),
    );
  }

  /// Stops the polling timer. Safe to call multiple times.
  void stop() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  /// Stops polling and closes the event stream.
  void dispose() {
    stop();
    _streamController.close();
  }

  // -------------------------------------------------------------------------
  // Polling logic
  // -------------------------------------------------------------------------

  void _poll() {
    final state = _binding.getState(0);
    if (state == null) return; // Controller disconnected.

    final packetChanged = state.packetNumber != _previousPacket;
    _previousPacket = state.packetNumber;

    // Digital buttons only need edge-triggered updates when the device state
    // packet changes. Analog controls must continue emitting while held so
    // scrolling, seeking, and volume changes don't stall mid-deflection.
    if (packetChanged) {
      _emitButtonEvents(state.buttons);
    }
    _emitTriggerEvents(state.leftTrigger, state.rightTrigger);
    _emitStickEvents(state.thumbLX, state.thumbLY, state.thumbRX, state.thumbRY);
  }

  // -------------------------------------------------------------------------
  // Button events
  // -------------------------------------------------------------------------

  static const _digitalMappings = <int, GamepadButton>{
    XInputButtons.a: GamepadButton.a,
    XInputButtons.b: GamepadButton.b,
    XInputButtons.x: GamepadButton.x,
    XInputButtons.y: GamepadButton.y,
    XInputButtons.leftShoulder: GamepadButton.leftShoulder,
    XInputButtons.rightShoulder: GamepadButton.rightShoulder,
    XInputButtons.start: GamepadButton.start,
    XInputButtons.back: GamepadButton.back,
    XInputButtons.leftThumb: GamepadButton.leftThumb,
    XInputButtons.rightThumb: GamepadButton.rightThumb,
  };

  static const _dpadMappings = <int, DpadDirection>{
    XInputButtons.dpadUp: DpadDirection.up,
    XInputButtons.dpadDown: DpadDirection.down,
    XInputButtons.dpadLeft: DpadDirection.left,
    XInputButtons.dpadRight: DpadDirection.right,
  };

  void _emitButtonEvents(int currentButtons) {
    final changed = currentButtons ^ _previousButtons;
    if (changed == 0) {
      _previousButtons = currentButtons;
      return;
    }

    // Digital face/shoulder buttons.
    _digitalMappings.forEach((mask, button) {
      if ((changed & mask) == 0) return;
      _streamController.add(
        GamepadButtonEvent(button, pressed: (currentButtons & mask) != 0),
      );
    });

    // D-pad directions.
    _dpadMappings.forEach((mask, direction) {
      if ((changed & mask) == 0) return;
      _streamController.add(
        GamepadDpadEvent(direction, pressed: (currentButtons & mask) != 0),
      );
    });

    _previousButtons = currentButtons;
  }

  // -------------------------------------------------------------------------
  // Trigger events
  // -------------------------------------------------------------------------

  void _emitTriggerEvents(int rawLeft, int rawRight) {
    final lt = _normaliseTrigger(rawLeft);
    final rt = _normaliseTrigger(rawRight);
    if (lt > 0.0 || rt > 0.0) {
      _streamController.add(GamepadTriggerEvent(leftTrigger: lt, rightTrigger: rt));
    }
  }

  double _normaliseTrigger(int raw) {
    if (raw <= XInputDeadZones.trigger) return 0.0;
    return (raw - XInputDeadZones.trigger) / (255.0 - XInputDeadZones.trigger);
  }

  // -------------------------------------------------------------------------
  // Stick events
  // -------------------------------------------------------------------------

  void _emitStickEvents(int lx, int ly, int rx, int ry) {
    final leftX = _normaliseStick(lx);
    final leftY = _normaliseStick(ly);
    final rightX = _normaliseStick(rx);
    final rightY = _normaliseStick(ry);

    if (leftX != 0.0 || leftY != 0.0 || rightX != 0.0 || rightY != 0.0) {
      _streamController.add(
        GamepadStickEvent(
          leftX: leftX,
          leftY: leftY,
          rightX: rightX,
          rightY: rightY,
        ),
      );
    }
  }

  double _normaliseStick(int raw) {
    const dead = XInputDeadZones.thumbStick;
    if (raw.abs() <= dead) return 0.0;

    // Map [dead, 32767] → [0, 1] (or [-32768, -dead] → [-1, 0]).
    final sign = raw < 0 ? -1.0 : 1.0;
    final magnitude = raw.abs();
    final normalised = (magnitude - dead) / (32767.0 - dead);
    return sign * math.min(normalised, 1.0);
  }
}
