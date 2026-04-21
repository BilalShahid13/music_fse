import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/localization/generated/app_localizations.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';

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
  late final FocusNode _minimizeFocus;
  late final FocusNode _quitFocus;
  late final FocusNode _keyListenerFocusNode;

  @override
  void initState() {
    super.initState();
    _minimizeFocus = FocusNode(debugLabel: 'CloseToTray-minimize');
    _quitFocus = FocusNode(debugLabel: 'CloseToTray-quit');
    _keyListenerFocusNode = FocusNode(debugLabel: 'CloseToTrayDialogState-keyListener')..skipTraversal = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _minimizeFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _minimizeFocus.dispose();
    _quitFocus.dispose();
    _keyListenerFocusNode.dispose();
    super.dispose();
  }

  void _dismiss({required bool minimize}) {
    Navigator.of(context).pop((minimize: minimize, remember: _remember));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;

    return KeyboardListener(
      focusNode: _keyListenerFocusNode,
      onKeyEvent: (event) {
        if (event is KeyDownEvent && (event.logicalKey == LogicalKeyboardKey.escape || event.logicalKey == LogicalKeyboardKey.gameButtonB)) {
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
            Row(
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
          ],
        ),
        actions: [
          TextButton(
            focusNode: _quitFocus,
            onPressed: () => _dismiss(minimize: false),
            child: Text(l10n.closeToTrayQuit),
          ),
          ElevatedButton.icon(
            focusNode: _minimizeFocus,
            onPressed: () => _dismiss(minimize: true),
            icon: const Icon(LucideIcons.minimize2, size: 16),
            label: Text(l10n.closeToTrayMinimize),
          ),
        ],
      ),
    );
  }
}
