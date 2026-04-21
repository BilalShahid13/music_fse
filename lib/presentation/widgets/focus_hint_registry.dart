import 'package:flutter/widgets.dart';

/// Capabilities exposed by the currently focused interactive widget.
class FocusHintCapabilities {
  const FocusHintCapabilities({
    required this.node,
    required this.supportsA,
    required this.supportsX,
    required this.supportsY,
    this.onA,
    this.onX,
    this.onY,
  });

  final FocusNode node;
  final bool supportsA;
  final bool supportsX;
  final bool supportsY;
  final VoidCallback? onA;
  final VoidCallback? onX;
  final VoidCallback? onY;
}

/// Global registry updated by focusable widgets (e.g. [FocusHighlight]).
/// The shell reads this to render context-aware button hints.
final ValueNotifier<FocusHintCapabilities?> focusedHintCapabilities = ValueNotifier<FocusHintCapabilities?>(null);

void setFocusedHintCapabilities(FocusHintCapabilities capabilities) {
  focusedHintCapabilities.value = capabilities;
}

void clearFocusedHintCapabilitiesIfNode(FocusNode node) {
  final current = focusedHintCapabilities.value;
  if (current == null) return;
  if (identical(current.node, node)) {
    focusedHintCapabilities.value = null;
  }
}
