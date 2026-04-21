import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_constants.dart';
import 'focus_highlight.dart';

/// A [Slider] widget controllable via gamepad D-pad / arrow keys.
///
/// When focused, the slider axis (left/right for horizontal, up/down for
/// vertical) adjusts the value. The perpendicular axis is left unhandled
/// so normal focus traversal continues to work.
///
/// Uses [FocusHighlight] for the standard accent-colored focus indicator.
class GamepadSlider extends StatelessWidget {
  const GamepadSlider({
    super.key,
    this.focusNode,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.step,
    this.sliderThemeData,
    this.borderRadius = 8.0,
  });

  final FocusNode? focusNode;
  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;
  final int? divisions;

  /// Step per arrow key press. Defaults to (max - min) / 20.
  final double? step;

  final SliderThemeData? sliderThemeData;
  final double borderRadius;

  double get _step {
    if (step != null) return step!;
    if (divisions != null && divisions! > 0) return (max - min) / divisions!;
    return (max - min) / 20;
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (onChanged == null) return KeyEventResult.ignored;

    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      onChanged!((value + _step).clamp(min, max));
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      onChanged!((value - _step).clamp(min, max));
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    Widget slider = Slider(
      value: value,
      min: min,
      max: max,
      divisions: divisions,
      onChanged: onChanged,
      // Prevent the Slider's internal focus from competing.
      focusNode: _NoFocusNode(),
    );

    if (sliderThemeData != null) {
      slider = SliderTheme(data: sliderThemeData!, child: slider);
    }

    return FocusHighlight(
      focusNode: focusNode,
      borderRadius: borderRadius,
      onKeyEvent: _handleKey,
      child: SizedBox(
        height: AppConstants.minFocusableSize,
        child: slider,
      ),
    );
  }
}

/// A [FocusNode] that never accepts focus, used to disable the [Slider]'s
/// built-in focus handling so [FocusHighlight] manages focus instead.
class _NoFocusNode extends FocusNode {
  _NoFocusNode() : super(skipTraversal: true, canRequestFocus: false);
}
