import 'dart:async';

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
import '../../../platform/keyboard/on_screen_keyboard.dart';
import '../../../platform/xinput/gamepad_scroll_target_mixin.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/playback_provider.dart';
import '../../providers/toast_provider.dart';
import '../../providers/search_provider.dart';
import '../../helpers/active_focus_request.dart';
import '../../helpers/add_to_playlist_helper.dart';
import '../../widgets/album_card.dart';
import '../../widgets/artist_card.dart';
import '../../widgets/context_menu.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/focus_highlight.dart';
import '../../widgets/song_list_tile.dart';

/// Search page — debounced live results in 4 categories.
///
/// Route: `/search`
///
/// Default focus: search input.
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage>
    with GamepadScrollTargetMixin {
  late final FocusNode _inputFocus;
  late final TextEditingController _controller;
  late final FocusNode _keyListenerFocusNode;
  Timer? _keyboardDismissDebounce;

  @override
  void initState() {
    super.initState();
    _inputFocus = FocusNode(debugLabel: 'Search-input');
    _inputFocus.addListener(_handleInputFocusChanged);
    _controller = TextEditingController();
    _keyListenerFocusNode = FocusNode(debugLabel: 'SearchPage-keyListener')
      ..skipTraversal = true;
    scheduleActiveFocusRequest(state: this, focusNode: _inputFocus);
  }

  @override
  void dispose() {
    _keyboardDismissDebounce?.cancel();
    _inputFocus.removeListener(_handleInputFocusChanged);
    unawaited(OnScreenKeyboard.hide());
    _inputFocus.dispose();
    _controller.dispose();
    _keyListenerFocusNode.dispose();
    super.dispose();
  }

  void _handleInputFocusChanged() {
    if (!OnScreenKeyboard.isSupported) {
      return;
    }

    _keyboardDismissDebounce?.cancel();
    if (_inputFocus.hasFocus) {
      unawaited(OnScreenKeyboard.show());
      return;
    }

    _keyboardDismissDebounce = Timer(
      const Duration(milliseconds: 150),
      () => unawaited(OnScreenKeyboard.hide()),
    );
  }

  KeyEventResult _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.escape ||
        event.logicalKey == LogicalKeyboardKey.gameButtonB) {
      if (_controller.text.isNotEmpty) {
        _controller.clear();
        ref.read(searchProvider.notifier).clearSearch();
        _inputFocus.requestFocus();
        return KeyEventResult.handled;
      }
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
    final l10n = AppLocalizations.of(context)!;
    final search = ref.watch(searchProvider);
    final currentSongId = ref.watch(
      playbackProvider.select((s) => s.currentSong?.id),
    );
    final currentRoute = ref.watch(navigationProvider);

    syncGamepadScrollTarget(currentRoute == '/search');

    return KeyboardListener(
      focusNode: _keyListenerFocusNode,
      onKeyEvent: _handleKey,
      child: Scaffold(
        backgroundColor: ext.bgDeep,
        body: Column(
          children: [
            // ── Header + search input ────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                sizes.screenEdgePadding,
                sizes.screenEdgePadding,
                sizes.screenEdgePadding,
                16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.navSearch,
                    style: tt.headlineLarge?.copyWith(
                      color: ext.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Search field
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: ext.bgInput,
                      borderRadius:
                          BorderRadius.circular(AppConstants.btnRadius),
                      border: Border.all(color: ext.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 14),
                        Icon(LucideIcons.search,
                            size: 18, color: ext.textTertiary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            focusNode: _inputFocus,
                            controller: _controller,
                            onChanged: (v) => ref
                                .read(searchProvider.notifier)
                                .onQueryChanged(v),
                            onSubmitted: (v) {
                              if (v.trim().isNotEmpty) {
                                ref
                                    .read(searchProvider.notifier)
                                    .addToHistory(v);
                              }
                            },
                            style:
                                tt.bodyMedium?.copyWith(color: ext.textPrimary),
                            decoration: InputDecoration(
                              hintText: l10n.searchPlaceholder,
                              hintStyle: tt.bodyMedium
                                  ?.copyWith(color: ext.textTertiary),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                        if (_controller.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _controller.clear();
                              ref.read(searchProvider.notifier).clearSearch();
                              _inputFocus.requestFocus();
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Icon(LucideIcons.x,
                                  size: 16, color: ext.textTertiary),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Results / history ────────────────────────────────────────
            Expanded(
              child: search.hasQuery
                  ? _SearchResults(
                      search: search,
                      currentSongId: currentSongId,
                      scrollController: gamepadScrollController,
                    )
                  : _SearchHistory(
                      history: search.history,
                      scrollController: gamepadScrollController,
                      onSelect: (q) {
                        _controller.text = q;
                        ref.read(searchProvider.notifier).onQueryChanged(q);
                        _inputFocus.requestFocus();
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Search results view
// ---------------------------------------------------------------------------

class _SearchResults extends ConsumerWidget {
  const _SearchResults({
    required this.search,
    required this.currentSongId,
    required this.scrollController,
  });
  final SearchState search;
  final int? currentSongId;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = search.results;
    final sizes = AppSizes.of(context);

    if (search.isSearching &&
        results.songs.isEmpty &&
        results.albums.isEmpty &&
        results.artists.isEmpty &&
        results.playlists.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!search.isSearching &&
        results.songs.isEmpty &&
        results.albums.isEmpty &&
        results.artists.isEmpty &&
        results.playlists.isEmpty) {
      return const EmptyState(
        icon: LucideIcons.searchX,
        title: 'No Results',
        subtitle: 'Try a different keyword or check spelling.',
      );
    }

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        // Songs
        if (results.songs.isNotEmpty) ...[
          const _SectionHeader(title: 'Songs'),
          ...results.songs
              .take(AppConstants.searchResultsPerCategory)
              .toList()
              .asMap()
              .entries
              .map((entry) {
            final i = entry.key;
            final song = entry.value;
            final songs = results.songs
                .take(AppConstants.searchResultsPerCategory)
                .toList();
            return SongListTile(
              key: ValueKey(song.id),
              song: song,
              isCurrentlyPlaying: song.id == currentSongId,
              isFavorite: song.isFavorite,
              onTap: () => ref.read(playbackProvider.notifier).playSong(song,
                  queue: songs, index: i, sourceType: QueueSourceType.search),
              onContextMenu: () =>
                  _showSongContextMenu(context, ref, song, songs, i),
              onToggleFavorite: () => ref
                  .read(favoritesProvider().notifier)
                  .toggleFavorite(song.id, isFavorite: song.isFavorite),
            );
          }),
        ],

        // Albums
        if (results.albums.isNotEmpty) ...[
          const _SectionHeader(title: 'Albums'),
          SizedBox(
            height: sizes.gridCardHeight + 16,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding:
                  EdgeInsets.symmetric(horizontal: sizes.screenEdgePadding),
              itemCount: results.albums
                  .take(AppConstants.searchResultsPerCategory)
                  .length,
              itemBuilder: (ctx, i) {
                final album = results.albums[i];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: AlbumCard(
                    albumName: album.name,
                    artistName: album.artist,
                    artCachePath: album.artCachePath,
                    onTap: () => ctx.go(
                      '/library/album/${Uri.encodeComponent(album.name)}/${Uri.encodeComponent(album.artist)}',
                    ),
                  ),
                );
              },
            ),
          ),
        ],

        // Artists
        if (results.artists.isNotEmpty) ...[
          const _SectionHeader(title: 'Artists'),
          SizedBox(
            height: sizes.gridCardHeight + 16,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding:
                  EdgeInsets.symmetric(horizontal: sizes.screenEdgePadding),
              itemCount: results.artists
                  .take(AppConstants.searchResultsPerCategory)
                  .length,
              itemBuilder: (ctx, i) {
                final artist = results.artists[i];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ArtistCard(
                    artistName: artist.name,
                    songCount: artist.songCount,
                    artCachePath: artist.artCachePath,
                    onTap: () => ctx.go(
                      '/library/artist/${Uri.encodeComponent(artist.name)}',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _showSongContextMenu(
    BuildContext ctx,
    WidgetRef ref,
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
          onTap: () => ref.read(playbackProvider.notifier).playSong(song,
              queue: songs, index: index, sourceType: QueueSourceType.search),
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
}

// ---------------------------------------------------------------------------
// Search history view
// ---------------------------------------------------------------------------

class _SearchHistory extends StatelessWidget {
  const _SearchHistory({
    required this.history,
    required this.onSelect,
    required this.scrollController,
  });
  final List<String> history;
  final void Function(String) onSelect;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const EmptyState(
        icon: LucideIcons.clock,
        title: 'No Search History',
        subtitle: 'Your recent searches will appear here.',
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.zero,
      itemCount: history.length,
      itemBuilder: (ctx, i) {
        return _HistoryItem(
          query: history[i],
          onTap: () => onSelect(history[i]),
        );
      },
    );
  }
}

class _HistoryItem extends StatefulWidget {
  const _HistoryItem({required this.query, required this.onTap});
  final String query;
  final VoidCallback onTap;

  @override
  State<_HistoryItem> createState() => _HistoryItemState();
}

class _HistoryItemState extends State<_HistoryItem> {
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
    final sizes = AppSizes.of(context);

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
                Icon(LucideIcons.clock, size: 16, color: ext.textTertiary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.query,
                    style: tt.bodyMedium?.copyWith(color: ext.textSecondary),
                  ),
                ),
                Icon(LucideIcons.arrowUpLeft,
                    size: 14, color: ext.textTertiary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;
    final sizes = AppSizes.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        sizes.screenEdgePadding,
        16,
        sizes.screenEdgePadding,
        8,
      ),
      child: Text(
        title,
        style: tt.titleMedium?.copyWith(
          color: ext.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
