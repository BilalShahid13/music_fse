import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/playback_state.dart';
import '../../../domain/entities/song.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/playback_provider.dart';
import '../../providers/toast_provider.dart';
import '../../providers/playlist_provider.dart';
import '../../helpers/add_to_playlist_helper.dart';
import '../../widgets/art_placeholder.dart';
import '../dialogs/confirm_dialog.dart';
import '../../widgets/context_menu.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/focus_highlight.dart';
import '../../widgets/song_list_tile.dart';

/// Playlist detail page — shows one playlist with its songs.
///
/// Route: `/playlists/:id`
class PlaylistDetailPage extends ConsumerStatefulWidget {
  const PlaylistDetailPage({super.key, required this.playlistId});
  final int playlistId;

  @override
  ConsumerState<PlaylistDetailPage> createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends ConsumerState<PlaylistDetailPage> {
  bool _isReorderMode = false;
  late final FocusNode _defaultFocus;
  late final FocusNode _keyListenerFocusNode;

  @override
  void initState() {
    super.initState();
    _defaultFocus = FocusNode(debugLabel: 'PlaylistDetail-default');
    _keyListenerFocusNode = FocusNode(debugLabel: 'PlaylistDetailPage-keyListener')..skipTraversal = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _defaultFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _defaultFocus.dispose();
    _keyListenerFocusNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    switch (event.logicalKey) {
      case LogicalKeyboardKey.escape:
      case LogicalKeyboardKey.gameButtonB:
        if (_isReorderMode) {
          setState(() => _isReorderMode = false);
          return KeyEventResult.handled;
        }
        context.pop();
        return KeyEventResult.handled;

      case LogicalKeyboardKey.gameButtonX:
        setState(() => _isReorderMode = !_isReorderMode);
        return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Future<void> _deletePlaylist() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.deletePlaylistConfirm(ref.read(playlistsProvider()).value?.firstWhere((p) => p.id == widget.playlistId).name ?? ''),
      message: l10n.deletePlaylistBody,
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
      isDangerous: true,
    );
    if (confirmed == true && mounted) {
      await ref.read(playlistsProvider().notifier).deletePlaylist(widget.playlistId);
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final sizes = AppSizes.of(context);
    final l10n = AppLocalizations.of(context)!;
    final playlistsAsync = ref.watch(playlistsProvider());
    final songsAsync = ref.watch(playlistSongsProvider(widget.playlistId));
    final currentSongId = ref.watch(
      playbackProvider.select((s) => s.currentSong?.id),
    );

    final playlist = playlistsAsync.value?.firstWhere(
      (p) => p.id == widget.playlistId,
      orElse: () => throw StateError('not found'),
    );

    return KeyboardListener(
      focusNode: _keyListenerFocusNode,
      onKeyEvent: _handleKey,
      child: Scaffold(
        backgroundColor: ext.bgDeep,
        body: songsAsync.when(
          data: (songs) => CustomScrollView(
            slivers: [
              // ── Header ────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(sizes.screenEdgePadding),
                  child: _PlaylistHeader(
                    playlistName: playlist?.name ?? l10n.playlist,
                    songCount: songs.length,
                    totalDurationMs: playlist?.totalDurationMs ?? 0,
                    artCachePath: playlist?.coverArtPath,
                    isSmart: playlist?.isSmart ?? false,
                    defaultFocus: _defaultFocus,
                    onPlayAll: songs.isEmpty ? null : () => ref.read(playbackProvider.notifier).playQueue(songs),
                    onShuffle: songs.isEmpty
                        ? null
                        : () {
                            final shuffled = List.of(songs)..shuffle();
                            ref.read(playbackProvider.notifier).playQueue(shuffled);
                          },
                    onDelete: playlist?.isSmart ?? true ? null : _deletePlaylist,
                    onToggleReorder: playlist?.isSmart ?? true ? null : () => setState(() => _isReorderMode = !_isReorderMode),
                    isReorderMode: _isReorderMode,
                  ),
                ),
              ),

              // ── Songs ─────────────────────────────────────────────────
              if (songs.isEmpty)
                SliverFillRemaining(
                  child: EmptyState(
                    icon: LucideIcons.music,
                    title: l10n.playlistIsEmpty,
                    subtitle: l10n.addSongsFromLibrary,
                  ),
                )
              else if (_isReorderMode)
                SliverFillRemaining(
                  child: ReorderableListView.builder(
                    itemCount: songs.length,
                    onReorder: (oldIndex, newIndex) {
                      if (newIndex > oldIndex) newIndex--;
                      ref.read(playlistSongsProvider(widget.playlistId).notifier).reorderSong(oldIndex, newIndex);
                    },
                    itemBuilder: (ctx, i) {
                      final song = songs[i];
                      return SongListTile(
                        key: ValueKey(song.id),
                        song: song,
                        index: i,
                        isCurrentlyPlaying: song.id == currentSongId,
                        isFavorite: song.isFavorite,
                        onTap: () => ref.read(playbackProvider.notifier).playSong(song, queue: songs, index: i, sourceType: QueueSourceType.playlist),
                        onContextMenu: () => _showContextMenu(ctx, song, songs, i),
                        trailing: Icon(LucideIcons.gripVertical, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      );
                    },
                  ),
                )
              else
                SliverList.builder(
                  itemCount: songs.length,
                  itemBuilder: (ctx, i) {
                    final song = songs[i];
                    return SongListTile(
                      key: ValueKey(song.id),
                      song: song,
                      index: i,
                      isCurrentlyPlaying: song.id == currentSongId,
                      isFavorite: song.isFavorite,
                      onTap: () => ref.read(playbackProvider.notifier).playSong(song, queue: songs, index: i, sourceType: QueueSourceType.playlist),
                      onContextMenu: () => _showContextMenu(ctx, song, songs, i),
                    );
                  },
                ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => EmptyState(
            icon: LucideIcons.circleAlert,
            title: l10n.failedToLoadSongs,
          ),
        ),
      ),
    );
  }

  Future<void> _showContextMenu(
    BuildContext ctx,
    Song song,
    List<Song> songs,
    int index,
  ) async {
    final l10n = AppLocalizations.of(ctx)!;
    final box = ctx.findRenderObject() as RenderBox?;
    final pos = box?.localToGlobal(Offset.zero) ?? Offset.zero;
    await showAppContextMenu(
      context: ctx,
      position: pos,
      entries: [
        ContextMenuItem(
          label: l10n.ctxPlay,
          icon: LucideIcons.play,
          onTap: () => ref.read(playbackProvider.notifier).playSong(song, queue: songs, index: index, sourceType: QueueSourceType.playlist),
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
          label: l10n.ctxRemoveFromPlaylist,
          icon: LucideIcons.listMinus,
          isDangerous: true,
          onTap: () => ref.read(playlistSongsProvider(widget.playlistId).notifier).removeSong(song.id),
        ),
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
// Playlist header
// ---------------------------------------------------------------------------

class _PlaylistHeader extends StatelessWidget {
  const _PlaylistHeader({
    required this.playlistName,
    required this.songCount,
    required this.totalDurationMs,
    required this.artCachePath,
    required this.isSmart,
    required this.defaultFocus,
    required this.isReorderMode,
    this.onPlayAll,
    this.onShuffle,
    this.onDelete,
    this.onToggleReorder,
  });

  final String playlistName;
  final int songCount;
  final int totalDurationMs;
  final String? artCachePath;
  final bool isSmart;
  final FocusNode defaultFocus;
  final bool isReorderMode;
  final VoidCallback? onPlayAll;
  final VoidCallback? onShuffle;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleReorder;

  String _formatDuration(int ms) {
    final d = Duration(milliseconds: ms);
    if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    }
    return '${d.inMinutes}m ${d.inSeconds.remainder(60)}s';
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final sizes = AppSizes.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Mosaic art (160×160) ────────────────────────────────────────
        ClipRRect(
          borderRadius: BorderRadius.circular(sizes.cardRadius),
          child: SizedBox(
            width: 160,
            height: 160,
            child: artCachePath != null && File(artCachePath!).existsSync()
                ? Image.file(File(artCachePath!), fit: BoxFit.cover)
                : const ArtPlaceholder(
                    size: 160,
                    icon: LucideIcons.listMusic,
                  ),
          ),
        ),
        const SizedBox(width: 24),

        // ── Info + actions ──────────────────────────────────────────────
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isSmart)
                Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: cs.primary.withOpacity(0.3)),
                  ),
                  child: Text(l10n.smartTag, style: tt.labelSmall?.copyWith(color: cs.primary)),
                ),
              Text(
                playlistName,
                style: tt.headlineMedium?.copyWith(
                  color: ext.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                l10n.songCountDuration(songCount, _formatDuration(totalDurationMs)),
                style: tt.bodySmall?.copyWith(color: ext.textTertiary),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  if (onPlayAll != null)
                    _ActionBtn(
                      focusNode: defaultFocus,
                      icon: LucideIcons.play,
                      label: l10n.playAll,
                      isPrimary: true,
                      onTap: onPlayAll!,
                    ),
                  if (onShuffle != null) ...[
                    const SizedBox(width: 10),
                    _ActionBtn(
                      icon: LucideIcons.shuffle,
                      label: l10n.shuffle,
                      onTap: onShuffle!,
                    ),
                  ],
                  if (onToggleReorder != null) ...[
                    const SizedBox(width: 10),
                    _ActionBtn(
                      icon: isReorderMode ? LucideIcons.check : LucideIcons.arrowUpDown,
                      label: isReorderMode ? l10n.done : l10n.ctxReorder,
                      onTap: onToggleReorder!,
                    ),
                  ],
                  if (onDelete != null) ...[
                    const SizedBox(width: 10),
                    _ActionBtn(
                      icon: LucideIcons.trash2,
                      label: l10n.delete,
                      isDestructive: true,
                      onTap: onDelete!,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Action button
// ---------------------------------------------------------------------------

class _ActionBtn extends StatefulWidget {
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.focusNode,
    this.isPrimary = false,
    this.isDestructive = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final FocusNode? focusNode;
  final bool isPrimary;
  final bool isDestructive;

  @override
  State<_ActionBtn> createState() => _ActionBtnState();
}

class _ActionBtnState extends State<_ActionBtn> {
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
    final cs = Theme.of(context).colorScheme;

    Color fgColor = ext.textPrimary;
    Color bgColor = ext.bgSurface;
    Color borderColor = ext.borderSubtle;

    if (widget.isPrimary) {
      bgColor = cs.primary;
      fgColor = Colors.white;
      borderColor = Colors.transparent;
    } else if (widget.isDestructive) {
      bgColor = ext.destructive.withOpacity(0.1);
      fgColor = ext.destructive;
      borderColor = ext.destructive.withOpacity(0.3);
    }

    return FocusHighlight(
      focusNode: _focus,
      borderRadius: AppConstants.btnRadius.toDouble(),
      onPressed: widget.onTap,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: AppConstants.minFocusableSize,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppConstants.btnRadius),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 14, color: fgColor),
              const SizedBox(width: 6),
              Text(widget.label, style: tt.labelSmall?.copyWith(color: fgColor)),
            ],
          ),
        ),
      ),
    );
  }
}
