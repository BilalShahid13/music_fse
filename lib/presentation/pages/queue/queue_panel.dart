import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/queue_item.dart';
import '../../../domain/entities/song.dart';
import '../../providers/playback_provider.dart';
import '../../providers/toast_provider.dart';
import '../../providers/use_case_providers.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/art_placeholder.dart';
import '../../widgets/focus_highlight.dart';
import '../dialogs/text_input_dialog.dart';
import '../../../core/localization/generated/app_localizations.dart';

/// A 340px slide-in queue panel.
///
/// Displayed as an overlay within the Now Playing page or shell. The calling
/// widget is responsible for the slide animation; this widget renders the
/// content only.
///
/// Gamepad:
/// - B button → dismiss (via [onDismiss])
/// - A on queue item → jump to that track
/// - X on queue item → remove from queue
class QueuePanel extends ConsumerStatefulWidget {
  const QueuePanel({super.key, required this.onDismiss});
  final VoidCallback onDismiss;

  @override
  ConsumerState<QueuePanel> createState() => _QueuePanelState();
}

class _QueuePanelState extends ConsumerState<QueuePanel> {
  late final FocusNode _clearFocus;
  late final FocusNode _saveFocus;
  late final FocusNode _keyListenerFocusNode;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _clearFocus = FocusNode(debugLabel: 'Queue-clear');
    _saveFocus = FocusNode(debugLabel: 'Queue-save');
    _keyListenerFocusNode = FocusNode(debugLabel: 'QueuePanel-keyListener')..skipTraversal = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _clearFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _clearFocus.dispose();
    _saveFocus.dispose();
    _keyListenerFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  KeyEventResult _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.escape || event.logicalKey == LogicalKeyboardKey.gameButtonB) {
      widget.onDismiss();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Future<void> _saveQueueAsPlaylist(
    BuildContext context,
    WidgetRef ref,
    List<Song> queue,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final defaultName = l10n.queueSaveDefaultName(
      DateFormat.yMMMd().format(DateTime.now()),
    );

    final name = await showTextInputDialog(
      context,
      title: l10n.queueSaveTitle,
      hint: l10n.queueSaveHint,
      initialValue: defaultName,
      confirmLabel: l10n.queueSaveConfirm,
      cancelLabel: l10n.cancel,
    );

    if (name == null || name.trim().isEmpty) return;

    final useCase = ref.read(saveQueueAsPlaylistProvider);
    final queueItems = queue.asMap().entries.map((e) => QueueItem(song: e.value, sortOrder: e.key)).toList();

    final result = await useCase(name.trim(), queueItems);

    if (!context.mounted) return;

    if (result.isSuccess) {
      ref.read(toastProvider.notifier).show(
            l10n.queueSaveSuccess(name.trim()),
          );
    } else {
      ref.read(toastProvider.notifier).show(
            'Failed to save playlist',
            isError: true,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;
    final queue = ref.watch(
      playbackProvider.select((s) => s.queue),
    );
    final currentSong = ref.watch(
      playbackProvider.select((s) => s.currentSong),
    );

    return KeyboardListener(
      focusNode: _keyListenerFocusNode,
      onKeyEvent: _handleKey,
      child: SizedBox(
        width: AppConstants.queuePanelWidth,
        child: Container(
          color: ext.bgSurface,
          child: Column(
            children: [
              // ── Header ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Queue',
                        style: tt.titleLarge?.copyWith(
                          color: ext.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),
                    // Dismiss
                    _IconBtn(
                      icon: LucideIcons.x,
                      tooltip: 'Close',
                      onTap: widget.onDismiss,
                    ),
                  ],
                ),
              ),

              // ── Action row ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: _QueueActionBtn(
                        focusNode: _clearFocus,
                        icon: LucideIcons.trash2,
                        label: 'Clear',
                        onTap: queue.isEmpty ? null : () => ref.read(playbackProvider.notifier).clearQueue(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _QueueActionBtn(
                        focusNode: _saveFocus,
                        icon: LucideIcons.save,
                        label: 'Save as Playlist',
                        onTap: queue.isEmpty ? null : () => _saveQueueAsPlaylist(context, ref, queue),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Queue items ──────────────────────────────────────────
              Expanded(
                child: queue.isEmpty
                    ? const EmptyState(
                        icon: LucideIcons.listMusic,
                        title: 'Queue is empty',
                        subtitle: 'Play a song or add tracks to the queue',
                      )
                    : ReorderableListView.builder(
                        scrollController: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: queue.length,
                        onReorder: (oldIndex, newIndex) {
                          if (newIndex > oldIndex) newIndex--;
                          ref.read(playbackProvider.notifier).reorderQueue(oldIndex, newIndex);
                        },
                        itemBuilder: (ctx, i) {
                          final song = queue[i];
                          final isCurrent = song.id == currentSong?.id;
                          return _QueueItem(
                            key: ValueKey('${song.id}-$i'), // index-keyed to handle duplicates
                            song: song,
                            index: i,
                            isCurrent: isCurrent,
                            onTap: () => ref.read(playbackProvider.notifier).playSong(song, queue: queue, index: i),
                            onRemove: () => ref.read(playbackProvider.notifier).removeFromQueue(i),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Queue item
// ---------------------------------------------------------------------------

class _QueueItem extends StatefulWidget {
  const _QueueItem({
    super.key,
    required this.song,
    required this.index,
    required this.isCurrent,
    required this.onTap,
    required this.onRemove,
  });

  final Song song;
  final int index;
  final bool isCurrent;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  State<_QueueItem> createState() => _QueueItemState();
}

class _QueueItemState extends State<_QueueItem> {
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode();
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;
    final accent = Theme.of(context).colorScheme.primary;

    return FocusHighlight(
      focusNode: _focus,
      borderRadius: 0,
      onPressed: widget.onTap,
      onSecondary: widget.onRemove,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              // Drag handle
              Icon(LucideIcons.gripVertical, size: 14, color: ext.textTertiary),
              const SizedBox(width: 8),
              // Art
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  width: AppConstants.queueItemArtSize,
                  height: AppConstants.queueItemArtSize,
                  child: widget.song.artCachePath != null && File(widget.song.artCachePath!).existsSync()
                      ? Image.file(File(widget.song.artCachePath!), fit: BoxFit.cover)
                      : const ArtPlaceholder(size: AppConstants.queueItemArtSize),
                ),
              ),
              const SizedBox(width: 10),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.song.title,
                      style: tt.bodySmall?.copyWith(
                        color: widget.isCurrent ? accent : ext.textPrimary,
                        fontWeight: widget.isCurrent ? FontWeight.w600 : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.song.artist,
                      style: tt.bodySmall?.copyWith(color: ext.textTertiary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Remove button
              _IconBtn(
                icon: LucideIcons.x,
                tooltip: 'Remove',
                size: 16,
                onTap: widget.onRemove,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.icon,
    required this.onTap,
    this.tooltip = '',
    this.size = 18,
  });
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final double size;

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: AppConstants.minFocusableSize,
          height: AppConstants.minFocusableSize,
          child: Icon(icon, size: size, color: ext.textSecondary),
        ),
      ),
    );
  }
}

class _QueueActionBtn extends StatefulWidget {
  const _QueueActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.focusNode,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final FocusNode? focusNode;

  @override
  State<_QueueActionBtn> createState() => _QueueActionBtnState();
}

class _QueueActionBtnState extends State<_QueueActionBtn> {
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _focus = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;

    return FocusHighlight(
      focusNode: _focus,
      borderRadius: AppConstants.btnRadius,
      onPressed: widget.onTap,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: ext.bgCard,
            borderRadius: BorderRadius.circular(AppConstants.btnRadius),
            border: Border.all(color: ext.borderCard),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 14, color: ext.textSecondary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  widget.label,
                  style: tt.labelSmall?.copyWith(color: ext.textPrimary),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
