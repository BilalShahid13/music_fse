import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/localization/generated/app_localizations.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';
import '../../widgets/focus_highlight.dart';
import '../../widgets/gamepad_button_hints.dart';

/// First-time close-to-tray dialog.
///
/// Returns `({bool minimize, bool remember})` or `null` if dismissed.
class CloseToTrayDialog extends StatefulWidget {
  const CloseToTrayDialog({super.key});

  @override
  State<CloseToTrayDialog> createState() => _CloseToTrayDialogState();
}

class _CloseToTrayDialogState extends State<CloseToTrayDialog> {
  bool _remember = false;
  late final FocusNode _rememberFocus;
  late final FocusNode _minimizeFocus;
  late final FocusNode _quitFocus;
  late final FocusNode _keyListenerFocusNode;

  @override
  void initState() {
    super.initState();
    _rememberFocus = FocusNode(debugLabel: 'CloseToTray-remember');
    _minimizeFocus = FocusNode(debugLabel: 'CloseToTray-minimize');
    _quitFocus = FocusNode(debugLabel: 'CloseToTray-quit');
    _keyListenerFocusNode = FocusNode(debugLabel: 'CloseToTrayDialogState-keyListener')..skipTraversal = true;
    _rememberFocus.addListener(_handleFocusChanged);
    _minimizeFocus.addListener(_handleFocusChanged);
    _quitFocus.addListener(_handleFocusChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _minimizeFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _rememberFocus.removeListener(_handleFocusChanged);
    _minimizeFocus.removeListener(_handleFocusChanged);
    _quitFocus.removeListener(_handleFocusChanged);
    _rememberFocus.dispose();
    _minimizeFocus.dispose();
    _quitFocus.dispose();
    _keyListenerFocusNode.dispose();
    super.dispose();
  }

  void _handleFocusChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _dismiss({required bool minimize}) {
    Navigator.of(context).pop((minimize: minimize, remember: _remember));
  }

  void _handlePrimaryAction() {
    if (_rememberFocus.hasFocus) {
      setState(() => _remember = !_remember);
      return;
    }
    if (_quitFocus.hasFocus) {
      _dismiss(minimize: false);
      return;
    }
    _dismiss(minimize: true);
  }

  String _primaryHintLabel(AppLocalizations l10n) {
    if (_rememberFocus.hasFocus) return l10n.hintSelect;
    if (_quitFocus.hasFocus) return l10n.closeToTrayQuit;
    return l10n.closeToTrayMinimize;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;

    return KeyboardListener(
      focusNode: _keyListenerFocusNode,
      onKeyEvent: (event) {
        if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.gameButtonA) {
          _handlePrimaryAction();
        }
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.escape ||
                event.logicalKey == LogicalKeyboardKey.gameButtonB ||
                event.logicalKey == LogicalKeyboardKey.keyB)) {
          Navigator.of(context).pop(null);
        }
      },
      child: AlertDialog(
        backgroundColor: ext.bgSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.closeToTrayDialogTitle,
          style: tt.titleLarge?.copyWith(
            color: ext.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.closeToTrayDialogBody,
              style: tt.bodyMedium?.copyWith(color: ext.textSecondary),
            ),
            const SizedBox(height: 16),
            FocusHighlight(
              focusNode: _rememberFocus,
              borderRadius: 8,
              onPressed: () => setState(() => _remember = !_remember),
              child: GestureDetector(
                onTap: () => setState(() => _remember = !_remember),
                child: Row(
                  children: [
                    Checkbox(
                      value: _remember,
                      onChanged: (v) => setState(() => _remember = v ?? false),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.closeToTrayRemember,
                      style: tt.bodyMedium?.copyWith(color: ext.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      focusNode: _quitFocus,
                      onPressed: () => _dismiss(minimize: false),
                      child: Text(l10n.closeToTrayQuit),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      focusNode: _minimizeFocus,
                      onPressed: () => _dismiss(minimize: true),
                      icon: const Icon(LucideIcons.minimize2, size: 16),
                      label: Text(l10n.closeToTrayMinimize),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                GamepadButtonHints(
                  aLabel: _primaryHintLabel(l10n),
                  bLabel: l10n.hintClose,
                  onAPressed: _handlePrimaryAction,
                  onBPressed: () => Navigator.of(context).pop(null),
                  backgroundColor: ext.bgSurface,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
