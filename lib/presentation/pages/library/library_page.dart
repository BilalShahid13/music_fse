import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../platform/xinput/gamepad_scroll_target.dart';
import '../../providers/multi_select_provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/sort_preference_provider.dart';
import '../../widgets/focus_highlight.dart';
import 'library_selection_commands.dart';
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
  late final List<FocusNode> _tabFocusNodes;
  late final ScrollController _songsScrollController;
  late final ScrollController _albumsScrollController;
  late final ScrollController _artistsScrollController;
  late final ScrollController _genresScrollController;
  late final ScrollController _foldersScrollController;
  late final MultiSelectNotifier _multiSelectNotifier;
  int _lastCommandId = 0;
  int _lastTabIndex = 0;

  static const int _tabCount = 5;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabCount, vsync: this);
    _tabController.addListener(_onTabChanged);
    _multiSelectNotifier = ref.read(multiSelectProvider.notifier);
    _defaultContentFocus = FocusNode(debugLabel: 'LibraryPage-defaultContent');
    _tabFocusNodes = List<FocusNode>.generate(
      _tabCount,
      (index) => FocusNode(debugLabel: 'LibraryPage-tab-$index'),
    );
    _lastTabIndex = _tabController.index;
    _songsScrollController = ScrollController();
    _albumsScrollController = ScrollController();
    _artistsScrollController = ScrollController();
    _genresScrollController = ScrollController();
    _foldersScrollController = ScrollController();
    _clearLibrarySelectionCallbacks();
    libraryTabCommand.addListener(_onTabCommand);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _clearLibrarySelectionCallbacks();
    libraryTabCommand.removeListener(_onTabCommand);
    GamepadScrollTarget.clear(_albumsScrollController);
    GamepadScrollTarget.clear(_artistsScrollController);
    GamepadScrollTarget.clear(_genresScrollController);
    GamepadScrollTarget.clear(_foldersScrollController);
    GamepadScrollTarget.clear(_songsScrollController);
    _albumsScrollController.dispose();
    _artistsScrollController.dispose();
    _genresScrollController.dispose();
    _foldersScrollController.dispose();
    _songsScrollController.dispose();
    for (final focusNode in _tabFocusNodes) {
      focusNode.dispose();
    }
    _tabController.dispose();
    _defaultContentFocus.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.index != _lastTabIndex) {
      _lastTabIndex = _tabController.index;
      _clearLibrarySelectionCallbacks();
      _multiSelectNotifier.deactivate();
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _clearLibrarySelectionCallbacks() {
    librarySelectionAddToQueue.value = null;
    librarySelectionAddToPlaylist.value = null;
    librarySelectionSelectAll.value = null;
    librarySelectionCancel.value = null;
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
    _selectTab(next);
  }

  void _selectTab(int index, {bool requestFocus = true}) {
    if (index < 0 || index >= _tabCount) return;

    if (requestFocus) {
      _tabFocusNodes[index].requestFocus();
    }
    if (_tabController.index != index) {
      _tabController.animateTo(index);
    }
  }

  void _syncGamepadScrollTarget(bool isLibraryRouteActive) {
    if (!isLibraryRouteActive) {
      GamepadScrollTarget.clear(_songsScrollController);
      GamepadScrollTarget.clear(_albumsScrollController);
      GamepadScrollTarget.clear(_artistsScrollController);
      GamepadScrollTarget.clear(_genresScrollController);
      GamepadScrollTarget.clear(_foldersScrollController);
      return;
    }

    switch (_tabController.index) {
      case 0:
        GamepadScrollTarget.set(_songsScrollController);
      case 1:
        GamepadScrollTarget.set(_albumsScrollController);
      case 2:
        GamepadScrollTarget.set(_artistsScrollController);
      case 3:
        GamepadScrollTarget.set(_genresScrollController);
      case 4:
        GamepadScrollTarget.set(_foldersScrollController);
    }
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final multiSelect = ref.read(multiSelectProvider);
    if (multiSelect.isActive) {
      if (event.logicalKey == LogicalKeyboardKey.gameButtonLeft1 ||
          event.logicalKey == LogicalKeyboardKey.keyQ) {
        final selectAll = librarySelectionSelectAll.value;
        if (selectAll != null) {
          selectAll();
          return KeyEventResult.handled;
        }
      }
      if (event.logicalKey == LogicalKeyboardKey.gameButtonRight1 ||
          event.logicalKey == LogicalKeyboardKey.keyE) {
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.escape ||
          event.logicalKey == LogicalKeyboardKey.gameButtonB ||
          event.logicalKey == LogicalKeyboardKey.keyB) {
        final cancelSelection = librarySelectionCancel.value;
        if (cancelSelection != null) {
          cancelSelection();
          return KeyEventResult.handled;
        }
      }
      if (event.logicalKey == LogicalKeyboardKey.gameButtonX ||
          event.logicalKey == LogicalKeyboardKey.keyX) {
        final addToQueue = librarySelectionAddToQueue.value;
        if (addToQueue != null) {
          addToQueue();
          return KeyEventResult.handled;
        }
      }
      if (event.logicalKey == LogicalKeyboardKey.gameButtonY ||
          event.logicalKey == LogicalKeyboardKey.keyY) {
        final addToPlaylist = librarySelectionAddToPlaylist.value;
        if (addToPlaylist != null) {
          addToPlaylist();
          return KeyEventResult.handled;
        }
      }
    }

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
    final isFoldersTab = _tabController.index == 4;
    final multiSelect = ref.watch(multiSelectProvider);
    final currentRoute = ref.watch(navigationProvider);

    _syncGamepadScrollTarget(currentRoute == '/library');

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
    final tabLabels = <String>[
      l10n.libTabSongs,
      l10n.libTabAlbums,
      l10n.libTabArtists,
      l10n.libTabGenres,
      l10n.libTabFolders,
    ];

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
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(
                        horizontal: sizes.screenEdgePadding,
                      ),
                      child: FocusTraversalGroup(
                        policy: OrderedTraversalPolicy(),
                        child: Row(
                          children: List<Widget>.generate(
                            tabLabels.length,
                            (index) => Padding(
                              padding: EdgeInsets.only(
                                right: index == tabLabels.length - 1
                                    ? 0
                                    : AppConstants.focusableSpacing,
                              ),
                              child: FocusTraversalOrder(
                                order: NumericFocusOrder(index.toDouble()),
                                child: _LibraryTabButton(
                                  label: tabLabels[index],
                                  focusNode: _tabFocusNodes[index],
                                  isSelected: _tabController.index == index,
                                  onSelect: () => _selectTab(index, requestFocus: false),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
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
                  ],
                  if (isSongsTab || isFoldersTab) ...[
                    const SizedBox(width: 12),
                    Padding(
                      padding: EdgeInsets.only(right: sizes.screenEdgePadding),
                      child: LibrarySongsSelectModeButton(
                        height: _headerControlHeight,
                        isActive: multiSelect.isActive,
                        countLabel: isSongsTab ? songsCountLabel : null,
                        onPressed: () {
                          if (multiSelect.isActive) {
                            _multiSelectNotifier.deactivate();
                          } else {
                            _multiSelectNotifier.activate();
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
                  SongsTab(
                    isActive: isSongsTab,
                    defaultItemFocusNode: _defaultContentFocus,
                    scrollController: _songsScrollController,
                  ),
                  AlbumsTab(scrollController: _albumsScrollController),
                  ArtistsTab(scrollController: _artistsScrollController),
                  GenresTab(scrollController: _genresScrollController),
                  FoldersTab(
                    isActive: isFoldersTab,
                    scrollController: _foldersScrollController,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryTabButton extends StatelessWidget {
  const _LibraryTabButton({
    required this.label,
    required this.focusNode,
    required this.isSelected,
    required this.onSelect,
  });

  final String label;
  final FocusNode focusNode;
  final bool isSelected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: focusNode,
      builder: (context, _) {
        final hasFocus = focusNode.hasFocus;
        final textColor = isSelected ? ext.textPrimary : ext.textTertiary;
        final showSelectedBar = isSelected && !hasFocus;

        return SizedBox(
          height: AppConstants.minFocusableSize,
          child: Center(
            child: FocusHighlight(
              focusNode: focusNode,
              borderRadius: AppConstants.btnRadius,
              onPressed: onSelect,
              child: GestureDetector(
                onTap: onSelect,
                child: AnimatedContainer(
                  duration: const Duration(
                    milliseconds: AppConstants.focusTransitionMs,
                  ),
                  curve: Curves.easeOut,
                  constraints: const BoxConstraints(minWidth: 88),
                  height: _LibraryPageState._headerControlHeight,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: showSelectedBar
                        ? Border(
                            bottom: BorderSide(
                              color: colorScheme.primary,
                              width: AppConstants.focusBorderWidth,
                            ),
                          )
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: textTheme.labelLarge?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
