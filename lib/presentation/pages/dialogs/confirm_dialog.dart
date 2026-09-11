import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/gamepad_button_hints.dart';

/// Generic confirmation dialog used for destructive operations.
///
/// Spec (REQUIREMENTS §7.17):
/// - Width: 380px
/// - Background: bgSurface, borderRadius 16px, padding 24px
/// - Title: 18sp semibold textPrimary
/// - Message: 14sp textSecondary
/// - Buttons: Cancel (secondary) + Confirm (danger/accent depending on [isDangerous])
///
/// Gamepad: A on confirm, B on cancel, default focus on cancel (safe default).
///
/// Usage:
/// ```dart
/// final confirmed = await showConfirmDialog(
///   context,
///   title: 'Delete Playlist',
///   message: 'This action cannot be undone.',
///   confirmLabel: 'Delete',
///   isDangerous: true,
/// );
/// if (confirmed == true) { /* proceed */ }
/// ```
Future<bool?> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool isDangerous = false,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (_) => _ConfirmDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      isDangerous: isDangerous,
    ),
  );
}

// ---------------------------------------------------------------------------
// Implementation
// ---------------------------------------------------------------------------

class _ConfirmDialog extends StatefulWidget {
  const _ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.isDangerous,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDangerous;

  @override
  State<_ConfirmDialog> createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<_ConfirmDialog> {
  // Default focus is on Cancel (safe default for destructive dialogs).
  late final FocusNode _cancelFocus;
  late final FocusNode _confirmFocus;
  late final FocusNode _keyListenerFocusNode;

  @override
  void initState() {
    super.initState();
    _cancelFocus = FocusNode(debugLabel: 'ConfirmDialog-cancel');
    _confirmFocus = FocusNode(debugLabel: 'ConfirmDialog-confirm');
    _keyListenerFocusNode = FocusNode(debugLabel: 'ConfirmDialogState-keyListener')..skipTraversal = true;
    _cancelFocus.addListener(_handleFocusChanged);
    _confirmFocus.addListener(_handleFocusChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cancelFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _cancelFocus.removeListener(_handleFocusChanged);
    _confirmFocus.removeListener(_handleFocusChanged);
    _cancelFocus.dispose();
    _confirmFocus.dispose();
    _keyListenerFocusNode.dispose();
    super.dispose();
  }

  void _handleFocusChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _handlePrimaryAction() {
    if (_cancelFocus.hasFocus) {
      Navigator.of(context).pop(false);
      return;
    }

    Navigator.of(context).pop(true);
  }

  String _primaryHintLabel() {
    if (_cancelFocus.hasFocus) return widget.cancelLabel;
    return widget.confirmLabel;
  }

  KeyEventResult _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.gameButtonA) {
      _handlePrimaryAction();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape ||
        event.logicalKey == LogicalKeyboardKey.gameButtonB ||
        event.logicalKey == LogicalKeyboardKey.keyB) {
      Navigator.of(context).pop(false);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;
    final sizes = AppSizes.of(context);

    return KeyboardListener(
      focusNode: _keyListenerFocusNode,
      onKeyEvent: _handleKey,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppConstants.dialogWidth,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: ext.bgSurface,
              borderRadius: BorderRadius.circular(sizes.cardRadius),
              border: Border.all(color: ext.borderSubtle),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xCC000000),
                  blurRadius: 32,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(AppConstants.dialogPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  widget.title,
                  style: tt.titleLarge?.copyWith(color: ext.textPrimary),
                ),
                const SizedBox(height: 12),
                // Message
                Text(
                  widget.message,
                  style: tt.bodyMedium?.copyWith(color: ext.textSecondary),
                ),
                const SizedBox(height: 24),
                // Buttons row
                FocusTraversalGroup(
                  policy: OrderedTraversalPolicy(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _DialogButton(
                        label: widget.cancelLabel,
                        focusNode: _cancelFocus,
                        isPrimary: false,
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                      const SizedBox(width: 12),
                      _DialogButton(
                        label: widget.confirmLabel,
                        focusNode: _confirmFocus,
                        isPrimary: true,
                        onPressed: () => Navigator.of(context).pop(true),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GamepadButtonHints(
                  aLabel: _primaryHintLabel(),
                  bLabel: widget.cancelLabel,
                  onAPressed: _handlePrimaryAction,
                  onBPressed: () => Navigator.of(context).pop(false),
                  backgroundColor: ext.bgSurface,
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
// Internal reusable button
// ---------------------------------------------------------------------------

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.focusNode,
    required this.isPrimary,
    required this.onPressed,
  });

  final String label;
  final FocusNode focusNode;
  final bool isPrimary;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return FilledButton(
        focusNode: focusNode,
        onPressed: onPressed,
        child: Text(label),
      );
    }
    return OutlinedButton(
      focusNode: focusNode,
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
