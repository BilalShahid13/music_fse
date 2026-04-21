import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_fse/presentation/providers/input_mode_provider.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() => container.dispose());

  test('defaults to keyboard mode', () {
    final mode = container.read(inputModeProvider);
    expect(mode, InputMode.keyboard);
  });

  test('onMouseMove switches to mouse', () {
    container.read(inputModeProvider.notifier).onMouseMove();
    expect(container.read(inputModeProvider), InputMode.mouse);
  });

  test('onGamepadInput switches to gamepad', () {
    container.read(inputModeProvider.notifier).onGamepadInput();
    expect(container.read(inputModeProvider), InputMode.gamepad);
  });

  test('onKeyboardInput switches back to keyboard', () {
    container.read(inputModeProvider.notifier).onGamepadInput();
    container.read(inputModeProvider.notifier).onKeyboardInput();
    expect(container.read(inputModeProvider), InputMode.keyboard);
  });

  test('showFocusIndicators is false for mouse', () {
    container.read(inputModeProvider.notifier).onMouseMove();
    expect(
      container.read(inputModeProvider.notifier).showFocusIndicators,
      false,
    );
  });

  test('showFocusIndicators is true for gamepad', () {
    container.read(inputModeProvider.notifier).onGamepadInput();
    expect(
      container.read(inputModeProvider.notifier).showFocusIndicators,
      true,
    );
  });

  test('repeated same mode does not trigger rebuild', () {
    var callCount = 0;
    container.listen(inputModeProvider, (_, __) => callCount++);
    container.read(inputModeProvider.notifier).onKeyboardInput();
    expect(callCount, 0); // already in keyboard mode
  });
}
