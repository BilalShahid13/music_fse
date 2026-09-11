import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/playback_state.dart';
import '../../../domain/entities/song.dart';
import '../../../platform/xinput/gamepad_scroll_target_mixin.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/home_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/playback_provider.dart';
import '../../providers/toast_provider.dart';
import '../../helpers/active_focus_request.dart';
import '../../helpers/add_to_playlist_helper.dart';
import '../../widgets/context_menu.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/focus_highlight.dart';
import '../../widgets/song_list_tile.dart';

/// Recently Played page — full list ordered by last played descending.
///
/// Route: `/home/recently-played`
class RecentlyPlayedPage extends ConsumerStatefulWidget {
  const RecentlyPlayedPage({super.key});

  @override
  ConsumerState<RecentlyPlayedPage> createState() => _RecentlyPlayedPageState();
}

class _RecentlyPlayedPageState extends ConsumerState<RecentlyPlayedPage>
    with GamepadScrollTargetMixin {
  late final FocusNode _defaultFocus;
  late final FocusNode _keyListenerFocusNode;

  @override
  void initState() {
    super.initState();
    _defaultFocus = FocusNode(debugLabel: 'RecentlyPlayed-default');
    _keyListenerFocusNode =
        FocusNode(debugLabel: 'RecentlyPlayedPage-keyListener')
          ..skipTraversal = true;
    scheduleActiveFocusRequest(state: this, focusNode: _defaultFocus);
  }

  @override
  void dispose() {
    _defaultFocus.dispose();
    _keyListenerFocusNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.escape ||
        event.logicalKey == LogicalKeyboardKey.gameButtonB ||
        event.logicalKey == LogicalKeyboardKey.keyB) {
      Navigator.of(context).maybePop();
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
    final songsAsync = ref.watch(recentlyPlayedProvider);
    final currentSongId = ref.watch(
      playbackProvider.select((s) => s.currentSong?.id),
    );
    final currentRoute = ref.watch(navigationProvider);

    syncGamepadScrollTarget(currentRoute == '/home/recently-played');

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
                    l10n.recentlyPlayed,
                    style: tt.headlineLarge?.copyWith(
                      color: ext.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  // Play all
                  songsAsync.when(
                    data: (songs) => songs.isNotEmpty
                        ? _PlayAllBtn(
                            focusNode: _defaultFocus,
                            label: l10n.playAll,
                            onTap: () => ref
                                .read(playbackProvider.notifier)
                                .playQueue(songs),
                          )
                        : const SizedBox.shrink(),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),

            // ── List ──────────────────────────────────────────────────────
            Expanded(
              child: songsAsync.when(
                data: (songs) {
                  if (songs.isEmpty) {
                    return const EmptyState(
                      icon: LucideIcons.clock,
                      title: 'Nothing Played Yet',
                      subtitle: 'Songs you play will appear here.',
                    );
                  }
                  return ListView.builder(
                    controller: gamepadScrollController,
                    itemCount: songs.length,
                    itemBuilder: (ctx, i) {
                      final song = songs[i];
                      return SongListTile(
                        key: ValueKey(song.id),
                        song: song,
                        index: i,
                        isCurrentlyPlaying: song.id == currentSongId,
                        isFavorite: song.isFavorite,
                        onTap: () => ref
                            .read(playbackProvider.notifier)
                            .playSong(song,
                                queue: songs,
                                index: i,
                                sourceType: QueueSourceType.recentlyPlayed),
                        onContextMenu: () =>
                            _showContextMenu(ctx, song, songs, i),
                        onToggleFavorite: () => ref
                            .read(favoritesProvider().notifier)
                            .toggleFavorite(song.id,
                                isFavorite: song.isFavorite),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const EmptyState(
                  icon: LucideIcons.circleAlert,
                  title: 'Failed to load history',
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
          onTap: () => ref.read(playbackProvider.notifier).playSong(song,
              queue: songs,
              index: index,
              sourceType: QueueSourceType.recentlyPlayed),
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
// Play all button
// ---------------------------------------------------------------------------

class _PlayAllBtn extends StatelessWidget {
  const _PlayAllBtn({
    required this.focusNode,
    required this.label,
    required this.onTap,
  });

  final FocusNode focusNode;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return FocusHighlight(
      focusNode: focusNode,
      borderRadius: AppConstants.btnRadius,
      onPressed: onTap,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: AppConstants.minFocusableSize,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: cs.primary,
            borderRadius: BorderRadius.circular(AppConstants.btnRadius),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.play, size: 14, color: cs.onPrimary),
              const SizedBox(width: 6),
              Text(label, style: tt.labelSmall?.copyWith(color: cs.onPrimary)),
            ],
          ),
        ),
      ),
    );
  }
}
