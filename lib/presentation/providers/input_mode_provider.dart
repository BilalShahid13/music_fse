import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'input_mode_provider.g.dart';

enum InputMode { gamepad, keyboard, mouse }

@Riverpod(keepAlive: true)
class InputModeNotifier extends _$InputModeNotifier {
  @override
  InputMode build() => InputMode.keyboard;

  void onMouseMove() {
    // Never switch to mouse mode — focus indicators and the current focus
    // element must remain visible at all times (gamepad-first design).
  }

  void onKeyboardInput() {
    if (state != InputMode.keyboard) {
      state = InputMode.keyboard;
    }
  }

  void onGamepadInput() {
    if (state != InputMode.gamepad) {
      state = InputMode.gamepad;
    }
  }

  bool get showFocusIndicators => state != InputMode.mouse;
}
