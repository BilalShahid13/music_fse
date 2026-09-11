import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../domain/entities/playback_state.dart';
import '../../../../domain/entities/song.dart';
import '../../../providers/favorites_provider.dart';
import '../../../providers/library_provider.dart';
import '../../../providers/multi_select_provider.dart';
import '../../../providers/playback_provider.dart';
import '../../../providers/toast_provider.dart';
import '../../../helpers/active_focus_request.dart';
import '../../../helpers/add_to_playlist_helper.dart';
import '../library_folder_commands.dart';
import '../library_selection_commands.dart';
import '../../../widgets/context_menu.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/focus_highlight.dart';
import '../../../widgets/selectable_song_tile.dart';

/// Folders tab — hierarchical folder browser with breadcrumb navigation.
///
/// Gamepad: B button = go up one level.
class FoldersTab extends ConsumerStatefulWidget {
  const FoldersTab({
    super.key,
    this.scrollController,
    this.isActive = false,
  });

  final ScrollController? scrollController;
  final bool isActive;

  @override
  ConsumerState<FoldersTab> createState() => _FoldersTabState();
}

class _FoldersTabState extends ConsumerState<FoldersTab> {
  final List<String> _pathStack = []; // empty = root
  late final FocusNode _defaultFocus;
  int _lastGoUpRequest = 0;
  bool _awaitingVisibleDefaultFocus = true;

  String? get _currentPath => _pathStack.isEmpty ? null : _pathStack.last;

  @override
  void initState() {
    super.initState();
    _defaultFocus = FocusNode(debugLabel: 'FoldersTab-default');
    scheduleActiveFocusRequest(state: this, focusNode: _defaultFocus);
    libraryFoldersCanGoUp.value = _pathStack.isNotEmpty;
    libraryFoldersGoUpRequest.addListener(_handleGoUpRequest);
  }

  @override
  void dispose() {
    if (widget.isActive) {
      _clearLibrarySelectionCommands();
    }
    libraryFoldersGoUpRequest.removeListener(_handleGoUpRequest);
    libraryFoldersCanGoUp.value = false;
    _defaultFocus.dispose();
    super.dispose();
  }

  void _handleGoUpRequest() {
    final next = libraryFoldersGoUpRequest.value;
    if (next == _lastGoUpRequest) return;
    _lastGoUpRequest = next;
    _goUp();
  }

  void _navigateTo(String path) {
    _cancelSelection();
    _awaitingVisibleDefaultFocus = true;
    setState(() => _pathStack.add(path));
    libraryFoldersCanGoUp.value = _pathStack.isNotEmpty;
    scheduleActiveFocusRequest(state: this, focusNode: _defaultFocus);
  }

  void _goUp() {
    if (_pathStack.isEmpty) return;
    _cancelSelection();
    _awaitingVisibleDefaultFocus = true;
    setState(_pathStack.removeLast);
    libraryFoldersCanGoUp.value = _pathStack.isNotEmpty;
    scheduleActiveFocusRequest(state: this, focusNode: _defaultFocus);
  }

