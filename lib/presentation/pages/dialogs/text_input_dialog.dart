import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/gamepad_button_hints.dart';

/// Dialog with a single text field + confirm/cancel.
///
/// Used for creating playlists, renaming them, saving EQ presets, and the
/// "Save Queue as Playlist" flow (per REQUIREMENTS §7.17).
///
/// Spec:
/// - Width: 380px, bgSurface, borderRadius 16px, padding 24px
/// - Title: 18sp semibold
/// - TextField: bgInput, height 44px, 14sp, borderRadius 8px
/// - Buttons: Cancel + Confirm (accent)
///
/// Gamepad: default focus on text field. A on "Confirm" submits (also Enter).
/// B cancels.
///
/// Usage:
/// ```dart
/// final name = await showTextInputDialog(
///   context,
///   title: 'New Playlist',
///   hint: 'Playlist name',
///   initialValue: 'My Playlist',
///   confirmLabel: 'Create',
/// );
/// if (name != null) { /* use name */ }
/// ```
Future<String?> showTextInputDialog(
  BuildContext context, {
  required String title,
  String hint = '',
  String initialValue = '',
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  int maxLength = 80,
}) {
  return showDialog<String>(
    context: context,
    barrierDismissible: true,
    builder: (_) => _TextInputDialog(
      title: title,
      hint: hint,
      initialValue: initialValue,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      maxLength: maxLength,
    ),
  );
}

// ---------------------------------------------------------------------------
// Implementation
// ---------------------------------------------------------------------------

class _TextInputDialog extends StatefulWidget {
  const _TextInputDialog({
    required this.title,
    required this.hint,
    required this.initialValue,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.maxLength,
  });

  final String title;
  final String hint;
  final String initialValue;
  final String confirmLabel;
  final String cancelLabel;
  final int maxLength;

  @override
  State<_TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<_TextInputDialog> {
  late final TextEditingController _controller;
  late final FocusNode _fieldFocus;
  late final FocusNode _cancelFocus;
  late final FocusNode _confirmFocus;
  late final FocusNode _keyListenerFocusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _fieldFocus = FocusNode(debugLabel: 'TextInputDialog-field');
    _cancelFocus = FocusNode(debugLabel: 'TextInputDialog-cancel');
    _confirmFocus = FocusNode(debugLabel: 'TextInputDialog-confirm');
    _keyListenerFocusNode = FocusNode(debugLabel: 'TextInputDialogState-keyListener')..skipTraversal = true;
    _fieldFocus.addListener(_handleFocusChanged);
    _cancelFocus.addListener(_handleFocusChanged);
    _confirmFocus.addListener(_handleFocusChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fieldFocus.requestFocus();
      // Select all text so the user can immediately overwrite the initial value.
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    });
  }

  @override
  void dispose() {
    _fieldFocus.removeListener(_handleFocusChanged);
    _cancelFocus.removeListener(_handleFocusChanged);
    _confirmFocus.removeListener(_handleFocusChanged);
    _controller.dispose();
    _fieldFocus.dispose();
    _cancelFocus.dispose();
    _confirmFocus.dispose();
    _keyListenerFocusNode.dispose();
    super.dispose();
  }

  void _confirm() {
    final trimmed = _controller.text.trim();
    if (trimmed.isEmpty) return;
    Navigator.of(context).pop(trimmed);
  }

  void _handleFocusChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _handlePrimaryAction() {
    if (_cancelFocus.hasFocus) {
      Navigator.of(context).pop();
      return;
    }

    _confirm();
  }

  String _primaryHintLabel() {
    if (_cancelFocus.hasFocus) return widget.cancelLabel;
    return widget.confirmLabel;
  }

  KeyEventResult _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.gameButtonA) {
      _handlePrimaryAction();
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (_fieldFocus.hasFocus) {
        _cancelFocus.requestFocus();
        return KeyEventResult.handled;
      }
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (_cancelFocus.hasFocus || _confirmFocus.hasFocus) {
        _fieldFocus.requestFocus();
        return KeyEventResult.handled;
      }
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      if (_cancelFocus.hasFocus) {
        _confirmFocus.requestFocus();
        return KeyEventResult.handled;
      }
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      if (_confirmFocus.hasFocus) {
        _cancelFocus.requestFocus();
        return KeyEventResult.handled;
      }
    }

    if (event.logicalKey == LogicalKeyboardKey.escape || event.logicalKey == LogicalKeyboardKey.gameButtonB) {
      Navigator.of(context).pop();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;
    final accent = Theme.of(context).colorScheme.primary;
    final sizes = AppSizes.of(context);

    return KeyboardListener(
      focusNode: _keyListenerFocusNode,
      onKeyEvent: _handleKey,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppConstants.dialogWidth),
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
                Text(
                  widget.title,
                  style: tt.titleLarge?.copyWith(color: ext.textPrimary),
                ),
                const SizedBox(height: 16),
                // Text field
                TextField(
                  controller: _controller,
                  focusNode: _fieldFocus,
                  maxLength: widget.maxLength,
                  maxLines: 1,
                  onSubmitted: (_) => _confirm(),
                  style: tt.bodyLarge?.copyWith(color: ext.textPrimary),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: tt.bodyLarge?.copyWith(color: ext.textTertiary),
                    filled: true,
                    fillColor: ext.bgInput,
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(sizes.cardRadiusSm),
                      borderSide: BorderSide(color: ext.borderSubtle),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(sizes.cardRadiusSm),
                      borderSide: BorderSide(color: ext.borderSubtle),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(sizes.cardRadiusSm),
                      borderSide: BorderSide(color: accent, width: AppConstants.focusBorderWidth),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FocusTraversalGroup(
                  policy: OrderedTraversalPolicy(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        focusNode: _cancelFocus,
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(widget.cancelLabel),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        focusNode: _confirmFocus,
                        onPressed: _confirm,
                        child: Text(widget.confirmLabel),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GamepadButtonHints(
                  aLabel: _primaryHintLabel(),
                  bLabel: widget.cancelLabel,
                  onAPressed: _handlePrimaryAction,
                  onBPressed: () => Navigator.of(context).pop(),
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
