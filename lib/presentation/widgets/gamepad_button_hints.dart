import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_theme.dart';

/// Horizontal bar displaying available gamepad button actions for the current
/// context.
///
/// Spec (REQUIREMENTS §6.10 / CLAUDE.md §2.3):
/// - Height: 40px
/// - Background: bgDeep with top border 1px borderSubtle
/// - Right-aligned (PS5 convention)
/// - Each hint: colored circle (22×22) + label (11sp secondary)
/// - Gap between hints: 20px
/// - Padding right: 24px
/// - Button colors: A=#4CAF50, B=#F44336, X=#2196F3, Y=#FFC107
///
/// Only buttons with non-null labels are rendered.
class GamepadButtonHints extends StatelessWidget {
  const GamepadButtonHints({
    super.key,
    this.aLabel,
    this.bLabel,
    this.xLabel,
    this.yLabel,
    this.startLabel,
    this.leftLabel,
    this.rightLabel,
    this.upLabel,
    this.downLabel,
    this.lbLabel,
    this.rbLabel,
    this.onAPressed,
    this.onBPressed,
    this.onXPressed,
    this.onYPressed,
    this.onStartPressed,
    this.onLeftPressed,
    this.onRightPressed,
    this.onUpPressed,
    this.onDownPressed,
    this.onLbPressed,
    this.onRbPressed,
    this.backgroundColor,
  });

  /// Label for the A (green / confirm) button.
  final String? aLabel;

  /// Label for the B (red / back) button.
  final String? bLabel;

  /// Label for the X (blue / options) button.
  final String? xLabel;

  /// Label for the Y (yellow / favorite) button.
  final String? yLabel;

  /// Label for the Start / Menu button.
  final String? startLabel;

  /// Optional background color override. When null, defaults to [ext.bgDeep].
  final Color? backgroundColor;

  /// Label for the left directional input.
  final String? leftLabel;

  /// Label for the right directional input.
  final String? rightLabel;

  /// Label for the up directional input.
  final String? upLabel;

  /// Label for the down directional input.
  final String? downLabel;

  /// Label for the LB (left bumper) button.
  final String? lbLabel;

  /// Label for the RB (right bumper) button.
  final String? rbLabel;

  final VoidCallback? onAPressed;
  final VoidCallback? onBPressed;
  final VoidCallback? onXPressed;
  final VoidCallback? onYPressed;
  final VoidCallback? onStartPressed;
  final VoidCallback? onLeftPressed;
  final VoidCallback? onRightPressed;
  final VoidCallback? onUpPressed;
  final VoidCallback? onDownPressed;
  final VoidCallback? onLbPressed;
  final VoidCallback? onRbPressed;

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final sizes = AppSizes.of(context);
    final compact = sizes.isCompact;
    final hPad = compact ? 20.0 : 24.0;
    final hintGap = compact ? 16.0 : 20.0;

    final hints = <_ButtonHint>[
      if (yLabel != null) _ButtonHint(label: yLabel!, color: ext.btnY, letter: 'Y', onPressed: onYPressed),
      if (xLabel != null) _ButtonHint(label: xLabel!, color: ext.btnX, letter: 'X', onPressed: onXPressed),
      if (bLabel != null) _ButtonHint(label: bLabel!, color: ext.btnB, letter: 'B', onPressed: onBPressed),
      if (aLabel != null) _ButtonHint(label: aLabel!, color: ext.btnA, letter: 'A', onPressed: onAPressed),
    ];

    final bgColor = backgroundColor ?? ext.bgDeep;

    final hasShoulderHints = lbLabel != null || rbLabel != null;
    final hasDirectionalHints = leftLabel != null || rightLabel != null;
    final hasVerticalDirectionalHints = upLabel != null || downLabel != null;

