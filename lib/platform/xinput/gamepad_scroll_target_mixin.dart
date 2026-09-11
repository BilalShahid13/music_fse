import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'gamepad_scroll_target.dart';

mixin GamepadScrollTargetMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  late final ScrollController gamepadScrollController = ScrollController();

  @protected
  void syncGamepadScrollTarget(bool isActive) {
    if (isActive) {
      GamepadScrollTarget.set(gamepadScrollController);
    } else {
      GamepadScrollTarget.clear(gamepadScrollController);
    }
  }

  @override
  void dispose() {
    GamepadScrollTarget.clear(gamepadScrollController);
    gamepadScrollController.dispose();
    super.dispose();
  }
}