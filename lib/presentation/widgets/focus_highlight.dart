import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../platform/nav_sounds/nav_sound_player.dart';
import '../providers/input_mode_provider.dart';
import '../providers/nav_sound_provider.dart';
import 'focus_hint_registry.dart';

bool _hasSuppressedInitialNavigateSound = false;
bool _shouldSuppressNextNavigateSound = false;

void suppressNextNavigateSound() {
  _shouldSuppressNextNavigateSound = true;
}

/// Single source of truth for the focus indicator used throughout the app.
///
/// Wraps [child] in a [Focus] widget and renders a 3px accent-colored border
/// with a glow shadow and a scale transition (150ms easeOut) whenever the
/// node is focused.
///
/// Spec (REQUIREMENTS §6.4 / CLAUDE.md §2.1):
/// - 3px accent border
/// - Accent glow: rgba(accent, 0.3) blur 12px
/// - Scale: 1.02× for tiles, 1.05× for cards ([isCard] = true)
/// - 150ms easeOut transition
///
/// Pass [onPressed] to handle the A button (Enter/Space or gamepad A).
/// Pass [onSecondary] to handle the X button (gamepad X — context menu).
class FocusHighlight extends ConsumerStatefulWidget {
  const FocusHighlight({
    super.key,
    this.focusNode,
    required this.child,
    this.borderRadius = AppConstants.cardRadius,
    this.padding = EdgeInsets.zero,
    this.onPressed,
    this.onSecondary,
    this.onTertiary,
    this.onKeyEvent,
    this.canRequestFocus = true,
    this.isCard = false,
    this.skipTraversal = false,
    this.showYHint = false,
    this.isCircular = false,
  });

  final FocusNode? focusNode;
  final Widget child;

  /// Border radius of the focus ring. Defaults to [AppConstants.cardRadius].
  final double borderRadius;

  /// Optional inner padding applied between the border decoration and [child].
  final EdgeInsets padding;

  /// Triggered by the A button (Enter, Space, or gamepad A).
  final VoidCallback? onPressed;

  /// Triggered by the X button (gamepad X). Typically opens a context menu.
  final VoidCallback? onSecondary;

  /// Triggered by the Y button (gamepad Y). Typically toggles favorite.
  final VoidCallback? onTertiary;

  /// Optional key event handler called before the built-in A/X handling.
  /// Return [KeyEventResult.handled] to consume the event.
  final FocusOnKeyEventCallback? onKeyEvent;

  /// Whether the focus node can accept focus from traversal.
  final bool canRequestFocus;

  /// When true, applies 1.05× scale instead of 1.02× (for grid cards).
  final bool isCard;

  /// When true, the node is excluded from focus traversal order.
  final bool skipTraversal;

  /// Whether this focused widget supports the Y button action.
  final bool showYHint;

  /// When true, uses [BoxShape.circle] for the focus border instead of
  /// [BorderRadius]. Ensures perfectly round focus indicators on circular buttons.
  final bool isCircular;

  @override
  ConsumerState<FocusHighlight> createState() => _FocusHighlightState();
}

class _FocusHighlightState extends ConsumerState<FocusHighlight> {
  bool _hasFocus = false;
  FocusNode? _internalFocusNode;

  FocusNode get _effectiveFocusNode => widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _effectiveFocusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(FocusHighlight oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldNode = oldWidget.focusNode ?? _internalFocusNode!;
    final newNode = _effectiveFocusNode;
    if (oldNode != newNode) {
      oldNode.removeListener(_onFocusChange);
      newNode.addListener(_onFocusChange);
    }
  }

  @override
  void dispose() {
    _effectiveFocusNode.removeListener(_onFocusChange);
    _internalFocusNode?.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!mounted) return;
    final hasFocus = _effectiveFocusNode.hasFocus;
    if (_hasFocus == hasFocus) return;
    setState(() => _hasFocus = hasFocus);
    if (hasFocus) {
      setFocusedHintCapabilities(
        FocusHintCapabilities(
          node: _effectiveFocusNode,
          supportsA: widget.onPressed != null,
          supportsX: widget.onSecondary != null,
          supportsY: widget.showYHint,
          onA: widget.onPressed,
          onX: widget.onSecondary,
          onY: widget.onTertiary,
        ),
      );
      if (!_hasSuppressedInitialNavigateSound) {
        _hasSuppressedInitialNavigateSound = true;
      } else if (_shouldSuppressNextNavigateSound) {
        _shouldSuppressNextNavigateSound = false;
      } else {
        // Fire-and-forget: play navigate sound. Volume is controlled separately.
        ref.read(navSoundPlayerProvider).play(NavSoundType.navigate);
      }
    } else {
      clearFocusedHintCapabilitiesIfNode(_effectiveFocusNode);
    }
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    // Custom handler runs first.
    if (widget.onKeyEvent != null) {
      final result = widget.onKeyEvent!(node, event);
      if (result == KeyEventResult.handled) return result;
    }
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    // A button: Enter, Space, gamepad A, or keyboard A key
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space ||
        event.logicalKey == LogicalKeyboardKey.gameButtonA ||
        event.logicalKey == LogicalKeyboardKey.keyA) {
      if (widget.onPressed != null) {
        widget.onPressed!();
        ref.read(navSoundPlayerProvider).play(NavSoundType.select);
        return KeyEventResult.handled;
      }
    }
    // X button: context menu (gamepad X or keyboard X key)
    if (event.logicalKey == LogicalKeyboardKey.gameButtonX || event.logicalKey == LogicalKeyboardKey.keyX) {
      if (widget.onSecondary != null) {
        widget.onSecondary!();
        return KeyEventResult.handled;
      }
    }
    // Y button: tertiary action (gamepad Y or keyboard Y key)
    if (event.logicalKey == LogicalKeyboardKey.gameButtonY || event.logicalKey == LogicalKeyboardKey.keyY) {
      if (widget.onTertiary != null) {
        widget.onTertiary!();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final showFocus = ref.watch(
      inputModeProvider.select((mode) => mode != InputMode.mouse),
    );
    final showVisualFocus = _hasFocus && showFocus;
    final scale = showVisualFocus ? (widget.isCard ? AppConstants.focusScaleCard : AppConstants.focusScaleTile) : 1.0;

    return Focus(
      focusNode: _effectiveFocusNode,
      canRequestFocus: widget.canRequestFocus,
      skipTraversal: widget.skipTraversal,
      onKeyEvent: _handleKeyEvent,
      child: AnimatedScale(
        duration: const Duration(milliseconds: AppConstants.focusTransitionMs),
        curve: Curves.easeOut,
        scale: scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: AppConstants.focusTransitionMs),
          curve: Curves.easeOut,
          padding: widget.padding,
          decoration: BoxDecoration(
            shape: widget.isCircular ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: widget.isCircular ? null : BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: showVisualFocus ? accent : Colors.transparent,
              width: AppConstants.focusBorderWidth,
            ),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