    if (hints.isEmpty && !hasShoulderHints && !hasDirectionalHints && !hasVerticalDirectionalHints) {
      return SizedBox(
        height: sizes.buttonHintsHeight,
        child: Material(
          type: MaterialType.transparency,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: bgColor,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: sizes.buttonHintsHeight,
      child: Material(
        type: MaterialType.transparency,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bgColor,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: Row(
              children: [
                // ── Left: shoulder button hints ──────────────────────────
                if (lbLabel != null || rbLabel != null) ...[
                  if (lbLabel != null)
                    _BumperHintItem(
                      label: lbLabel!,
                      buttonText: 'LB',
                      textColor: ext.textSecondary,
                      isCompact: compact,
                      onPressed: onLbPressed,
                    ),
                  if (lbLabel != null && rbLabel != null) SizedBox(width: compact ? 12.0 : 16.0),
                  if (rbLabel != null)
                    _BumperHintItem(
                      label: rbLabel!,
                      buttonText: 'RB',
                      textColor: ext.textSecondary,
                      isCompact: compact,
                      onPressed: onRbPressed,
                    ),
                ],
                if (hasDirectionalHints) ...[
                  if (hasShoulderHints) SizedBox(width: compact ? 12.0 : 16.0),
                  if (leftLabel != null)
                    _BumperHintItem(
                      label: leftLabel!,
                      buttonText: '←',
                      textColor: ext.textSecondary,
                      isCompact: compact,
                      onPressed: onLeftPressed,
                    ),
                  if (leftLabel != null && rightLabel != null) SizedBox(width: compact ? 12.0 : 16.0),
                  if (rightLabel != null)
                    _BumperHintItem(
                      label: rightLabel!,
                      buttonText: '→',
                      textColor: ext.textSecondary,
                      isCompact: compact,
                      onPressed: onRightPressed,
                    ),
                ],
                if (hasVerticalDirectionalHints) ...[
                  if (hasShoulderHints || hasDirectionalHints) SizedBox(width: compact ? 12.0 : 16.0),
                  if (upLabel != null)
                    _BumperHintItem(
                      label: upLabel!,
                      buttonText: '↑',
                      textColor: ext.textSecondary,
                      isCompact: compact,
                      onPressed: onUpPressed,
                    ),
                  if (upLabel != null && downLabel != null) SizedBox(width: compact ? 12.0 : 16.0),
                  if (downLabel != null)
                    _BumperHintItem(
                      label: downLabel!,
                      buttonText: '↓',
                      textColor: ext.textSecondary,
                      isCompact: compact,
                      onPressed: onDownPressed,
                    ),
                ],
                const Spacer(),
                // ── Right: face button hints ─────────────────────────────
                if (startLabel != null)
                  Padding(
                    padding: EdgeInsets.only(left: hintGap),
                    child: _StartHintItem(
                      label: startLabel!,
                      textColor: ext.textSecondary,
                      isCompact: compact,
                      onPressed: onStartPressed,
                    ),
                  ),
                ...hints.map(
                  (h) => Padding(
                    padding: EdgeInsets.only(left: hintGap),
                    child: _HintItem(hint: h, textColor: ext.textSecondary, isCompact: compact),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Internal model
// ---------------------------------------------------------------------------

class _ButtonHint {
  const _ButtonHint({
    required this.label,
    required this.color,
    required this.letter,
    this.onPressed,
  });

  final String label;
  final Color color;
  final String letter;
  final VoidCallback? onPressed;
}

// ---------------------------------------------------------------------------
// Internal item widget
// ---------------------------------------------------------------------------

class _HintItem extends StatelessWidget {
  const _HintItem({
    required this.hint,
    required this.textColor,
    this.isCompact = false,
  });

  final _ButtonHint hint;
  final Color textColor;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final badgeLabelGap = isCompact ? 6.0 : 8.0;
    final labelSize = isCompact ? 12.0 : 14.0;
    final baseStyle = Theme.of(context).textTheme.labelLarge;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ButtonCircle(color: hint.color, letter: hint.letter, isCompact: isCompact),
        SizedBox(width: badgeLabelGap),
        Text(
          hint.label,
          style: baseStyle?.copyWith(
            fontSize: labelSize,
            fontWeight: FontWeight.w600,
            color: textColor,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );

    if (hint.onPressed == null) return content;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: hint.onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: content,
      ),
    );
  }
}

class _ButtonCircle extends StatelessWidget {
  const _ButtonCircle({required this.color, required this.letter, this.isCompact = false});

  final Color color;
  final String letter;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final diameter = isCompact ? 22.0 : 28.0;
    final fontSize = isCompact ? 12.0 : 15.0;
    final verticalOffset = isCompact ? -0.5 : -0.75;
    final baseStyle = Theme.of(context).textTheme.labelLarge;

    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Transform.translate(
        offset: Offset(0, verticalOffset),
        child: Text(
          letter,
          textAlign: TextAlign.center,
          textHeightBehavior: const TextHeightBehavior(
            applyHeightToFirstAscent: false,
            applyHeightToLastDescent: false,
          ),
          strutStyle: StrutStyle(
            fontSize: fontSize,
            height: 1,
            leading: 0,
            forceStrutHeight: true,
          ),
          style: baseStyle?.copyWith(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 1,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}

class _StartHintItem extends StatelessWidget {
  const _StartHintItem({
    required this.label,
    required this.textColor,
    this.isCompact = false,
    this.onPressed,
  });

  final String label;
  final Color textColor;
  final bool isCompact;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final badgeLabelGap = isCompact ? 6.0 : 8.0;
    final labelSize = isCompact ? 12.0 : 14.0;
    final baseStyle = Theme.of(context).textTheme.labelLarge;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StartButtonBadge(isCompact: isCompact),
        SizedBox(width: badgeLabelGap),
        Text(
          label,
          style: baseStyle?.copyWith(
            fontSize: labelSize,
            fontWeight: FontWeight.w600,
            color: textColor,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );

    if (onPressed == null) return content;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: content,
      ),
    );
  }
}

class _StartButtonBadge extends StatelessWidget {
  const _StartButtonBadge({this.isCompact = false});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final horizontalPadding = isCompact ? 6.0 : 8.0;
    final verticalPadding = isCompact ? 3.0 : 4.0;
    final lineWidth = isCompact ? 12.0 : 15.0;
    final lineGap = isCompact ? 2.0 : 2.6;
    final lineHeight = isCompact ? 2.0 : 2.2;

    Widget line() => Container(
          width: lineWidth,
          height: lineHeight,
          decoration: BoxDecoration(
            color: ext.textSecondary,
            borderRadius: BorderRadius.circular(lineHeight),
          ),
        );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isCompact ? 6.0 : 7.0),
        border: Border.all(color: ext.textSecondary.withValues(alpha: 0.75), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          line(),
          SizedBox(height: lineGap),
          line(),
          SizedBox(height: lineGap),
          line(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Xbox-style bumper button (rounded rectangle with text)
// ---------------------------------------------------------------------------

class _BumperHintItem extends StatelessWidget {
  const _BumperHintItem({
    required this.label,
    required this.buttonText,
    required this.textColor,
    this.isCompact = false,
    this.onPressed,
  });

  final String label;
  final String buttonText;
  final Color textColor;
  final bool isCompact;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final badgeLabelGap = isCompact ? 6.0 : 8.0;
    final labelSize = isCompact ? 12.0 : 14.0;
    final baseStyle = Theme.of(context).textTheme.labelLarge;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _BumperBadge(text: buttonText, isCompact: isCompact),
        SizedBox(width: badgeLabelGap),
        Text(
          label,
          style: baseStyle?.copyWith(
            fontSize: labelSize,
            fontWeight: FontWeight.w600,
            color: textColor,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );

    if (onPressed == null) return content;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: content,
      ),
    );
  }
}

class _BumperBadge extends StatelessWidget {
  const _BumperBadge({required this.text, this.isCompact = false});

  final String text;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final badgeHeight = isCompact ? 20.0 : 22.0;
    final baseStyle = Theme.of(context).textTheme.labelLarge;

    final badgeFill = isDark ? Colors.white.withValues(alpha: 0.15) : ext.bgCard.withValues(alpha: 0.92);
    final badgeBorder = isDark ? Colors.white.withValues(alpha: 0.4) : ext.borderSubtle.withValues(alpha: 0.9);
    final badgeText = isDark ? Colors.white : ext.textSecondary;

    return Container(
      height: badgeHeight,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: badgeFill,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: badgeBorder,
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: baseStyle?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: badgeText,
          height: 1,
          letterSpacing: 0.5,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}
