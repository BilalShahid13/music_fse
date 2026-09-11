import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/playback_state.dart';
import '../../../domain/entities/song.dart';
import '../../../platform/xinput/gamepad_scroll_target.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/home_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/playback_provider.dart';
import '../../providers/toast_provider.dart';
import '../../providers/scan_provider.dart';
import '../../helpers/add_to_playlist_helper.dart';
import '../../widgets/album_card.dart';
import '../../widgets/context_menu.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/focus_highlight.dart';
import '../../widgets/marquee_text.dart';

/// Home screen — the first page users see after onboarding.
///
/// Sections (REQUIREMENTS §7.5):
/// 1. Quick Resume hero card (if saved state exists)
/// 2. Recently Played horizontal scroll row
/// 3. Most Played horizontal scroll row
/// 4. Recently Added horizontal scroll row
/// 5. Library stats footer
///
/// Default focus: the Resume button (if present) or the first song in
/// "Recently Played".
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late final FocusNode _resumeFocus;
  late final FocusNode _firstSectionFocus;
  late final FocusNode _keyListenerFocusNode;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _resumeFocus = FocusNode(debugLabel: 'Home-resume');
    _firstSectionFocus = FocusNode(debugLabel: 'Home-firstSection');
    _keyListenerFocusNode = FocusNode(debugLabel: 'HomePage-keyListener')..skipTraversal = true;
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    GamepadScrollTarget.clear(_scrollController);
    _scrollController.dispose();
    _resumeFocus.dispose();
    _firstSectionFocus.dispose();
    _keyListenerFocusNode.dispose();
    super.dispose();
  }

  void _syncGamepadScrollTarget(bool isHomeRouteActive) {
    if (isHomeRouteActive) {
      GamepadScrollTarget.set(_scrollController);
    } else {
      GamepadScrollTarget.clear(_scrollController);
    }
  }

  KeyEventResult _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.escape || event.logicalKey == LogicalKeyboardKey.gameButtonB) {
      // Home is root — B does nothing (no back navigation).
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.gameButtonStart) {
      ref.read(playbackProvider.notifier).togglePlayPause();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  String _recommendationTitle(AppLocalizations l10n, String key) {
    return switch (key) {
      'recently_liked' => 'Recently Liked',
      'hidden_gems' => 'Hidden Gems',
      'top_played' => 'Your Top Tracks',
      _ => key.replaceAll('_', ' '),
    };
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final l10n = AppLocalizations.of(context)!;
    final tt = Theme.of(context).textTheme;
    final sizes = AppSizes.of(context);

    final resumeAsync = ref.watch(resumeContextProvider);
    final recentlyPlayedAsync = ref.watch(recentlyPlayedProvider);
    final mostPlayedAsync = ref.watch(mostPlayedProvider);
    final recentlyAddedAsync = ref.watch(recentlyAddedProvider);
    final recommendationsAsync = ref.watch(recommendationsProvider);
    final statsAsync = ref.watch(libraryStatsProvider);
    final scanState = ref.watch(scanProvider);
    final currentRoute = ref.watch(navigationProvider);

    _syncGamepadScrollTarget(currentRoute == '/home');

    return KeyboardListener(
      focusNode: _keyListenerFocusNode,
      onKeyEvent: _handleKey,
      child: Scaffold(
        backgroundColor: ext.bgDeep,
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // ── Padding top ────────────────────────────────────────────────
            SliverPadding(padding: EdgeInsets.only(top: sizes.screenEdgePadding)),

            // ── Scan progress banner ───────────────────────────────────────
            if (scanState.isScanning)
              SliverToBoxAdapter(
                child: _ScanBanner(state: scanState),
              ),

            // ── Page title ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: sizes.screenEdgePadding,
                ),
                child: Text(
                  l10n.navHome,
                  style: tt.headlineLarge?.copyWith(
                    color: ext.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SliverPadding(padding: EdgeInsets.only(top: 16)),

            // ── Empty library state ────────────────────────────────────────
            if (!scanState.isScanning)
              ...statsAsync.when(
                data: (s) => s.totalSongs == 0
                    ? [
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: EmptyState(
                            icon: LucideIcons.music,
                            title: 'Your library is empty',
                            subtitle: 'Add folders to scan for music files',
                            actionLabel: 'Scan Library',
                            onAction: () => context.go('/settings'),
                          ),
                        ),
                      ]
                    : const <Widget>[],
                loading: () => const <Widget>[],
                error: (_, __) => const <Widget>[],
              ),

            // ── Quick Resume ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: resumeAsync.when(
                data: (ctx) {
                  if (ctx.lastSong == null) return const SizedBox.shrink();
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: sizes.screenEdgePadding,
                    ),
                    child: _ResumeCard(
                      song: ctx.lastSong!,
                      position: ctx.lastPosition ?? Duration.zero,
                      focusNode: _resumeFocus,
                      onResume: () {
                        ref.read(playbackProvider.notifier).resumeFromSaved();
                        context.push('/now-playing');
                      },
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

            // ── Recently Played ────────────────────────────────────────────
            _SongRowSection(
              title: l10n.homeRecentlyPlayed,
              songsAsync: recentlyPlayedAsync,
              firstItemFocusNode: _firstSectionFocus,
              onSeeAll: () => context.go('/home/recently-played'),
            ),

            // ── Most Played ────────────────────────────────────────────────
            _SongRowSection(
              title: l10n.homeMostPlayed,
              songsAsync: mostPlayedAsync,
            ),

            // ── Recently Added ─────────────────────────────────────────────
            _SongRowSection(
              title: l10n.homeRecentlyAdded,
              songsAsync: recentlyAddedAsync,
            ),
            // ── Recommendations ────────────────────────────────────────────
            ...recommendationsAsync.when(
              data: (categories) => categories.entries.where((e) => e.value.isNotEmpty).map((e) => _SongRowSection(
                    title: _recommendationTitle(l10n, e.key),
                    songsAsync: AsyncValue.data(e.value),
                  )),
              loading: () => const [SliverPadding(padding: EdgeInsets.zero)],
              error: (_, __) => const [SliverPadding(padding: EdgeInsets.zero)],
            ),
            // ── Library Stats ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: statsAsync.when(
                data: (s) => _StatsFooter(
                  totalSongs: s.totalSongs,
                  totalAlbums: s.totalAlbums,
                  totalArtists: s.totalArtists,
                  totalDuration: s.totalDuration,
                ),
                loading: () => const SizedBox(height: 80),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

            SliverPadding(
              padding: EdgeInsets.only(bottom: sizes.screenEdgePadding),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Resume card
// ---------------------------------------------------------------------------

class _ResumeCard extends StatelessWidget {
  const _ResumeCard({
    required this.song,
    required this.position,
    required this.focusNode,
    required this.onResume,
  });

  final Song song;
  final Duration position;
  final FocusNode focusNode;
  final VoidCallback onResume;

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${d.inHours > 0 ? '${d.inHours}:' : ''}$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final accent = Theme.of(context).colorScheme.primary;
    final sizes = AppSizes.of(context);
    final compact = sizes.isCompact;
    final titleStyle = tt.titleMedium?.copyWith(color: ext.textPrimary) ?? DefaultTextStyle.of(context).style;

    return FocusHighlight(
      focusNode: focusNode,
      isCard: true,
      borderRadius: sizes.cardRadius,
      onPressed: onResume,
      child: GestureDetector(
        onTap: onResume,
        child: Container(
          height: compact ? 80.0 : 100.0,
          decoration: BoxDecoration(
            color: ext.bgCard,
            borderRadius: BorderRadius.circular(sizes.cardRadius),
            border: Border.all(color: ext.borderCard),
          ),
          padding: EdgeInsets.all(compact ? 12.0 : 16.0),
          child: Row(
            children: [
              // Album art
              ClipRRect(
                borderRadius: BorderRadius.circular(sizes.cardRadiusSm),
                child: song.artCachePath != null
                    ? Image.asset(
                        song.artCachePath!,
                        width: compact ? 56.0 : 68.0,
                        height: compact ? 56.0 : 68.0,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: compact ? 56.0 : 68.0,
                        height: compact ? 56.0 : 68.0,
                        color: ext.bgInput,
                        child: Icon(LucideIcons.music, color: ext.textTertiary, size: 28),
                      ),
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.homeQuickResume,
                      style: tt.labelSmall?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FocusedMarqueeText(
                      focusNode: focusNode,
                      text: song.title,
                      style: titleStyle,
                    ),
                    Text(
                      song.artist,
                      style: tt.bodySmall?.copyWith(color: ext.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _fmt(position),
                      style: tt.bodySmall?.copyWith(color: ext.textTertiary),
                    ),
                  ],
                ),
              ),
              // Play icon
              Icon(LucideIcons.circlePlay, size: 36, color: accent),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Horizontal song row section
// ---------------------------------------------------------------------------

class _SongRowSection extends ConsumerWidget {
  const _SongRowSection({
    required this.title,
    required this.songsAsync,
    this.firstItemFocusNode,
    this.onSeeAll,
  });

  final String title;
  final AsyncValue<List<Song>> songsAsync;
  final FocusNode? firstItemFocusNode;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final sizes = AppSizes.of(context);
    final currentSongId = ref.watch(playbackProvider.select((s) => s.currentSong?.id));
    final homePlaceholderIconOffset = Offset(
      sizes.gridCardScrollRowWidth * 0.015,
      sizes.gridCardScrollRowWidth * 0.012,
    );

    // Don't render the section at all when there's no data
    final songs = songsAsync.asData?.value;
    if (songs != null && songs.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(top: sizes.sectionGap),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: sizes.screenEdgePadding,
              ),
              child: Row(
                children: [
                  Text(
                    title,
                    style: tt.titleLarge?.copyWith(
                      color: ext.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (onSeeAll != null)
                    TextButton(
                      onPressed: onSeeAll,
                      child: Text(l10n.homeSeeAll),
                    ),
                ],
              ),
            ),
            SizedBox(height: sizes.headerContentGap),
            // Horizontal scroll list
            songsAsync.when(
              data: (songs) {
                if (songs.isEmpty) return const SizedBox.shrink();
                return SizedBox(
                  height: sizes.gridCardHeight + 24,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(
                      horizontal: sizes.screenEdgePadding,
                      vertical: 12,
                    ),
                    itemCount: songs.length,
                    itemBuilder: (ctx, index) {
                      final song = songs[index];
                      final isCurrent = currentSongId == song.id;
                      return Padding(
                        padding: EdgeInsets.only(right: sizes.isCompact ? 10.0 : 12.0),
                        child: AlbumCard(
                          key: ValueKey('home-row-${song.id}'),
                          albumName: song.title,
                          artistName: song.artist,
                          artCachePath: song.artCachePath,
                          width: sizes.gridCardScrollRowWidth,
                          artPlaceholderIconOffset: homePlaceholderIconOffset,
                          showFocusedPlayCue: false,
                          isCurrentlyPlaying: isCurrent,
                          focusNode: index == 0 ? firstItemFocusNode : null,
                          onTap: () =>
                              ref.read(playbackProvider.notifier).playSong(song, queue: songs, index: index, sourceType: QueueSourceType.allSongs),
                          onContextMenu: () => _showSongContextMenu(ctx, ref, song, songs, index),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const SizedBox(
                height: 40,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSongContextMenu(
    BuildContext ctx,
    WidgetRef ref,
    Song song,
    List<Song> songs,
    int index,
  ) async {
    Offset resolveMenuPosition() {
      // Prefer the currently focused widget (X is usually triggered on focus).
      final focusedContext = FocusManager.instance.primaryFocus?.context;
      final focusedRender = focusedContext?.findRenderObject();
      if (focusedRender is RenderBox) {
        return focusedRender.localToGlobal(Offset.zero);
      }

      final localRender = ctx.findRenderObject();
      if (localRender is RenderBox) {
        return localRender.localToGlobal(Offset.zero);
      }

      final overlayRender = Overlay.maybeOf(ctx)?.context.findRenderObject();
      if (overlayRender is RenderBox) {
        final overlayCenter = overlayRender.size.center(Offset.zero);
        return overlayRender.localToGlobal(overlayCenter);
      }

      return Offset.zero;
    }

    final pos = resolveMenuPosition();
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
}

// ---------------------------------------------------------------------------
// Library stats footer
// ---------------------------------------------------------------------------

class _StatsFooter extends StatelessWidget {
  const _StatsFooter({
    required this.totalSongs,
    required this.totalAlbums,
    required this.totalArtists,
    required this.totalDuration,
  });

  final int totalSongs;
  final int totalAlbums;
  final int totalArtists;
  final Duration totalDuration;

  String _fmtDuration(Duration d) {
    final h = d.inHours;
    return h > 0 ? '${h}h ${d.inMinutes.remainder(60)}m' : '${d.inMinutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;
    final sizes = AppSizes.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        sizes.screenEdgePadding,
        sizes.isCompact ? 20.0 : 28.0,
        sizes.screenEdgePadding,
        4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: ext.borderSubtle),
          const SizedBox(height: 12),
          Text(
            'Library',
            style: tt.labelSmall?.copyWith(
              color: ext.textTertiary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 24,
            runSpacing: 6,
            children: [
              _StatChip(label: 'Songs', value: totalSongs.toString()),
              _StatChip(label: 'Albums', value: totalAlbums.toString()),
              _StatChip(label: 'Artists', value: totalArtists.toString()),
              _StatChip(label: 'Duration', value: _fmtDuration(totalDuration)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: tt.bodyMedium?.copyWith(
            color: ext.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: tt.bodySmall?.copyWith(color: ext.textTertiary),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Scan progress banner
// ---------------------------------------------------------------------------

class _ScanBanner extends StatelessWidget {
  const _ScanBanner({required this.state});
  final ScanState state;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;
    final sizes = AppSizes.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        sizes.screenEdgePadding,
        0,
        sizes.screenEdgePadding,
        12,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(sizes.cardRadiusSm),
          border: Border.all(color: accent.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: accent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Scanning library… ${state.processed} / ${state.total}',
                    style: tt.bodySmall?.copyWith(color: ext.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: state.progressFraction,
              backgroundColor: ext.borderSubtle,
              color: accent,
              minHeight: 3,
              borderRadius: BorderRadius.circular(2),
            ),
          ],
        ),
      ),
    );
  }
}
