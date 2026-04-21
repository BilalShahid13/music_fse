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
import '../../providers/library_provider.dart';
import '../../providers/playback_provider.dart';
import '../../providers/toast_provider.dart';
import '../../helpers/add_to_playlist_helper.dart';
import '../../widgets/context_menu.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/focus_highlight.dart';
import '../../widgets/song_list_tile.dart';

/// Genre detail screen.
///
/// Route: `/library/genre/:genreName`
class GenreDetailPage extends ConsumerStatefulWidget {
  const GenreDetailPage({super.key, required this.genreName});
  final String genreName;

  @override
  ConsumerState<GenreDetailPage> createState() => _GenreDetailPageState();
}

class _GenreDetailPageState extends ConsumerState<GenreDetailPage> {
  late final FocusNode _playAllFocus;
  late final FocusNode _keyListenerFocusNode;

  @override
  void initState() {
    super.initState();
    _playAllFocus = FocusNode(debugLabel: 'GenreDetail-playAll');
    _keyListenerFocusNode = FocusNode(debugLabel: 'GenreDetailPage-keyListener')..skipTraversal = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playAllFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _playAllFocus.dispose();
    _keyListenerFocusNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.escape || event.logicalKey == LogicalKeyboardKey.gameButtonB) {
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
      songsByGenreProvider(widget.genreName),
    );
    final currentSongId = ref.watch(
      playbackProvider.select((s) => s.currentSong?.id),
    );
    final favorites = ref.watch(favoritesProvider());

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
                  final favoriteIds = favorites.value?.map((s) => s.id).toSet() ?? {};

                  return CustomScrollView(
                    slivers: [
                      // ── Header ────────────────────────────────────────
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
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(LucideIcons.tag, size: 28, color: Theme.of(context).colorScheme.primary),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.genreName,
                                      style: tt.headlineMedium?.copyWith(
                                        color: ext.textPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${songs.length} song${songs.length == 1 ? '' : 's'}',
                                      style: tt.bodySmall?.copyWith(color: ext.textTertiary),
                                    ),
                                  ],
                                ),
                              ),
                              // Play All button
                              _PlayButton(
                                focusNode: _playAllFocus,
                                label: 'Play All',
                                onTap: songs.isEmpty
                                    ? null
                                    : () => ref
                                        .read(playbackProvider.notifier)
                                        .playSong(songs.first, queue: songs, index: 0, sourceType: QueueSourceType.genre),
                              ),
                              const SizedBox(width: 10),
                              _PlayButton(
                                label: 'Shuffle',
                                icon: LucideIcons.shuffle,
                                onTap: songs.isEmpty
                                    ? null
                                    : () {
                                        final s = List.of(songs)..shuffle();
                                        ref.read(playbackProvider.notifier).playSong(s.first, queue: s, index: 0, sourceType: QueueSourceType.genre);
                                      },
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ── Song list ─────────────────────────────────────
                      if (songs.isEmpty)
                        const SliverToBoxAdapter(
                          child: EmptyState(
                            icon: LucideIcons.tag,
                            title: 'No Songs',
                            subtitle: 'No songs tagged with this genre.',
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
                              isFavorite: favoriteIds.contains(song.id),
                              onTap: () =>
                                  ref.read(playbackProvider.notifier).playSong(song, queue: songs, index: i, sourceType: QueueSourceType.genre),
                              onContextMenu: () => _showContextMenu(ctx, song, songs, i, favoriteIds.contains(song.id)),
                              onToggleFavorite: () =>
                                  ref.read(favoritesProvider().notifier).toggleFavorite(song.id, isFavorite: favoriteIds.contains(song.id)),
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
                  title: 'Failed to load genre',
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
          onTap: () => ref.read(playbackProvider.notifier).playSong(song, queue: songs, index: index, sourceType: QueueSourceType.genre),
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
          label: isFavorite ? l10n.ctxRemoveFromFavorites : l10n.ctxAddToFavorites,
          icon: isFavorite ? LucideIcons.heartOff : LucideIcons.heart,
          onTap: () => ref.read(favoritesProvider().notifier).toggleFavorite(song.id, isFavorite: isFavorite),
        ),
      ],
    );
  }
}

class _PlayButton extends StatefulWidget {
  const _PlayButton({
    required this.label,
    required this.onTap,
    this.icon = LucideIcons.play,
    this.focusNode,
  });
  final String label;
  final VoidCallback? onTap;
  final IconData icon;
  final FocusNode? focusNode;

  @override
  State<_PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<_PlayButton> {
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
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: ext.bgSurface,
            borderRadius: BorderRadius.circular(AppConstants.btnRadius),
            border: Border.all(color: ext.borderSubtle),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 15, color: ext.textSecondary),
              const SizedBox(width: 7),
              Text(widget.label, style: tt.labelMedium?.copyWith(color: ext.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }
}