  KeyEventResult _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final multiSelect = ref.read(multiSelectProvider);
    if (multiSelect.isActive) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.escape:
        case LogicalKeyboardKey.gameButtonB:
        case LogicalKeyboardKey.keyB:
          _cancelSelection();
          return KeyEventResult.handled;
        case LogicalKeyboardKey.gameButtonX:
        case LogicalKeyboardKey.keyX:
          if (multiSelect.selectedIds.isNotEmpty) {
            _addSelectionToQueue();
            return KeyEventResult.handled;
          }
        case LogicalKeyboardKey.gameButtonY:
        case LogicalKeyboardKey.keyY:
          if (multiSelect.selectedIds.isNotEmpty) {
            _addSelectionToPlaylist();
            return KeyEventResult.handled;
          }
        case LogicalKeyboardKey.gameButtonLeft1:
        case LogicalKeyboardKey.keyQ:
          _selectAllVisibleSongs();
          return KeyEventResult.handled;
        case LogicalKeyboardKey.gameButtonRight1:
        case LogicalKeyboardKey.keyE:
          return KeyEventResult.handled;
      }
    }

    if ((event.logicalKey == LogicalKeyboardKey.escape ||
            event.logicalKey == LogicalKeyboardKey.gameButtonB ||
            event.logicalKey == LogicalKeyboardKey.keyB) &&
        _pathStack.isNotEmpty) {
      _goUp();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final currentSongId = ref.watch(
      playbackProvider.select((s) => s.currentSong?.id),
    );
    final folderContentsAsync = ref.watch(folderContentsProvider(_currentPath));
    final multiSelect = ref.watch(multiSelectProvider);

    if (widget.isActive) {
      _syncLibrarySelectionCommands(multiSelect.isActive);
    }

    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: (_, event) => _handleKey(event),
      child: Column(
        children: [
          // ── Breadcrumb ───────────────────────────────────────────────
          if (_pathStack.isNotEmpty)
            _Breadcrumb(
              pathStack: _pathStack,
              onUp: _goUp,
              onNavigateTo: (i) {
                _cancelSelection();
                setState(() => _pathStack.removeRange(i + 1, _pathStack.length));
                libraryFoldersCanGoUp.value = _pathStack.isNotEmpty;
              },
            ),

          // ── Content ──────────────────────────────────────────────────
          Expanded(
            child: folderContentsAsync.when(
              data: (data) {
                if (data.subFolders.isEmpty && data.songs.isEmpty) {
                  return const EmptyState(
                    icon: LucideIcons.folderOpen,
                    title: 'Empty Folder',
                    subtitle: 'No music files or sub-folders found here.',
                  );
                }

                _ensureDefaultFocusWhenVisible();

                final subFolderCount = data.subFolders.length;
                final totalCount = subFolderCount + data.songs.length;
                return ListView.builder(
                  controller: widget.scrollController,
                  itemCount: totalCount,
                  itemBuilder: (listCtx, i) {
                    if (i < subFolderCount) {
                      final path = data.subFolders[i];
                      return _FolderItem(
                        key: ValueKey(path),
                        path: path,
                        focusNode: i == 0 ? _defaultFocus : null,
                        onTap:
                            multiSelect.isActive ? null : () => _navigateTo(path),
                      );
                    }

                    final songIndex = i - subFolderCount;
                    final song = data.songs[songIndex];
                    return SelectableSongTile(
                      key: ValueKey(song.id),
                      focusNode: subFolderCount == 0 && songIndex == 0
                          ? _defaultFocus
                          : null,
                      song: song,
                      isCurrentlyPlaying: song.id == currentSongId,
                      isFavorite: song.isFavorite,
                      onTap: () => ref.read(playbackProvider.notifier).playSong(
                            song,
                            queue: data.songs,
                            index: songIndex,
                            sourceType: QueueSourceType.folder,
                          ),
                      onContextMenu: () => _showContextMenu(
                          listCtx, song, data.songs, songIndex),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const EmptyState(
                icon: LucideIcons.folderOpen,
                title: 'Empty Folder',
                subtitle: 'No music files or sub-folders found here.',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _syncLibrarySelectionCommands(bool isSelectionActive) {
    librarySelectionAddToQueue.value =
        isSelectionActive ? _addSelectionToQueue : null;
    librarySelectionAddToPlaylist.value =
        isSelectionActive ? _addSelectionToPlaylist : null;
    librarySelectionSelectAll.value =
        isSelectionActive ? _selectAllVisibleSongs : null;
    librarySelectionCancel.value = isSelectionActive ? _cancelSelection : null;
  }

  void _clearLibrarySelectionCommands() {
    librarySelectionAddToQueue.value = null;
    librarySelectionAddToPlaylist.value = null;
    librarySelectionSelectAll.value = null;
    librarySelectionCancel.value = null;
  }

  void _cancelSelection() {
    ref.read(multiSelectProvider.notifier).deactivate();
  }

  void _selectAllVisibleSongs() {
    final songs = _visibleSongs();
    if (songs.isEmpty) return;
    ref.read(multiSelectProvider.notifier).selectAll(
          songs.map((song) => song.id).toList(growable: false),
        );
  }

  void _addSelectionToQueue() {
    final selectedIds = ref.read(multiSelectProvider).selectedIds;
    if (selectedIds.isEmpty) return;

    final selectedSongs =
        _visibleSongs().where((song) => selectedIds.contains(song.id));
    final notifier = ref.read(playbackProvider.notifier);
    for (final song in selectedSongs) {
      notifier.addToQueue(song);
    }

    ref.read(toastProvider.notifier).show(
          AppLocalizations.of(context)!.addedManyToQueue(selectedIds.length),
        );
    _cancelSelection();
  }

  void _addSelectionToPlaylist() {
    final selectedIds =
        ref.read(multiSelectProvider).selectedIds.toList(growable: false);
    if (selectedIds.isEmpty) return;
    handleAddManyToPlaylist(context, ref, selectedIds);
  }

  List<Song> _visibleSongs() {
    return ref.read(folderContentsProvider(_currentPath)).asData?.value.songs ??
        const <Song>[];
  }

  void _ensureDefaultFocusWhenVisible() {
    if (!_awaitingVisibleDefaultFocus) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (requestFocusIfActive(_defaultFocus)) {
        _awaitingVisibleDefaultFocus = false;
      }
    });
  }

  Future<void> _showContextMenu(
    BuildContext ctx,
    Song song,
    List<Song> songs,
    int index,
  ) async {
    final pos = _resolveMenuAnchor(ctx);
    final l10n = AppLocalizations.of(ctx)!;
    await showAppContextMenu(
      context: ctx,
      position: pos,
      entries: [
        ContextMenuItem(
          label: l10n.ctxPlay,
          icon: LucideIcons.play,
          onTap: () => ref.read(playbackProvider.notifier).playSong(song,
              queue: songs, index: index, sourceType: QueueSourceType.folder),
        ),
        ContextMenuItem(
          label: l10n.ctxAddToQueue,
          icon: LucideIcons.listPlus,
          onTap: () {
            ref.read(playbackProvider.notifier).addToQueue(song);
            ref.read(toastProvider.notifier).show(l10n.addedToQueue);
          },
        ),
        ContextMenuItem(
          label: l10n.ctxAddToPlaylist,
          icon: LucideIcons.listMusic,
          onTap: () => handleAddToPlaylist(ctx, ref, song.id),
        ),
        const ContextMenuSeparator(),
        ContextMenuItem(
          label: song.isFavorite
              ? l10n.ctxRemoveFromFavorites
              : l10n.ctxAddToFavorites,
          icon: song.isFavorite ? LucideIcons.heartOff : LucideIcons.heart,
          onTap: () => ref
              .read(favoritesProvider().notifier)
              .toggleFavorite(song.id, isFavorite: song.isFavorite),
        ),
      ],
    );
  }

  Offset _resolveMenuAnchor(BuildContext ctx) {
    final direct = ctx.findRenderObject();
    if (direct is RenderBox) {
      return direct.localToGlobal(Offset.zero);
    }

    final focusedCtx = FocusManager.instance.primaryFocus?.context;
    final focusedRender = focusedCtx?.findRenderObject();
    if (focusedRender is RenderBox) {
      return focusedRender.localToGlobal(Offset.zero);
    }

    final overlayRender = Overlay.maybeOf(ctx)?.context.findRenderObject();
    if (overlayRender is RenderBox) {
      final center = overlayRender.size.center(Offset.zero);
      return overlayRender.localToGlobal(center);
    }

    return Offset.zero;
  }
}

// ---------------------------------------------------------------------------
// Folder item tile
// ---------------------------------------------------------------------------

class _FolderItem extends StatefulWidget {
  const _FolderItem({super.key, required this.path, this.onTap, this.focusNode});
  final String path;
  final VoidCallback? onTap;
  final FocusNode? focusNode;

  @override
  State<_FolderItem> createState() => _FolderItemState();
}

class _FolderItemState extends State<_FolderItem> {
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
    final sizes = AppSizes.of(context);
    final name = widget.path.split('/').last.split('\\').last;

    return FocusHighlight(
      focusNode: _focus,
      borderRadius: 0,
      onPressed: widget.onTap,
      child: GestureDetector(
        onTap: widget.onTap,
        child: SizedBox(
          height: AppConstants.listTileHeight,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: sizes.screenEdgePadding),
            child: Row(
              children: [
                Icon(LucideIcons.folder, size: 20, color: ext.textTertiary),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    name,
                    style: tt.bodyMedium?.copyWith(color: ext.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(LucideIcons.chevronRight,
                    size: 16, color: ext.textTertiary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Breadcrumb bar
// ---------------------------------------------------------------------------

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb({
    required this.pathStack,
    required this.onUp,
    required this.onNavigateTo,
  });
  final List<String> pathStack;
  final VoidCallback onUp;
  final void Function(int index) onNavigateTo;

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;
    final sizes = AppSizes.of(context);

    return Container(
      height: 40,
      color: ext.bgSurface,
      padding: EdgeInsets.symmetric(horizontal: sizes.screenEdgePadding),
      child: Row(
        children: [
          GestureDetector(
            onTap: onUp,
            child:
                Icon(LucideIcons.folderOpen, size: 16, color: ext.textTertiary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: pathStack.asMap().entries.expand((e) {
                  final name = e.value.split('/').last.split('\\').last;
                  return [
                    GestureDetector(
                      onTap: () => onNavigateTo(e.key),
                      child: Text(
                        name,
                        style: tt.bodySmall?.copyWith(
                          color: e.key == pathStack.length - 1
                              ? ext.textPrimary
                              : ext.textTertiary,
                        ),
                      ),
                    ),
                    if (e.key < pathStack.length - 1)
                      Icon(LucideIcons.chevronRight,
                          size: 12, color: ext.textTertiary),
                  ];
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
