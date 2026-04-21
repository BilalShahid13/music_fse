import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../domain/entities/playback_state.dart';
import '../../../../domain/entities/song.dart';
import '../../../providers/favorites_provider.dart';
import '../../../providers/library_provider.dart';
import '../../../providers/playback_provider.dart';
import '../../../providers/toast_provider.dart';
import '../../../providers/sort_preference_provider.dart';
import '../../../providers/multi_select_provider.dart';
import '../../../helpers/add_to_playlist_helper.dart';
import '../library_selection_commands.dart';
import '../../../widgets/context_menu.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/selectable_song_tile.dart';

/// Displays all songs in the library as a virtualized list.
///
/// Gamepad: D-pad up/down to navigate, A to play, X for context menu, Y to favorite.
class SongsTab extends ConsumerStatefulWidget {
  const SongsTab({super.key, this.defaultItemFocusNode});

  final FocusNode? defaultItemFocusNode;

  @override
  ConsumerState<SongsTab> createState() => _SongsTabState();
}

class _SongsTabState extends ConsumerState<SongsTab> {
  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final multiSelect = ref.read(multiSelectProvider);
    if (!multiSelect.isActive) return KeyEventResult.ignored;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.escape:
      case LogicalKeyboardKey.gameButtonB:
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

    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    librarySelectionAddToQueue.value = null;
    librarySelectionAddToPlaylist.value = null;
    librarySelectionSelectAll.value = null;
    librarySelectionCancel.value = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sizes = AppSizes.of(context);

    final sortPrefAsync = ref.watch(
      sortPreferenceProvider('songs', defaultSortBy: 'title'),
    );
    final sortBy = sortPrefAsync.value?.sortBy ?? 'title';
    final ascending = sortPrefAsync.value?.ascending ?? true;

    final songsAsync = ref.watch(
      songsProvider(sortBy: sortBy, ascending: ascending),
    );
    final currentSongId = ref.watch(
      playbackProvider.select((s) => s.currentSong?.id),
    );

    final multiSelect = ref.watch(multiSelectProvider);
    librarySelectionAddToQueue.value = multiSelect.isActive ? _addSelectionToQueue : null;
    librarySelectionAddToPlaylist.value = multiSelect.isActive ? _addSelectionToPlaylist : null;
    librarySelectionSelectAll.value = multiSelect.isActive ? _selectAllVisibleSongs : null;
    librarySelectionCancel.value = multiSelect.isActive ? _cancelSelection : null;

    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: _handleKey,
      child: songsAsync.when(
        data: (songs) {
          if (songs.isEmpty) {
            return EmptyState(
              icon: LucideIcons.music,
              title: l10n.noSongs,
              subtitle: l10n.noSongsMessage,
              actionLabel: l10n.settingsLibrary,
              onAction: () => context.go('/settings'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 4),
            itemCount: songs.length,
            itemBuilder: (ctx, i) {
              final song = songs[i];
              return SelectableSongTile(
                key: ValueKey(song.id),
                song: song,
                focusNode: i == 0 ? widget.defaultItemFocusNode : null,
                horizontalPadding: sizes.screenEdgePadding,
                isCurrentlyPlaying: song.id == currentSongId,
                isFavorite: song.isFavorite,
                onTap: () => ref.read(playbackProvider.notifier).playSong(song, queue: songs, index: i, sourceType: QueueSourceType.allSongs),
                onContextMenu: () => _showContextMenu(ctx, song, songs, i),
                onToggleFavorite: () => ref.read(favoritesProvider().notifier).toggleFavorite(song.id, isFavorite: song.isFavorite),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => EmptyState(
          icon: LucideIcons.circleAlert,
          title: l10n.failedToLoadSongs,
          subtitle: l10n.tryRescanLibrary,
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
    // Position context menu near the triggering item, with safe fallbacks
    // when the incoming context is backed by a sliver render object.
    final pos = _resolveMenuAnchor(ctx);
    final l10n = AppLocalizations.of(ctx)!;
    await showAppContextMenu(
      context: ctx,
      position: pos,
      entries: [
        ContextMenuItem(
          label: l10n.ctxPlay,
          icon: LucideIcons.play,
          onTap: () => ref.read(playbackProvider.notifier).playSong(song, queue: songs, index: index, sourceType: QueueSourceType.allSongs),
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

    final selectedSongs = _visibleSongs().where((song) => selectedIds.contains(song.id));
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
    final selectedIds = ref.read(multiSelectProvider).selectedIds.toList(growable: false);
    if (selectedIds.isEmpty) return;
    handleAddManyToPlaylist(context, ref, selectedIds);
  }

  List<Song> _visibleSongs() {
    final sortPref = ref.read(sortPreferenceProvider('songs', defaultSortBy: 'title'));
    final sortBy = sortPref.value?.sortBy ?? 'title';
    final ascending = sortPref.value?.ascending ?? true;
    return ref.read(songsProvider(sortBy: sortBy, ascending: ascending)).asData?.value ?? const <Song>[];
  }
}
