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
import '../../../providers/playback_provider.dart';
import '../../../providers/toast_provider.dart';
import '../../../providers/use_case_providers.dart';
import '../../../helpers/add_to_playlist_helper.dart';
import '../library_folder_commands.dart';
import '../../../widgets/context_menu.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/focus_highlight.dart';
import '../../../widgets/song_list_tile.dart';

/// Folders tab — hierarchical folder browser with breadcrumb navigation.
///
/// Gamepad: B button = go up one level.
class FoldersTab extends ConsumerStatefulWidget {
  const FoldersTab({super.key});

  @override
  ConsumerState<FoldersTab> createState() => _FoldersTabState();
}

class _FoldersTabState extends ConsumerState<FoldersTab> {
  final List<String> _pathStack = []; // empty = root
  late final FocusNode _defaultFocus;
  late final FocusNode _keyListenerFocusNode;
  int _lastGoUpRequest = 0;

  String? get _currentPath => _pathStack.isEmpty ? null : _pathStack.last;

  @override
  void initState() {
    super.initState();
    _defaultFocus = FocusNode(debugLabel: 'FoldersTab-default');
    _keyListenerFocusNode = FocusNode(debugLabel: 'FoldersTab-keyListener')..skipTraversal = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _defaultFocus.requestFocus();
    });
    libraryFoldersCanGoUp.value = _pathStack.isNotEmpty;
    libraryFoldersGoUpRequest.addListener(_handleGoUpRequest);
  }

  @override
  void dispose() {
    libraryFoldersGoUpRequest.removeListener(_handleGoUpRequest);
    libraryFoldersCanGoUp.value = false;
    _defaultFocus.dispose();
    _keyListenerFocusNode.dispose();
    super.dispose();
  }

  void _handleGoUpRequest() {
    final next = libraryFoldersGoUpRequest.value;
    if (next == _lastGoUpRequest) return;
    _lastGoUpRequest = next;
    _goUp();
  }

  void _navigateTo(String path) {
    setState(() => _pathStack.add(path));
    libraryFoldersCanGoUp.value = _pathStack.isNotEmpty;
    WidgetsBinding.instance.addPostFrameCallback((_) => _defaultFocus.requestFocus());
  }

  void _goUp() {
    if (_pathStack.isEmpty) return;
    setState(_pathStack.removeLast);
    libraryFoldersCanGoUp.value = _pathStack.isNotEmpty;
    WidgetsBinding.instance.addPostFrameCallback((_) => _defaultFocus.requestFocus());
  }

  KeyEventResult _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if ((event.logicalKey == LogicalKeyboardKey.escape || event.logicalKey == LogicalKeyboardKey.gameButtonB) && _pathStack.isNotEmpty) {
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
    final folderContentsUseCase = ref.watch(getFolderContentsProvider);

    return KeyboardListener(
      focusNode: _keyListenerFocusNode,
      onKeyEvent: _handleKey,
      child: Column(
        children: [
          // ── Breadcrumb ───────────────────────────────────────────────
          if (_pathStack.isNotEmpty)
            _Breadcrumb(
              pathStack: _pathStack,
              onUp: _goUp,
              onNavigateTo: (i) {
                setState(() => _pathStack.removeRange(i + 1, _pathStack.length));
                libraryFoldersCanGoUp.value = _pathStack.isNotEmpty;
              },
            ),

          // ── Content ──────────────────────────────────────────────────
          Expanded(
            child: FutureBuilder<({List<String> subFolders, List<Song> songs})>(
              future: folderContentsUseCase.call(_currentPath).then(
                    (r) => r.when(
                      success: (c) => c,
                      failure: (_) => (subFolders: <String>[], songs: <Song>[]),
                    ),
                  ),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final data = snap.data ?? (subFolders: <String>[], songs: <Song>[]);
                if (data.subFolders.isEmpty && data.songs.isEmpty) {
                  return const EmptyState(
                    icon: LucideIcons.folderOpen,
                    title: 'Empty Folder',
                    subtitle: 'No music files or sub-folders found here.',
                  );
                }
                final subFolderCount = data.subFolders.length;
                final totalCount = subFolderCount + data.songs.length;
                return ListView.builder(
                  itemCount: totalCount,
                  itemBuilder: (listCtx, i) {
                    if (i < subFolderCount) {
                      final path = data.subFolders[i];
                      return _FolderItem(
                        path: path,
                        focusNode: i == 0 ? _defaultFocus : null,
                        onTap: () => _navigateTo(path),
                      );
                    }

                    final songIndex = i - subFolderCount;
                    final song = data.songs[songIndex];
                    return SongListTile(
                      key: ValueKey(song.id),
                      focusNode: subFolderCount == 0 && songIndex == 0 ? _defaultFocus : null,
                      song: song,
                      isCurrentlyPlaying: song.id == currentSongId,
                      isFavorite: song.isFavorite,
                      onTap: () => ref.read(playbackProvider.notifier).playSong(
                            song,
                            queue: data.songs,
                            index: songIndex,
                            sourceType: QueueSourceType.folder,
                          ),
                      onContextMenu: () => _showContextMenu(listCtx, song, data.songs, songIndex),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showContextMenu(
    BuildContext ctx,
    Song song,
    List<Song> songs,
    int index,
  ) async {
    final box = ctx.findRenderObject() as RenderBox?;
    final pos = box?.localToGlobal(Offset.zero) ?? Offset.zero;
    final l10n = AppLocalizations.of(ctx)!;
    await showAppContextMenu(
      context: ctx,
      position: pos,
      entries: [
        ContextMenuItem(
          label: l10n.ctxPlay,
          icon: LucideIcons.play,
          onTap: () => ref.read(playbackProvider.notifier).playSong(song, queue: songs, index: index, sourceType: QueueSourceType.folder),
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
          label: song.isFavorite ? l10n.ctxRemoveFromFavorites : l10n.ctxAddToFavorites,
          icon: song.isFavorite ? LucideIcons.heartOff : LucideIcons.heart,
          onTap: () => ref.read(favoritesProvider().notifier).toggleFavorite(song.id, isFavorite: song.isFavorite),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Folder item tile
// ---------------------------------------------------------------------------

class _FolderItem extends StatefulWidget {
  const _FolderItem({required this.path, required this.onTap, this.focusNode});
  final String path;
  final VoidCallback onTap;
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
                Icon(LucideIcons.chevronRight, size: 16, color: ext.textTertiary),
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
            child: Icon(LucideIcons.folderOpen, size: 16, color: ext.textTertiary),
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
                          color: e.key == pathStack.length - 1 ? ext.textPrimary : ext.textTertiary,
                        ),
                      ),
                    ),
                    if (e.key < pathStack.length - 1) Icon(LucideIcons.chevronRight, size: 12, color: ext.textTertiary),
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
