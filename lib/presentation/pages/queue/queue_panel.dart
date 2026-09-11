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
import '../../../platform/xinput/gamepad_scroll_target.dart';
import '../../providers/playback_provider.dart';
import '../../providers/toast_provider.dart';
import '../../providers/use_case_providers.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/art_placeholder.dart';
import '../../widgets/focus_highlight.dart';
import '../../widgets/focus_hint_registry.dart';
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
  late final FocusNode _closeFocus;
  late final FocusNode _clearFocus;
  late final FocusNode _saveFocus;
  late final FocusNode _keyListenerFocusNode;
  final ScrollController _scrollController = ScrollController();
  final List<FocusNode> _itemFocusNodes = <FocusNode>[];
  bool _didRequestInitialFocus = false;
  int? _reorderOriginIndex;
  int? _reorderCurrentIndex;

  bool get _isReordering => _reorderCurrentIndex != null;

  @override
  void initState() {
    super.initState();
    _closeFocus = FocusNode(debugLabel: 'Queue-close');
    _clearFocus = FocusNode(debugLabel: 'Queue-clear');
    _saveFocus = FocusNode(debugLabel: 'Queue-save');
    _keyListenerFocusNode = FocusNode(debugLabel: 'QueuePanel-keyListener')
      ..skipTraversal = true;
    GamepadScrollTarget.set(_scrollController);
    FocusManager.instance.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_handleFocusChange);
    setQueuePanelHintState(null);
    _closeFocus.dispose();
    _clearFocus.dispose();
    _saveFocus.dispose();
    _keyListenerFocusNode.dispose();
    for (final node in _itemFocusNodes) {
      node.dispose();
    }
    GamepadScrollTarget.clear(_scrollController);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    _publishHintState();
  }

  void _syncItemFocusNodes(int count) {
    while (_itemFocusNodes.length < count) {
      _itemFocusNodes.add(
        FocusNode(debugLabel: 'Queue-item-${_itemFocusNodes.length}'),
      );
    }
    while (_itemFocusNodes.length > count) {
      final node = _itemFocusNodes.removeLast();
      node.dispose();
    }
  }

  int? _focusedItemIndex() {
    for (var index = 0; index < _itemFocusNodes.length; index++) {
      if (_itemFocusNodes[index].hasFocus) return index;
    }
    return null;
  }

  void _focusQueueIndex(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || index < 0 || index >= _itemFocusNodes.length) return;
      _itemFocusNodes[index].requestFocus();
      _publishHintState();
    });
  }

  void _ensureInitialFocus(List<Song> queue, Song? currentSong) {
    if (_didRequestInitialFocus) return;
    _didRequestInitialFocus = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (queue.isEmpty) {
        _closeFocus.requestFocus();
        _publishHintState();
        return;
      }
      final initialIndex = currentSong == null
          ? 0
          : queue.indexWhere((song) => song.id == currentSong.id);
      _focusQueueIndex(initialIndex >= 0 ? initialIndex : 0);
    });
  }

  void _publishHintState() {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final focusedItemIndex = _focusedItemIndex();

    if (_isReordering && focusedItemIndex != null) {
      final canMoveUp = focusedItemIndex > 0;
      final canMoveDown = focusedItemIndex < _itemFocusNodes.length - 1;
      setQueuePanelHintState(
        QueuePanelHintState(
          aLabel: l10n.confirm,
          bLabel: l10n.cancel,
          xLabel: l10n.exitReorder,
          upLabel: l10n.hintMoveUp,
          downLabel: l10n.hintMoveDown,
          onAPressed: _confirmReorder,
          onBPressed: _cancelReorder,
          onXPressed: _confirmReorder,
          onUpPressed: canMoveUp ? () => _moveReorder(-1) : null,
          onDownPressed: canMoveDown ? () => _moveReorder(1) : null,
        ),
      );
      return;
    }

    if (focusedItemIndex != null) {
      setQueuePanelHintState(
        QueuePanelHintState(
          aLabel: l10n.hintPlay,
          bLabel: l10n.hintClose,
          xLabel: l10n.ctxReorder,
          yLabel: l10n.ctxRemoveFromQueue,
          onAPressed: () => _playQueueItem(focusedItemIndex),
          onBPressed: widget.onDismiss,
          onXPressed: () => _enterReorderMode(focusedItemIndex),
          onYPressed: () => _removeQueueItem(focusedItemIndex),
        ),
      );
      return;
    }

    final focusedCaps = focusedHintCapabilities.value;
    setQueuePanelHintState(
      QueuePanelHintState(
        aLabel: focusedCaps?.supportsA == true ? l10n.hintSelect : null,
        bLabel: l10n.hintClose,
        onAPressed: focusedCaps?.supportsA == true ? focusedCaps?.onA : null,
        onBPressed: _isReordering ? _cancelReorder : widget.onDismiss,
      ),
    );
  }

  void _playQueueItem(int index) {
    final queue = ref.read(playbackProvider).queue;
    if (index < 0 || index >= queue.length) return;
    ref.read(playbackProvider.notifier).playSong(
          queue[index],
          queue: queue,
          index: index,
        );
  }

  void _enterReorderMode(int index) {
    if (_isReordering || index < 0 || index >= _itemFocusNodes.length) return;
    setState(() {
      _reorderOriginIndex = index;
      _reorderCurrentIndex = index;
    });
    _focusQueueIndex(index);
  }

  void _confirmReorder() {
    if (!_isReordering) return;
    setState(() {
      _reorderOriginIndex = null;
      _reorderCurrentIndex = null;
    });
    _publishHintState();
  }

  void _cancelReorder() {
    final originIndex = _reorderOriginIndex;
    final currentIndex = _reorderCurrentIndex;
    if (originIndex == null || currentIndex == null) return;

    if (originIndex != currentIndex) {
      final node = _itemFocusNodes.removeAt(currentIndex);
      _itemFocusNodes.insert(originIndex, node);
      ref
          .read(playbackProvider.notifier)
          .reorderQueue(currentIndex, originIndex);
    }

    setState(() {
      _reorderOriginIndex = null;
      _reorderCurrentIndex = null;
    });
    _focusQueueIndex(originIndex);
  }

  void _moveReorder(int delta) {
    final currentIndex = _reorderCurrentIndex;
    if (currentIndex == null) return;
    final targetIndex =
        (currentIndex + delta).clamp(0, _itemFocusNodes.length - 1);
    if (targetIndex == currentIndex) return;

    final node = _itemFocusNodes.removeAt(currentIndex);
    _itemFocusNodes.insert(targetIndex, node);
    ref.read(playbackProvider.notifier).reorderQueue(currentIndex, targetIndex);
    setState(() => _reorderCurrentIndex = targetIndex);
    _focusQueueIndex(targetIndex);
  }

  Future<void> _removeQueueItem(int index) async {
    if (index < 0 || index >= _itemFocusNodes.length) return;
    final removedNode = _itemFocusNodes.removeAt(index);
    final nextFocusIndex = _itemFocusNodes.isEmpty
        ? null
        : index.clamp(0, _itemFocusNodes.length - 1);

    await ref.read(playbackProvider.notifier).removeFromQueue(index);

    if (_reorderOriginIndex != null && _reorderCurrentIndex != null) {
      if (index < _reorderOriginIndex!) {
        _reorderOriginIndex = _reorderOriginIndex! - 1;
      }
      if (index < _reorderCurrentIndex!) {
        _reorderCurrentIndex = _reorderCurrentIndex! - 1;
      } else if (index == _reorderCurrentIndex) {
        _reorderOriginIndex = null;
        _reorderCurrentIndex = null;
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      removedNode.dispose();
      if (!mounted) return;
      if (nextFocusIndex != null && nextFocusIndex < _itemFocusNodes.length) {
        _itemFocusNodes[nextFocusIndex].requestFocus();
      } else {
        _closeFocus.requestFocus();
      }
      _publishHintState();
    });
  }

  KeyEventResult _handleItemKey(int index, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;

    if (_isReordering && _reorderCurrentIndex == index) {
      if (key == LogicalKeyboardKey.arrowUp) {
        _moveReorder(-1);
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.arrowDown) {
        _moveReorder(1);
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.enter ||
          key == LogicalKeyboardKey.space ||
          key == LogicalKeyboardKey.gameButtonA ||
          key == LogicalKeyboardKey.keyA) {
        _confirmReorder();
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.escape ||
          key == LogicalKeyboardKey.gameButtonB ||
          key == LogicalKeyboardKey.keyB) {
        _cancelReorder();
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.gameButtonX ||
          key == LogicalKeyboardKey.keyX) {
        _confirmReorder();
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.gameButtonY ||
          key == LogicalKeyboardKey.keyY ||
          key == LogicalKeyboardKey.delete) {
        return KeyEventResult.handled;
      }
    }

    if (key == LogicalKeyboardKey.delete) {
      _removeQueueItem(index);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  KeyEventResult _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.escape ||
        event.logicalKey == LogicalKeyboardKey.gameButtonB ||
        event.logicalKey == LogicalKeyboardKey.keyB) {
      if (_isReordering) {
        _cancelReorder();
        return KeyEventResult.handled;
      }
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
    final queueItems = queue
        .asMap()
        .entries
        .map((e) => QueueItem(song: e.value, sortOrder: e.key))
        .toList();

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
    final l10n = AppLocalizations.of(context)!;
    final queue = ref.watch(
      playbackProvider.select((s) => s.queue),
    );
    final currentSong = ref.watch(
      playbackProvider.select((s) => s.currentSong),
    );

    _syncItemFocusNodes(queue.length);
    _ensureInitialFocus(queue, currentSong);
    WidgetsBinding.instance.addPostFrameCallback((_) => _publishHintState());

    return KeyboardListener(
      focusNode: _keyListenerFocusNode,
      onKeyEvent: _handleKey,
      child: FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: SizedBox(
          width: AppConstants.queuePanelWidth,
          child: Container(
            color: ext.bgSurface,
            child: Column(
              children: [
                // ── Header ───────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 0, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.queue,
                          style: tt.titleLarge?.copyWith(
                            color: ext.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Spacer(),
                      // Dismiss
                      FocusTraversalOrder(
                        order: const NumericFocusOrder(0),
                        child: _IconBtn(
                          focusNode: _closeFocus,
                          icon: LucideIcons.x,
                          tooltip: l10n.hintClose,
                          onTap: widget.onDismiss,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),

                // ── Action row ───────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: FocusTraversalOrder(
                          order: const NumericFocusOrder(1),
                          child: _QueueActionBtn(
                            focusNode: _clearFocus,
                            icon: LucideIcons.trash2,
                            label: l10n.clearQueue,
                            onTap: queue.isEmpty
                                ? null
                                : () => ref
                                    .read(playbackProvider.notifier)
                                    .clearQueue(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FocusTraversalOrder(
                          order: const NumericFocusOrder(2),
                          child: _QueueActionBtn(
                            focusNode: _saveFocus,
                            icon: LucideIcons.save,
                            label: l10n.queueSaveTitle,
                            onTap: queue.isEmpty
                                ? null
                                : () =>
                                    _saveQueueAsPlaylist(context, ref, queue),
                          ),
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
                          buildDefaultDragHandles: false,
                          scrollController: _scrollController,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: queue.length,
                          onReorder: (oldIndex, newIndex) {
                            if (newIndex > oldIndex) newIndex--;
                            ref
                                .read(playbackProvider.notifier)
                                .reorderQueue(oldIndex, newIndex);
                          },
                          itemBuilder: (ctx, i) {
                            final song = queue[i];
                            final isCurrent = song.id == currentSong?.id;
                            return _QueueItem(
                              key: ValueKey(
                                  '${song.id}-$i'), // index-keyed to handle duplicates
                              focusNode: _itemFocusNodes[i],
                              song: song,
                              index: i,
                              isCurrent: isCurrent,
                              isReordering:
                                  _isReordering && _reorderCurrentIndex == i,
                              onTap: () => _playQueueItem(i),
                              onRemove: () => _removeQueueItem(i),
                              onToggleReorder: () {
                                if (_isReordering &&
                                    _reorderCurrentIndex == i) {
                                  _confirmReorder();
                                } else {
                                  _enterReorderMode(i);
                                }
                              },
                              onKeyEvent: (event) => _handleItemKey(i, event),
                            );
                          },
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
// Queue item
// ---------------------------------------------------------------------------

class _QueueItem extends StatelessWidget {
  const _QueueItem({
    super.key,
    required this.focusNode,
    required this.song,
    required this.index,
    required this.isCurrent,
    required this.isReordering,
    required this.onTap,
    required this.onRemove,
    required this.onToggleReorder,
    required this.onKeyEvent,
  });

  final FocusNode focusNode;
  final Song song;
  final int index;
  final bool isCurrent;
  final bool isReordering;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final VoidCallback onToggleReorder;
  final KeyEventResult Function(KeyEvent event) onKeyEvent;

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;
    final accent = Theme.of(context).colorScheme.primary;

    return FocusHighlight(
      focusNode: focusNode,
      borderRadius: 0,
      onPressed: isReordering ? onToggleReorder : onTap,
      onSecondary: onToggleReorder,
      onTertiary: isReordering ? null : onRemove,
      showYHint: !isReordering,
      onKeyEvent: (_, event) => onKeyEvent(event),
      child: GestureDetector(
        onTap: isReordering ? onToggleReorder : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              // Drag handle
              MouseRegion(
                cursor: SystemMouseCursors.grab,
                child: ReorderableDragStartListener(
                  index: index,
                  child: Icon(
                    isReordering
                        ? LucideIcons.arrowUpDown
                        : LucideIcons.gripVertical,
                    size: 14,
                    color: isReordering ? accent : ext.textTertiary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Art
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  width: AppConstants.queueItemArtSize,
                  height: AppConstants.queueItemArtSize,
                  child: song.artCachePath != null &&
                          File(song.artCachePath!).existsSync()
                      ? Image.file(File(song.artCachePath!), fit: BoxFit.cover)
                      : const ArtPlaceholder(
                          size: AppConstants.queueItemArtSize),
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
                      song.title,
                      style: tt.bodySmall?.copyWith(
                        color: isReordering
                            ? accent
                            : (isCurrent ? accent : ext.textPrimary),
                        fontWeight: (isCurrent || isReordering)
                            ? FontWeight.w600
                            : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      song.artist,
                      style: tt.bodySmall?.copyWith(color: ext.textTertiary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
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
// Small helpers
// ---------------------------------------------------------------------------

class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.icon,
    required this.onTap,
    this.focusNode,
    this.tooltip = '',
  });
  final IconData icon;
  final VoidCallback onTap;
  final FocusNode? focusNode;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    return Tooltip(
      message: tooltip,
      child: FocusHighlight(
        focusNode: focusNode,
        borderRadius: AppConstants.btnRadius,
        onPressed: onTap,
        child: GestureDetector(
          onTap: onTap,
          child: SizedBox(
            width: AppConstants.minFocusableSize,
            height: AppConstants.minFocusableSize,
            child: Icon(icon, size: 18, color: ext.textSecondary),
          ),
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
