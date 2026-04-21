import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/multi_select_provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/sort_preference_provider.dart';
import 'library_tab_commands.dart';
import 'widgets/albums_tab.dart';
import 'widgets/artists_tab.dart';
import 'widgets/folders_tab.dart';
import 'widgets/genres_tab.dart';
import 'widgets/library_songs_header_controls.dart';
import 'widgets/songs_tab.dart';

/// Library page — houses 5 tabs: Songs, Albums, Artists, Genres, Folders.
///
/// Tab switching:
/// - Tap / D-pad on tab bar
/// - LB = previous tab, RB = next tab (global LB/RB override from shell is
///   suppressed here)
///
/// Default focus: tab bar → Songs tab first item.
class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> with SingleTickerProviderStateMixin {
  static const double _headerControlHeight = 38.0;
  static const List<(String, String)> _songSortOptions = [
    ('title', 'Name (A–Z)'),
    ('artist', 'Artist'),
    ('album', 'Album'),
    ('dateAdded', 'Date Added'),
    ('duration', 'Duration'),
  ];

  late final TabController _tabController;
  late final FocusNode _defaultContentFocus;
  int _lastCommandId = 0;

  static const int _tabCount = 5;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabCount, vsync: this);
    _tabController.addListener(_onTabChanged);
    _defaultContentFocus = FocusNode(debugLabel: 'LibraryPage-defaultContent');
    libraryTabCommand.addListener(_onTabCommand);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    ref.read(multiSelectProvider.notifier).deactivate();
    libraryTabCommand.removeListener(_onTabCommand);
    _tabController.dispose();
    _defaultContentFocus.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (mounted) {
      setState(() {});
    }
    if (_tabController.index == 0) return;
    ref.read(multiSelectProvider.notifier).deactivate();
  }

  void _onTabCommand() {
    final command = libraryTabCommand.value;
    if (command == null) return;
    if (command.id == _lastCommandId) return;
    _lastCommandId = command.id;
    _switchTabBy(command.delta);
  }

  void _switchTabBy(int delta) {
    final next = (_tabController.index + delta).clamp(0, _tabCount - 1);
    if (next == _tabController.index) return;
    _tabController.animateTo(next);
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    // LB / RB switch tabs.
    if (event.logicalKey == LogicalKeyboardKey.gameButtonLeft1) {
      _switchTabBy(-1);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.gameButtonRight1) {
      _switchTabBy(1);
      return KeyEventResult.handled;
    }
    // B / Escape — Library is a root tab so just ignore (shell handles nav).
    if (event.logicalKey == LogicalKeyboardKey.escape || event.logicalKey == LogicalKeyboardKey.gameButtonB) {
      return KeyEventResult.ignored;
    }
    // Start = play/pause toggle.
    if (event.logicalKey == LogicalKeyboardKey.gameButtonStart) {
      return KeyEventResult.ignored; // Let shell handle it.
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final sizes = AppSizes.of(context);
    final isSongsTab = _tabController.index == 0;
    final multiSelect = ref.watch(multiSelectProvider);

    final songsSortPrefAsync = ref.watch(
      sortPreferenceProvider('songs', defaultSortBy: 'title'),
    );
    final songsSortBy = songsSortPrefAsync.value?.sortBy ?? 'title';
    final songsAscending = songsSortPrefAsync.value?.ascending ?? true;
    final songsAsync = ref.watch(
      songsProvider(sortBy: songsSortBy, ascending: songsAscending),
    );
    final songsCount = songsAsync.asData?.value.length;
    final songsCountLabel = songsCount == null ? null : '$songsCount song${songsCount == 1 ? '' : 's'}';

    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: _handleKey,
      child: Scaffold(
        backgroundColor: ext.bgDeep,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                sizes.screenEdgePadding,
                sizes.screenEdgePadding,
                sizes.screenEdgePadding,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.navLibrary,
                    style: tt.headlineLarge?.copyWith(
                      color: ext.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            // ── Tab bar ──────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.only(top: sizes.isCompact ? 8 : 12),
              child: Row(
                children: [
                  Expanded(
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      dividerColor: Colors.transparent,
                      indicatorColor: Theme.of(context).colorScheme.primary,
                      labelColor: ext.textPrimary,
                      indicatorSize: TabBarIndicatorSize.tab,
                      unselectedLabelColor: ext.textTertiary,
                      indicatorWeight: AppConstants.focusBorderWidth,
                      tabAlignment: TabAlignment.start,
                      labelStyle: tt.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                      unselectedLabelStyle: tt.labelLarge,
                      tabs: [
                        Tab(text: l10n.libTabSongs),
                        Tab(text: l10n.libTabAlbums),
                        Tab(text: l10n.libTabArtists),
                        Tab(text: l10n.libTabGenres),
                        Tab(text: l10n.libTabFolders),
                      ],
                    ),
                  ),
                  if (isSongsTab) ...[
                    const SizedBox(width: 12),
                    LibrarySongsSortDropdown(
                      height: _headerControlHeight,
                      value: songsSortBy,
                      options: _songSortOptions,
                      ascending: songsAscending,
                      onChanged: (key, asc) {
                        ref.read(sortPreferenceProvider('songs', defaultSortBy: 'title').notifier).setSort(sortBy: key, ascending: asc);
                      },
                    ),
                    const SizedBox(width: 12),
                    Padding(
                      padding: EdgeInsets.only(right: sizes.screenEdgePadding),
                      child: LibrarySongsSelectModeButton(
                        height: _headerControlHeight,
                        isActive: multiSelect.isActive,
                        countLabel: songsCountLabel,
                        onPressed: () {
                          if (multiSelect.isActive) {
                            ref.read(multiSelectProvider.notifier).deactivate();
                          } else {
                            ref.read(multiSelectProvider.notifier).activate();
                          }
                        },
                      ),
                    ),
                  ] else
                    SizedBox(width: sizes.screenEdgePadding),
                ],
              ),
            ),

            // ── Tab content ──────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  SongsTab(defaultItemFocusNode: _defaultContentFocus),
                  const AlbumsTab(),
                  const ArtistsTab(),
                  const GenresTab(),
                  const FoldersTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
