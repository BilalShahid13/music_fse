import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../providers/multi_select_provider.dart';
import '../providers/playback_provider.dart';
import '../providers/toast_provider.dart';
import '../../domain/entities/song.dart';
import 'focus_highlight.dart';

/// Bottom action bar shown when multi-select mode is active.
///
/// Provides batch operations: Add to Queue, Add to Playlist, Select All, Cancel.
class MultiSelectActionsBar extends ConsumerWidget {
  const MultiSelectActionsBar({
    super.key,
    required this.allSongs,
    this.onAddToPlaylist,
  });

  /// All songs in the current view (for Select All).
  final List<Song> allSongs;

  /// Optional callback for "Add to Playlist" (opens picker).
  final VoidCallback? onAddToPlaylist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final multiSelect = ref.watch(multiSelectProvider);
    final count = multiSelect.selectedIds.length;
    final theme = Theme.of(context);
    final tt = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;
    final hasSelection = count > 0;

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Text(
            l10n.selectedCount(count),
            style: tt.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 16),
          _ActionButton(
            icon: LucideIcons.listPlus,
            label: l10n.ctxAddToQueue,
            onPressed: hasSelection ? () => _addToQueue(context, ref, count) : null,
          ),
          if (onAddToPlaylist != null)
            _ActionButton(
              icon: LucideIcons.listMusic,
              label: l10n.ctxAddToPlaylist,
              onPressed: hasSelection ? onAddToPlaylist : null,
            ),
          const Spacer(),
          _ActionButton(
            icon: LucideIcons.squareCheck,
            label: l10n.selectAll,
            onPressed: () {
              ref.read(multiSelectProvider.notifier).selectAll(
                    allSongs.map((s) => s.id).toList(),
                  );
            },
          ),
          _ActionButton(
            icon: LucideIcons.x,
            label: l10n.cancel,
            onPressed: () {
              ref.read(multiSelectProvider.notifier).deactivate();
            },
          ),
        ],
      ),
    );
  }

  void _addToQueue(BuildContext context, WidgetRef ref, int count) {
    final l10n = AppLocalizations.of(context)!;
    final selectedIds = ref.read(multiSelectProvider).selectedIds;
    final selected = allSongs.where((s) => selectedIds.contains(s.id)).toList();
    final notifier = ref.read(playbackProvider.notifier);
    for (final song in selected) {
      notifier.addToQueue(song);
    }
    ref.read(toastProvider.notifier).show(l10n.addedManyToQueue(count));
    ref.read(multiSelectProvider.notifier).deactivate();
  }
}

class _ActionButton extends StatefulWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(debugLabel: 'MultiSelectAction-${widget.label}');
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final disabledColor = Theme.of(context).disabledColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FocusHighlight(
        focusNode: _focusNode,
        onPressed: widget.onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 18,
                color: enabled ? null : disabledColor,
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: enabled
                    ? Theme.of(context).textTheme.bodySmall
                    : Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: disabledColor,
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
