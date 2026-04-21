import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
import '../../presentation/models/keyboard_shortcut.dart';

/// Dialog that captures a key combination from the user.
///
/// Returns a [SingleActivator] or null if cancelled.
class ShortcutCaptureDialog extends StatefulWidget {
  const ShortcutCaptureDialog({
    super.key,
    required this.actionLabel,
  });

  final String actionLabel;

  @override
  State<ShortcutCaptureDialog> createState() => _ShortcutCaptureDialogState();
}

class _ShortcutCaptureDialogState extends State<ShortcutCaptureDialog> {
  SingleActivator? _captured;
  late final FocusNode _captureFocus;

  @override
  void initState() {
    super.initState();
    _captureFocus = FocusNode(debugLabel: 'ShortcutCapture');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _captureFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _captureFocus.dispose();
    super.dispose();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final key = event.logicalKey;

    // Ignore bare modifier presses
    if (key == LogicalKeyboardKey.controlLeft ||
        key == LogicalKeyboardKey.controlRight ||
        key == LogicalKeyboardKey.shiftLeft ||
        key == LogicalKeyboardKey.shiftRight ||
        key == LogicalKeyboardKey.altLeft ||
        key == LogicalKeyboardKey.altRight ||
        key == LogicalKeyboardKey.metaLeft ||
        key == LogicalKeyboardKey.metaRight) {
      return KeyEventResult.handled;
    }

    // Escape cancels
    if (key == LogicalKeyboardKey.escape && !HardwareKeyboard.instance.isControlPressed) {
      Navigator.of(context).pop(null);
      return KeyEventResult.handled;
    }

    setState(() {
      _captured = SingleActivator(
        key,
        control: HardwareKeyboard.instance.isControlPressed,
        shift: HardwareKeyboard.instance.isShiftPressed,
        alt: HardwareKeyboard.instance.isAltPressed,
        meta: HardwareKeyboard.instance.isMetaPressed,
      );
    });

    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;

    return AlertDialog(
      backgroundColor: ext.bgSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Edit Shortcut',
        style: tt.titleLarge?.copyWith(
          color: ext.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Focus(
        focusNode: _captureFocus,
        onKeyEvent: _onKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Press the key combination for "${widget.actionLabel}"',
              style: tt.bodyMedium?.copyWith(color: ext.textSecondary),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                color: ext.bgInput,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  _captured != null ? KeyboardShortcutConfig.activatorToString(_captured!) : 'Waiting for input...',
                  style: tt.titleMedium?.copyWith(
                    color: _captured != null ? ext.textPrimary : ext.textTertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _captured != null ? () => Navigator.of(context).pop(_captured) : null,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
