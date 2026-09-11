import 'package:flutter/widgets.dart';

/// Registry for an explicit scroll target used by gamepad analog scrolling.
///
/// Some virtualized screens rebuild or recycle focused children aggressively,
/// which makes inferring the active scrollable from focus unreliable. Pages
/// with a stable primary list can register their [ScrollController] while
/// active so right-stick scrolling always targets the intended viewport.
abstract final class GamepadScrollTarget {
  static ScrollController? _controller;

  static ScrollController? get controller =>
      _controller != null && _controller!.hasClients ? _controller : null;

  static void set(ScrollController? controller) {
    _controller = controller;
  }

  static void clear(ScrollController controller) {
    if (identical(_controller, controller)) {
      _controller = null;
    }
  }
}