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
import '../../../platform/xinput/gamepad_scroll_target_mixin.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/playback_provider.dart';
import '../../providers/toast_provider.dart';
import '../../helpers/active_focus_request.dart';
import '../../helpers/add_to_playlist_helper.dart';
import '../../widgets/art_placeholder.dart';
import '../../widgets/context_menu.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/focus_highlight.dart';
import '../../widgets/song_list_tile.dart';

/// Album detail screen.
///
/// Route: `/library/album/:albumName/:albumArtist`
class AlbumDetailPage extends ConsumerStatefulWidget {
  const AlbumDetailPage({
    super.key,
    required this.albumName,
    required this.albumArtist,
  });

  final String albumName;
  final String albumArtist;

  @override
  ConsumerState<AlbumDetailPage> createState() => _AlbumDetailPageState();
}

class _AlbumDetailPageState extends ConsumerState<AlbumDetailPage>
    with GamepadScrollTargetMixin {
  late final FocusNode _playAllFocus;
  late final FocusNode _keyListenerFocusNode;

  @override
  void initState() {
    super.initState();
    _playAllFocus = FocusNode(debugLabel: 'AlbumDetail-playAll');
    _keyListenerFocusNode = FocusNode(debugLabel: 'AlbumDetailPage-keyListener')
      ..skipTraversal = true;
    scheduleActiveFocusRequest(state: this, focusNode: _playAllFocus);
  }

  @override
  void dispose() {
    _playAllFocus.dispose();
    _keyListenerFocusNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.escape ||
        event.logicalKey == LogicalKeyboardKey.gameButtonB ||
        event.logicalKey == LogicalKeyboardKey.keyB) {
      context.pop();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;
    final songsAsync = ref.watch(
      songsByAlbumProvider(widget.albumName, widget.albumArtist),
    );
    final currentSongId = ref.watch(
      playbackProvider.select((s) => s.currentSong?.id),
    );
    final favorites = ref.watch(favoritesProvider());
    final currentRoute = ref.watch(navigationProvider);

    syncGamepadScrollTarget(currentRoute.startsWith('/library/album/'));

    return KeyboardListener(
      focusNode: _keyListenerFocusNode,
      onKeyEvent: _handleKey,
      child: Scaffold(
        backgroundColor: ext.bgDeep,
        body: Column(
          children: [
            Expanded(
              child: songsAsync.when(
                data: (songs) => _buildContent(
                    context, ext, tt, songs, currentSongId, favorites),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const EmptyState(
                  icon: LucideIcons.circleAlert,
                  title: 'Failed to load album',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppThemeExtension ext,
    TextTheme tt,
    List<Song> songs,
    int? currentSongId,
    AsyncValue<List<Song>> favorites,
  ) {
    final artPath = songs.isNotEmpty ? songs.first.artCachePath : null;
    final favoriteIds = favorites.value?.map((s) => s.id).toSet() ?? {};
    final totalMs = songs.fold<int>(0, (acc, s) => acc + s.durationMs);
    final minutes = (totalMs / 60000).floor();
    final year = songs.isNotEmpty ? songs.first.year : null;
    final sizes = AppSizes.of(context);

    return CustomScrollView(
      controller: gamepadScrollController,
      slivers: [
        // ── Header ────────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              sizes.screenEdgePadding,
              sizes.screenEdgePadding,
              sizes.screenEdgePadding,
              24,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Art
                ClipRRect(
                  borderRadius: BorderRadius.circular(sizes.cardRadiusSm),
                  child: SizedBox(
                    width: AppConstants.detailArtSize,
                    height: AppConstants.detailArtSize,
                    child: artPath != null && File(artPath).existsSync()
                        ? Image.file(
                            File(artPath),
                            fit: BoxFit.cover,
                          )
                        : const ArtPlaceholder(
                            size: AppConstants.detailArtSize),
                  ),
                ),
                const SizedBox(width: 24),
                // Info + actions
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Text(
                        widget.albumName,
                        style: tt.headlineMedium?.copyWith(
                          color: ext.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.albumArtist,
                        style: tt.bodyLarge?.copyWith(color: ext.textSecondary),
                      ),
                      if (year != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          '$year',
                          style:
                              tt.bodySmall?.copyWith(color: ext.textTertiary),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        '${songs.length} songs · $minutes min',
                        style: tt.bodySmall?.copyWith(color: ext.textTertiary),
                      ),
                      const SizedBox(height: 20),
                      // Action row
                      Row(
                        children: [
                          _ActionButton(
                            focusNode: _playAllFocus,
                            icon: LucideIcons.play,
                            label: 'Play All',
                            isPrimary: true,
                            onTap: songs.isEmpty
                                ? null
                                : () => ref
                                    .read(playbackProvider.notifier)
                                    .playSong(songs.first,
                                        queue: songs,
                                        index: 0,
                                        sourceType: QueueSourceType.album),
                          ),
                          const SizedBox(width: 10),
                          _ActionButton(
                            icon: LucideIcons.shuffle,
                            label: 'Shuffle',
                            onTap: songs.isEmpty
                                ? null
                                : () {
                                    final shuffled = List<Song>.from(songs)
                                      ..shuffle();
                                    ref
                                        .read(playbackProvider.notifier)
                                        .playSong(shuffled.first,
                                            queue: shuffled,
                                            index: 0,
                                            sourceType: QueueSourceType.album);
                                  },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Song list ─────────────────────────────────────────────────────
        SliverList.builder(
          itemCount: songs.length,
          itemBuilder: (ctx, i) {
            final song = songs[i];
            return SongListTile(
              key: ValueKey(song.id),
              song: song,
              index: i,
              isCurrentlyPlaying: song.id == currentSongId,
              isFavorite: favoriteIds.contains(song.id),
              onTap: () => ref.read(playbackProvider.notifier).playSong(song,
                  queue: songs, index: i, sourceType: QueueSourceType.album),
              onContextMenu: () => _showContextMenu(ctx, song),
              onToggleFavorite: () => ref
                  .read(favoritesProvider().notifier)
                  .toggleFavorite(song.id,
                      isFavorite: favoriteIds.contains(song.id)),
            );
          },
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  void _showContextMenu(BuildContext context, Song song) {
    final l10n = AppLocalizations.of(context)!;
    final box = context.findRenderObject() as RenderBox?;
    final position = box != null ? box.localToGlobal(Offset.zero) : Offset.zero;
    showAppContextMenu(
      context: context,
      position: position,
      entries: [
        ContextMenuItem(
          label: l10n.ctxPlayNext,
          icon: LucideIcons.skipForward,
          onTap: () {
            ref.read(playbackProvider.notifier).addToQueue(song);
            ref.read(toastProvider.notifier).show(l10n.addedToQueue);
          },
        ),
        ContextMenuItem(
          label: l10n.ctxAddToPlaylist,
          icon: LucideIcons.listMusic,
          onTap: () => handleAddToPlaylist(context, ref, song.id),
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
}

// ---------------------------------------------------------------------------
// Action button widget
// ---------------------------------------------------------------------------

class _ActionButton extends StatefulWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
    this.focusNode,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isPrimary;
  final FocusNode? focusNode;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
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

    return SizedBox(
      height: AppConstants.minFocusableSize,
      child: Center(
        child: FocusHighlight(
          focusNode: _focus,
          borderRadius: AppConstants.btnRadius,
          onPressed: widget.onTap,
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: widget.isPrimary ? cs.primary : ext.bgSurface,
                borderRadius: BorderRadius.circular(AppConstants.btnRadius),
                border: widget.isPrimary
                    ? null
                    : Border.all(color: ext.borderSubtle),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.icon,
                    size: 16,
                    color: widget.isPrimary ? Colors.white : ext.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.label,
                    style: tt.labelLarge?.copyWith(
                      color: widget.isPrimary ? Colors.white : ext.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
