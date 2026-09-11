import 'package:flutter/scheduler.dart';
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

class QueuePanelHintState {
  const QueuePanelHintState({
    this.aLabel,
    this.bLabel,
    this.xLabel,
    this.yLabel,
    this.upLabel,
    this.downLabel,
    this.onAPressed,
    this.onBPressed,
    this.onXPressed,
    this.onYPressed,
    this.onUpPressed,
    this.onDownPressed,
  });

  final String? aLabel;
  final String? bLabel;
  final String? xLabel;
  final String? yLabel;
  final String? upLabel;
  final String? downLabel;
  final VoidCallback? onAPressed;
  final VoidCallback? onBPressed;
  final VoidCallback? onXPressed;
  final VoidCallback? onYPressed;
  final VoidCallback? onUpPressed;
  final VoidCallback? onDownPressed;
}

/// Global registry updated by focusable widgets (e.g. [FocusHighlight]).
/// The shell reads this to render context-aware button hints.
final ValueNotifier<FocusHintCapabilities?> focusedHintCapabilities = ValueNotifier<FocusHintCapabilities?>(null);
FocusHintCapabilities? _pendingFocusedHintCapabilities;
bool _focusedHintUpdateScheduled = false;

final ValueNotifier<QueuePanelHintState?> queuePanelHintState = ValueNotifier<QueuePanelHintState?>(null);
QueuePanelHintState? _pendingQueuePanelHintState;
bool _queuePanelHintUpdateScheduled = false;

void setFocusedHintCapabilities(FocusHintCapabilities capabilities) {
  _setFocusedHintCapabilitiesDeferred(capabilities);
}

void clearFocusedHintCapabilitiesIfNode(FocusNode node) {
  final current = focusedHintCapabilities.value;
  final pending = _pendingFocusedHintCapabilities;
  if (identical(current?.node, node) || identical(pending?.node, node)) {
    _setFocusedHintCapabilitiesDeferred(null);
  }
}

void _setFocusedHintCapabilitiesDeferred(FocusHintCapabilities? capabilities) {
  final phase = SchedulerBinding.instance.schedulerPhase;
  final canNotifyNow =
      phase == SchedulerPhase.idle || phase == SchedulerPhase.postFrameCallbacks;

  if (canNotifyNow) {
    _pendingFocusedHintCapabilities = null;
    _focusedHintUpdateScheduled = false;
    if (focusedHintCapabilities.value != capabilities) {
      focusedHintCapabilities.value = capabilities;
    }
    return;
  }

  _pendingFocusedHintCapabilities = capabilities;
  if (_focusedHintUpdateScheduled) return;

  _focusedHintUpdateScheduled = true;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _focusedHintUpdateScheduled = false;
    final pendingState = _pendingFocusedHintCapabilities;
    _pendingFocusedHintCapabilities = null;
    if (focusedHintCapabilities.value != pendingState) {
      focusedHintCapabilities.value = pendingState;
    }
  });
}

void setQueuePanelHintState(QueuePanelHintState? state) {
  final phase = SchedulerBinding.instance.schedulerPhase;
  final canNotifyNow =
      phase == SchedulerPhase.idle || phase == SchedulerPhase.postFrameCallbacks;

  if (canNotifyNow) {
    _pendingQueuePanelHintState = null;
    _queuePanelHintUpdateScheduled = false;
    if (queuePanelHintState.value != state) {
      queuePanelHintState.value = state;
    }
    return;
  }

  _pendingQueuePanelHintState = state;
  if (_queuePanelHintUpdateScheduled) return;

  _queuePanelHintUpdateScheduled = true;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _queuePanelHintUpdateScheduled = false;
    final pendingState = _pendingQueuePanelHintState;
    _pendingQueuePanelHintState = null;
    if (queuePanelHintState.value != pendingState) {
      queuePanelHintState.value = pendingState;
    }
  });
}
