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
import '../../widgets/album_card.dart';
import '../../widgets/art_placeholder.dart';
import '../../widgets/context_menu.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/focus_highlight.dart';
import '../../widgets/song_list_tile.dart';

/// Artist detail screen.
///
/// Route: `/library/artist/:artistName`
class ArtistDetailPage extends ConsumerStatefulWidget {
  const ArtistDetailPage({super.key, required this.artistName});
  final String artistName;

  @override
  ConsumerState<ArtistDetailPage> createState() => _ArtistDetailPageState();
}

class _ArtistDetailPageState extends ConsumerState<ArtistDetailPage>
    with GamepadScrollTargetMixin {
  late final FocusNode _playAllFocus;
  late final FocusNode _keyListenerFocusNode;

  @override
  void initState() {
    super.initState();
    _playAllFocus = FocusNode(debugLabel: 'ArtistDetail-playAll');
    _keyListenerFocusNode =
        FocusNode(debugLabel: 'ArtistDetailPage-keyListener')
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
    final sizes = AppSizes.of(context);
    final songsAsync = ref.watch(
      songsByArtistProvider(widget.artistName),
    );
    final albumsAsync = ref.watch(
      albumsProvider(sortBy: 'year', ascending: true),
    );
    final currentSongId = ref.watch(
      playbackProvider.select((s) => s.currentSong?.id),
    );
    final favorites = ref.watch(favoritesProvider());
    final currentRoute = ref.watch(navigationProvider);

    syncGamepadScrollTarget(currentRoute.startsWith('/library/artist/'));

    return KeyboardListener(
      focusNode: _keyListenerFocusNode,
      onKeyEvent: _handleKey,
      child: Scaffold(
        backgroundColor: ext.bgDeep,
        body: Column(
          children: [
            Expanded(
              child: songsAsync.when(
                data: (songs) {
                  final artistAlbums = albumsAsync.value
                          ?.where((a) => a.artist == widget.artistName)
                          .toList() ??
                      [];
                  final favoriteIds =
                      favorites.value?.map((s) => s.id).toSet() ?? {};
                  final artPath =
                      songs.isNotEmpty ? songs.first.artCachePath : null;

                  return CustomScrollView(
                    controller: gamepadScrollController,
                    slivers: [
                      // ── Artist header ─────────────────────────────────
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            sizes.screenEdgePadding,
                            sizes.screenEdgePadding,
                            sizes.screenEdgePadding,
                            20,
                          ),
                          child: Row(
                            children: [
                              // Circular art
                              ClipOval(
                                child: SizedBox(
                                  width: 120,
                                  height: 120,
                                  child: artPath != null &&
                                          File(artPath).existsSync()
                                      ? Image.file(File(artPath),
                                          fit: BoxFit.cover)
                                      : const ArtPlaceholder(size: 120),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.artistName,
                                      style: tt.headlineMedium?.copyWith(
                                        color: ext.textPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${songs.length} songs · ${artistAlbums.length} albums',
                                      style: tt.bodySmall
                                          ?.copyWith(color: ext.textTertiary),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        _ArtistActionBtn(
                                          focusNode: _playAllFocus,
                                          icon: LucideIcons.play,
                                          label: 'Play All',
                                          isPrimary: true,
                                          onTap: songs.isEmpty
                                              ? null
                                              : () => ref
                                                  .read(
                                                      playbackProvider.notifier)
                                                  .playSong(songs.first,
                                                      queue: songs,
                                                      index: 0,
                                                      sourceType:
                                                          QueueSourceType
                                                              .artist),
                                        ),
                                        const SizedBox(width: 10),
                                        _ArtistActionBtn(
                                          icon: LucideIcons.shuffle,
                                          label: 'Shuffle',
                                          onTap: songs.isEmpty
                                              ? null
                                              : () {
                                                  final shuffled =
                                                      List.from(songs)
                                                        ..shuffle();
                                                  ref
                                                      .read(playbackProvider
                                                          .notifier)
                                                      .playSong(
                                                          shuffled.first,
                                                          queue:
                                                              List<Song>.from(
                                                                  shuffled),
                                                          index: 0,
                                                          sourceType:
                                                              QueueSourceType
                                                                  .artist);
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

                      // ── Albums horizontal row ─────────────────────────
                      if (artistAlbums.isNotEmpty) ...[
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                                sizes.screenEdgePadding,
                                0,
                                sizes.screenEdgePadding,
                                8),
                            child: Text(
                              'Albums',
                              style: tt.titleMedium?.copyWith(
                                  color: ext.textPrimary,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: sizes.gridCardHeight + 16,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.symmetric(
                                  horizontal: sizes.screenEdgePadding),
                              itemCount: artistAlbums.length,
                              itemBuilder: (ctx, i) {
                                final album = artistAlbums[i];
                                return Padding(
                                  padding: EdgeInsets.only(
                                      right:
                                          i < artistAlbums.length - 1 ? 12 : 0),
                                  child: AlbumCard(
                                    albumName: album.name,
                                    artistName: album.artist,
                                    artCachePath: album.artCachePath,
                                    width: sizes.gridCardScrollRowWidth,
                                    onTap: () => context.go(
                                      '/library/album/${Uri.encodeComponent(album.name)}/${Uri.encodeComponent(album.artist)}',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 16)),
                      ],

                      // ── All songs ────────────────────────────────────
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(sizes.screenEdgePadding,
                              0, sizes.screenEdgePadding, 8),
                          child: Text(
                            'All Songs',
                            style: tt.titleMedium?.copyWith(
                                color: ext.textPrimary,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),

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
                            onTap: () => ref
                                .read(playbackProvider.notifier)
                                .playSong(song,
                                    queue: songs,
                                    index: i,
                                    sourceType: QueueSourceType.artist),
                            onContextMenu: () => _showContextMenu(ctx, song,
                                songs, i, favoriteIds.contains(song.id)),
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
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const EmptyState(
                  icon: LucideIcons.circleAlert,
                  title: 'Failed to load artist',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showContextMenu(
    BuildContext ctx,
    Song song,
    List<Song> songs,
    int index,
    bool isFavorite,
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
          onTap: () => ref.read(playbackProvider.notifier).playSong(song,
              queue: songs, index: index, sourceType: QueueSourceType.artist),
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
          label:
              isFavorite ? l10n.ctxRemoveFromFavorites : l10n.ctxAddToFavorites,
          icon: isFavorite ? LucideIcons.heartOff : LucideIcons.heart,
          onTap: () => ref
              .read(favoritesProvider().notifier)
              .toggleFavorite(song.id, isFavorite: isFavorite),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable action button (same pattern as album detail, kept local)
// ---------------------------------------------------------------------------

class _ArtistActionBtn extends StatefulWidget {
  const _ArtistActionBtn({
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
  State<_ArtistActionBtn> createState() => _ArtistActionBtnState();
}

class _ArtistActionBtnState extends State<_ArtistActionBtn> {
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

    return FocusHighlight(
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
            border:
                widget.isPrimary ? null : Border.all(color: ext.borderSubtle),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon,
                  size: 16,
                  color: widget.isPrimary ? Colors.white : ext.textSecondary),
              const SizedBox(width: 8),
              Text(widget.label,
                  style: tt.labelLarge?.copyWith(
                    color: widget.isPrimary ? Colors.white : ext.textPrimary,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
