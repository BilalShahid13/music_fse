import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/playback_provider.dart';
import '../../providers/toast_provider.dart';
import '../../helpers/add_to_playlist_helper.dart';
import '../../../domain/entities/playback_state.dart';
import '../../../domain/entities/song.dart';
import '../../widgets/context_menu.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/focus_highlight.dart';
import '../../widgets/selectable_song_tile.dart';

/// Favorites page — all favorited songs.
///
/// Route: `/favorites`
class FavoritesPage extends ConsumerStatefulWidget {
  const FavoritesPage({super.key});

  @override
  ConsumerState<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends ConsumerState<FavoritesPage> {
  String _sortBy = 'title';
  bool _ascending = true;
  late final FocusNode _defaultFocus;
  late final FocusNode _keyListenerFocusNode;

  @override
  void initState() {
    super.initState();
    _defaultFocus = FocusNode(debugLabel: 'Favorites-default');
    _keyListenerFocusNode = FocusNode(debugLabel: 'FavoritesPage-keyListener')..skipTraversal = true;
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
    // Y = toggle favorite from anywhere (handled per-tile via SongListTile)
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final sizes = AppSizes.of(context);
    final favoritesAsync = ref.watch(
      favoritesProvider(sortBy: _sortBy, ascending: _ascending),
    );
    final currentSongId = ref.watch(
      playbackProvider.select((s) => s.currentSong?.id),
    );

    return KeyboardListener(
      focusNode: _keyListenerFocusNode,
      onKeyEvent: _handleKey,
      child: Scaffold(
        backgroundColor: ext.bgDeep,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                sizes.screenEdgePadding,
                sizes.screenEdgePadding,
                sizes.screenEdgePadding,
                0,
              ),
              child: Row(
                children: [
                  Text(
                    l10n.favorites,
                    style: tt.headlineLarge?.copyWith(
                      color: ext.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  // Sort dropdown
                  _SortDropdown(
                    sortBy: _sortBy,
                    ascending: _ascending,
                    onChange: (sortBy, ascending) => setState(() {
                      _sortBy = sortBy;
                      _ascending = ascending;
                    }),
                  ),
                ],
              ),
            ),

            // ── Action row ────────────────────────────────────────────────
            favoritesAsync.when(
              data: (songs) => songs.isNotEmpty
                  ? Padding(
                      padding: EdgeInsets.fromLTRB(
                        sizes.screenEdgePadding,
                        16,
                        sizes.screenEdgePadding,
                        8,
                      ),
                      child: Row(
                        children: [
                          _ActionChip(
                            icon: LucideIcons.play,
                            label: 'Play All',
                            onTap: () => ref.read(playbackProvider.notifier).playQueue(songs),
                          ),
                          const SizedBox(width: 10),
                          _ActionChip(
                            icon: LucideIcons.shuffle,
                            label: 'Shuffle',
                            onTap: () {
                              final shuffled = List.of(songs)..shuffle();
                              ref.read(playbackProvider.notifier).playQueue(shuffled);
                            },
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${songs.length} song${songs.length == 1 ? '' : 's'}',
                            style: tt.bodySmall?.copyWith(color: ext.textTertiary),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // ── List ──────────────────────────────────────────────────────
            Expanded(
              child: favoritesAsync.when(
                data: (songs) {
                  if (songs.isEmpty) {
                    return EmptyState(
                      icon: LucideIcons.heart,
                      title: l10n.noFavoritesYet,
                      subtitle: l10n.noFavoritesMessage,
                      actionLabel: l10n.browseLibrary,
                      onAction: () => context.go('/library'),
                    );
                  }
                  return ListView.builder(
                    itemCount: songs.length,
                    itemBuilder: (ctx, i) {
                      final song = songs[i];
                      return SelectableSongTile(
                        key: ValueKey(song.id),
                        song: song,
                        index: i,
                        isCurrentlyPlaying: song.id == currentSongId,
                        isFavorite: true,
                        onTap: () => ref.read(playbackProvider.notifier).playSong(song, queue: songs, index: i),
                        onContextMenu: () => _showContextMenu(ctx, song, songs, i),
                        onToggleFavorite: () =>
                            ref.read(favoritesProvider(sortBy: _sortBy, ascending: _ascending).notifier).toggleFavorite(song.id, isFavorite: true),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => EmptyState(
                  icon: LucideIcons.circleAlert,
                  title: l10n.failedToLoadFavorites,
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
          onTap: () => ref.read(playbackProvider.notifier).playSong(song, queue: songs, index: index, sourceType: QueueSourceType.favorites),
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
          label: l10n.ctxRemoveFromFavorites,
          icon: LucideIcons.heartOff,
          onTap: () => ref.read(favoritesProvider(sortBy: _sortBy, ascending: _ascending).notifier).toggleFavorite(song.id, isFavorite: true),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Sort dropdown
// ---------------------------------------------------------------------------

class _SortDropdown extends StatelessWidget {
  const _SortDropdown({
    required this.sortBy,
    required this.ascending,
    required this.onChange,
  });
  final String sortBy;
  final bool ascending;
  final void Function(String sortBy, bool ascending) onChange;

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;

    return PopupMenuButton<(String, bool)>(
      onSelected: (v) => onChange(v.$1, v.$2),
      color: ext.bgSurface,
      child: Row(
        children: [
          Text('Sort', style: tt.labelMedium?.copyWith(color: ext.textSecondary)),
          const SizedBox(width: 4),
          Icon(LucideIcons.chevronsUpDown, size: 14, color: ext.textTertiary),
        ],
      ),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: ('title', true),
          child: Text('Title A–Z', style: tt.bodySmall?.copyWith(color: ext.textPrimary)),
        ),
        PopupMenuItem(
          value: ('title', false),
          child: Text('Title Z–A', style: tt.bodySmall?.copyWith(color: ext.textPrimary)),
        ),
        PopupMenuItem(
          value: ('artist', true),
          child: Text('Artist A–Z', style: tt.bodySmall?.copyWith(color: ext.textPrimary)),
        ),
        PopupMenuItem(
          value: ('dateAdded', false),
          child: Text('Date Added', style: tt.bodySmall?.copyWith(color: ext.textPrimary)),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Action chip
// ---------------------------------------------------------------------------

class _ActionChip extends StatefulWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  State<_ActionChip> createState() => _ActionChipState();
}

class _ActionChipState extends State<_ActionChip> {
  final _focus = FocusNode();

  @override
  void dispose() {
    _focus.dispose();
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: ext.bgSurface,
            borderRadius: BorderRadius.circular(AppConstants.btnRadius),
            border: Border.all(color: ext.borderSubtle),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 14, color: ext.textSecondary),
              const SizedBox(width: 6),
              Text(widget.label, style: tt.labelSmall?.copyWith(color: ext.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }
}
