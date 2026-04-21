import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/keyboard_shortcuts_provider.dart';
import '../../providers/toast_provider.dart';
import '../../widgets/focus_highlight.dart';
import '../../widgets/shortcut_capture_dialog.dart';
import '../../../presentation/models/keyboard_shortcut.dart';

class KeyboardShortcutEditorPage extends ConsumerStatefulWidget {
  const KeyboardShortcutEditorPage({super.key});

  @override
  ConsumerState<KeyboardShortcutEditorPage> createState() => _KeyboardShortcutEditorPageState();
}

class _KeyboardShortcutEditorPageState extends ConsumerState<KeyboardShortcutEditorPage> {
  late final FocusNode _resetFocusNode;
  late final FocusNode _keyListenerFocusNode;

  @override
  void initState() {
    super.initState();
    _resetFocusNode = FocusNode(debugLabel: 'ResetAllShortcuts');
    _keyListenerFocusNode = FocusNode(debugLabel: 'KeyboardShortcutEditorPage-keyListener')..skipTraversal = true;
  }

  @override
  void dispose() {
    _resetFocusNode.dispose();
    _keyListenerFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final shortcutsAsync = ref.watch(keyboardShortcutsProvider);

    return KeyboardListener(
      focusNode: _keyListenerFocusNode,
      onKeyEvent: (event) {
        if (event is KeyDownEvent && (event.logicalKey == LogicalKeyboardKey.escape || event.logicalKey == LogicalKeyboardKey.gameButtonB)) {
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: ext.bgDeep,
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.arrowLeft),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.keyboardShortcuts,
                    style: tt.headlineSmall?.copyWith(
                      color: ext.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  FocusHighlight(
                    focusNode: _resetFocusNode,
                    child: TextButton.icon(
                      icon: const Icon(LucideIcons.rotateCcw, size: 16),
                      label: Text(l10n.resetAll),
                      onPressed: () async {
                        await ref.read(keyboardShortcutsProvider.notifier).resetAll();
                        if (context.mounted) {
                          ref.read(toastProvider.notifier).show(l10n.shortcutsResetToDefaults);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: shortcutsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(
                    child: Text(l10n.errorLoadingShortcuts, style: tt.bodyMedium?.copyWith(color: ext.textSecondary)),
                  ),
                  data: (configs) => ListView.builder(
                    itemCount: configs.length,
                    itemBuilder: (ctx, i) {
                      final config = configs[i];
                      final isDefault = _activatorsEqual(config.keySet, config.defaultKeySet);
                      return _ShortcutRow(
                        config: config,
                        isDefault: isDefault,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _activatorsEqual(SingleActivator a, SingleActivator b) =>
      a.trigger == b.trigger && a.control == b.control && a.shift == b.shift && a.alt == b.alt && a.meta == b.meta;
}

class _ShortcutRow extends ConsumerStatefulWidget {
  const _ShortcutRow({
    required this.config,
    required this.isDefault,
  });

  final KeyboardShortcutConfig config;
  final bool isDefault;

  @override
  ConsumerState<_ShortcutRow> createState() => _ShortcutRowState();
}

class _ShortcutRowState extends ConsumerState<_ShortcutRow> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(debugLabel: 'ShortcutRow-${widget.config.actionId}');
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final keyLabel = KeyboardShortcutConfig.activatorToString(widget.config.keySet);

    return FocusHighlight(
      focusNode: _focusNode,
      child: ListTile(
        title: Text(
          widget.config.label,
          style: tt.bodyLarge?.copyWith(color: ext.textPrimary),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: ext.bgInput,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                keyLabel,
                style: tt.bodyMedium?.copyWith(
                  color: widget.isDefault ? ext.textSecondary : ext.textPrimary,
                  fontWeight: widget.isDefault ? FontWeight.w400 : FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(LucideIcons.pencil, size: 16),
              onPressed: () => _editShortcut(context, ref),
              tooltip: l10n.editShortcut,
            ),
            if (!widget.isDefault)
              IconButton(
                icon: const Icon(LucideIcons.rotateCcw, size: 16),
                onPressed: () => ref.read(keyboardShortcutsProvider.notifier).resetSingle(widget.config.actionId),
                tooltip: l10n.resetToDefault,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _editShortcut(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<SingleActivator>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ShortcutCaptureDialog(actionLabel: widget.config.label),
    );

    if (result == null || !context.mounted) return;

    final notifier = ref.read(keyboardShortcutsProvider.notifier);
    final conflict = await notifier.updateShortcut(widget.config.actionId, result);

    if (conflict != null && context.mounted) {
      final conflictLabel = KeyboardShortcutConfig.labels[conflict] ?? conflict;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(l10n.shortcutConflictTitle),
          content: Text(
            l10n.shortcutConflict(conflictLabel),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.reassign),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        await notifier.forceUpdateShortcut(widget.config.actionId, result);
      }
    } else if (conflict == null && context.mounted) {
      ref.read(toastProvider.notifier).show(l10n.shortcutUpdated);
    }
  }
}
