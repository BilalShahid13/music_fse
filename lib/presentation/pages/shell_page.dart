import 'dart:async';
import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/localization/generated/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/logger.dart';
import '../../domain/repositories/settings_repository.dart';
import '../providers/navigation_provider.dart';
import '../providers/multi_select_provider.dart';
import '../providers/playback_provider.dart';
import '../providers/repository_providers.dart';
import '../providers/scan_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/toast_provider.dart';
import 'library/library_folder_commands.dart';
import 'library/library_selection_commands.dart';
import 'library/library_tab_commands.dart';
import 'queue/queue_drawer.dart';
import '../widgets/custom_title_bar.dart';
import '../widgets/context_menu.dart';
import '../widgets/drop_overlay.dart';
import '../widgets/focus_hint_registry.dart';
import '../widgets/gamepad_button_hints.dart';
import '../widgets/mini_player_bar.dart';
import '../widgets/mini_player_popup_registry.dart';
import '../widgets/settings_popup_registry.dart';
import '../widgets/side_nav_rail.dart';

/// Outer scaffold that wraps all main pages.
///
/// Layout (per REQUIREMENTS §7.1 / CLAUDE.md §7.1):
/// ```
/// Column
/// ├── CustomTitleBar (36px)
/// └── Expanded
///     └── Row
///         ├── SideNavRail (220px or 72px)
///         └── Expanded
///             └── Column
///                 ├── Expanded → child (GoRouter content)
///                 ├── MiniPlayerBar (84px, if song loaded)
///                 └── GamepadButtonHints (40px)
/// ```
///
/// Focus management:
/// - Two [FocusTraversalGroup]s: nav rail (order 0) and content area (order 1).
/// - D-pad left from the content area edge moves focus to the nav rail.
/// - B button from nav-rail focus context returns to content area.
class ShellPage extends ConsumerStatefulWidget {
  const ShellPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends ConsumerState<ShellPage> {
  late final FocusNode _navRailFocus;
  late final FocusNode _contentFocus;
  late final FocusNode _miniPlayerFocus;
  late final FocusNode _shellFocusNode;
  FocusNode? _queueDrawerReturnFocus;
  bool _isDragging = false;
  bool _isWideNavRailExpanded = true;
  bool _hasManualWideNavRailChoice = false;
  bool _showQueueDrawer = false;
  String _lastFocusSnapshot = '';

  String _focusLabel(FocusNode? node) {
    if (node == null) return 'null';
    final label = node.debugLabel ?? node.runtimeType.toString();
    try {
      final rect = node.rect;
      return '$label @(${rect.center.dx.toStringAsFixed(1)},${rect.center.dy.toStringAsFixed(1)})';
    } catch (_) {
      return label;
    }
  }

  String _regionSnapshot() {
    final primary = FocusManager.instance.primaryFocus;
    return 'route=${ref.read(navigationProvider)} nav=${_isFocusWithinScope(_navRailFocus)} content=${_isFocusWithinScope(_contentFocus)} mini=${_isFocusWithinScope(_miniPlayerFocus)} primary=${_focusLabel(primary)}';
  }

  bool _isContextWithinSubtree(BuildContext context, BuildContext ancestor) {
    if (identical(context, ancestor)) return true;

    var found = false;
    context.visitAncestorElements((element) {
      if (identical(element, ancestor)) {
        found = true;
        return false;
      }
      return true;
    });
    return found;
  }

  bool _isNodeWithinScopeSubtree(FocusNode node, FocusNode scopeNode) {
    final nodeContext = node.context;
    final scopeContext = scopeNode.context;
    if (nodeContext == null || scopeContext == null) return false;
    return _isContextWithinSubtree(nodeContext, scopeContext);
  }

  bool _isFocusWithinScope(FocusNode scopeNode) {
    final primary = FocusManager.instance.primaryFocus;
    if (primary == null) return false;
    if (identical(primary, scopeNode)) return true;
    return _isNodeWithinScopeSubtree(primary, scopeNode);
  }

  void _requestRebuildSafely() {
    if (!mounted) return;
    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.idle ||
        phase == SchedulerPhase.postFrameCallbacks) {
      setState(() {});
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  void _requestTraversalFocus(
    FocusNode node, {
    ScrollPositionAlignmentPolicy? alignmentPolicy,
    double? alignment,
    Duration? duration,
    Curve? curve,
  }) {
    node.requestFocus();
    if (node.context == null) return;

    final animateFocusScrolling =
        ref.read(animateFocusScrollingProvider).value ?? true;
    Scrollable.ensureVisible(
      node.context!,
      alignment: alignment ?? 1,
      alignmentPolicy:
          alignmentPolicy ?? ScrollPositionAlignmentPolicy.explicit,
      duration: animateFocusScrolling
          ? (duration ??
              const Duration(milliseconds: AppConstants.focusScrollDurationMs))
          : Duration.zero,
      curve: curve ?? Curves.easeOut,
    );
  }

  void _ensurePrimaryFocusVisible(TraversalDirection direction) {
    final primary = FocusManager.instance.primaryFocus;
    if (primary?.context == null) return;

    final animateFocusScrolling =
        ref.read(animateFocusScrollingProvider).value ?? true;
    final alignmentPolicy = switch (direction) {
      TraversalDirection.up ||
      TraversalDirection.left =>
        ScrollPositionAlignmentPolicy.keepVisibleAtStart,
      TraversalDirection.down ||
      TraversalDirection.right =>
        ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
    };

    Scrollable.ensureVisible(
      primary!.context!,
      alignmentPolicy: alignmentPolicy,
      duration: animateFocusScrolling
          ? const Duration(milliseconds: AppConstants.focusScrollDurationMs)
          : Duration.zero,
      curve: Curves.easeOut,
    );
  }

  void _requestManagedFocus(
    FocusNode node, {
    TraversalDirection? direction,
    ScrollPositionAlignmentPolicy? alignmentPolicy,
  }) {
    final policy = alignmentPolicy ??
        switch (direction) {
          TraversalDirection.up ||
          TraversalDirection.left =>
            ScrollPositionAlignmentPolicy.keepVisibleAtStart,
          TraversalDirection.down ||
          TraversalDirection.right =>
            ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
          null => ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
        };

    _requestTraversalFocus(node, alignmentPolicy: policy);
  }

  bool _moveWithinScope(FocusNode scopeNode, TraversalDirection direction) {
    final previous = FocusManager.instance.primaryFocus;
    if (previous == null) return false;

    final moved = previous.focusInDirection(direction);
    if (!moved) return false;

    final next = FocusManager.instance.primaryFocus;
    final stayedInScope = next != null &&
        (identical(next, scopeNode) ||
            _isNodeWithinScopeSubtree(next, scopeNode));
    if (stayedInScope) {
      _ensurePrimaryFocusVisible(direction);
      return true;
    }

    if (previous.context != null && previous.canRequestFocus) {
      previous.requestFocus();
    }
    return false;
  }

  bool _isOffstageForTraversal(BuildContext context) {
    var isOffstage = false;
    context.visitAncestorElements((element) {
      final widget = element.widget;
      if (widget is Offstage && widget.offstage) {
        isOffstage = true;
        return false;
      }
      return true;
    });
    return isOffstage;
  }

  bool _isTraversalCandidate(FocusNode node) {
    if (!node.canRequestFocus ||
        node.skipTraversal ||
        node.context == null ||
        node is FocusScopeNode) {
      return false;
    }

    final context = node.context!;
    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) {
      return false;
    }
    if (_isOffstageForTraversal(context)) {
      return false;
    }

    final renderObject = context.findRenderObject();
    if (renderObject == null || !renderObject.attached) {
      return false;
    }
    if (renderObject is RenderBox && !renderObject.hasSize) {
      return false;
    }

    try {
      final rect = node.rect;
      return rect.left.isFinite &&
          rect.top.isFinite &&
          rect.right.isFinite &&
          rect.bottom.isFinite;
    } catch (_) {
      return false;
    }
  }

  void _onPrimaryFocusChanged() {
    final snapshot = _regionSnapshot();
    if (snapshot != _lastFocusSnapshot) {
      _lastFocusSnapshot = snapshot;
      AppLogger.debug('Focus changed: $snapshot', tag: 'ShellFocus');
    }
    _requestRebuildSafely();
  }

  void _onContextMenuVisibilityChanged() {
    _requestRebuildSafely();
  }

  void _onLibraryFoldersStateChanged() {
    _requestRebuildSafely();
  }

  void _onMiniPlayerPopupStateChanged() {
    _requestRebuildSafely();
  }

  void _openQueueDrawer() {
    if (_showQueueDrawer) return;
    _queueDrawerReturnFocus = FocusManager.instance.primaryFocus;
    setState(() => _showQueueDrawer = true);
  }

  void _closeQueueDrawer({bool restoreFocus = true}) {
    if (!_showQueueDrawer) return;
    final returnFocus = _queueDrawerReturnFocus;
    _queueDrawerReturnFocus = null;
    setState(() => _showQueueDrawer = false);

    if (!restoreFocus) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (returnFocus != null &&
          returnFocus.context != null &&
          returnFocus.canRequestFocus) {
        _requestManagedFocus(returnFocus);
        return;
      }
      if (_focusableDescendantsOf(_miniPlayerFocus).isNotEmpty) {
        _focusTopmostInScope(_miniPlayerFocus);
        return;
      }
      _focusTopmostInScope(_contentFocus);
    });
  }

  void _openNowPlayingScreen() {
    _closeQueueDrawer(restoreFocus: false);
    context.push('/now-playing');
  }

  Future<void> _restoreWideNavRailPreference() async {
    final result = await ref
        .read(settingsRepositoryProvider)
        .getBool(SettingsKeys.wideNavRailExpanded);

    if (result.isFailure) {
      AppLogger.error(
        'ShellPage: failed to restore wide nav rail preference',
        tag: 'ShellPage',
        error: result.errorOrNull,
      );
      return;
    }

    final storedExpanded = result.valueOrNull;
    if (!mounted ||
        _hasManualWideNavRailChoice ||
        storedExpanded == null ||
        storedExpanded == _isWideNavRailExpanded) {
      return;
    }

    setState(() => _isWideNavRailExpanded = storedExpanded);
  }

  Future<void> _persistWideNavRailPreference(bool expanded) async {
    final result = await ref.read(settingsRepositoryProvider).setBool(
          SettingsKeys.wideNavRailExpanded,
          value: expanded,
        );

    if (result.isFailure) {
      AppLogger.error(
        'ShellPage: failed to persist wide nav rail preference',
        tag: 'ShellPage',
        error: result.errorOrNull,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _navRailFocus = FocusNode(debugLabel: 'ShellPage-navRail');
    _contentFocus = FocusNode(debugLabel: 'ShellPage-content');
    _miniPlayerFocus = FocusNode(debugLabel: 'ShellPage-miniPlayer');
    _shellFocusNode = FocusNode(debugLabel: 'ShellPage-shell')
      ..skipTraversal = true;

    unawaited(_restoreWideNavRailPreference());

    // Ensure nav rail Home item has focus on first frame so the user sees a
    // focus ring immediately (console-like experience).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (FocusManager.instance.primaryFocus == null ||
          FocusManager.instance.primaryFocus ==
              FocusManager.instance.rootScope) {
        // Focus the topmost nav rail item (Home) by Y position.
        _focusTopmostInScope(_navRailFocus);
      }
    });
    FocusManager.instance.addListener(_onPrimaryFocusChanged);
    contextMenuVisible.addListener(_onContextMenuVisibilityChanged);
    libraryFoldersCanGoUp.addListener(_onLibraryFoldersStateChanged);
    miniPlayerVolumePopupVisible.addListener(_onMiniPlayerPopupStateChanged);
    miniPlayerVolumePopupDismiss.addListener(_onMiniPlayerPopupStateChanged);
    settingsThemePopupVisible.addListener(_onMiniPlayerPopupStateChanged);
    settingsThemePopupDismiss.addListener(_onMiniPlayerPopupStateChanged);
    settingsColorPopupVisible.addListener(_onMiniPlayerPopupStateChanged);
    settingsColorPopupDismiss.addListener(_onMiniPlayerPopupStateChanged);
  }

  @override
  void dispose() {
    _navRailFocus.dispose();
    _contentFocus.dispose();
    _miniPlayerFocus.dispose();
    _shellFocusNode.dispose();
    FocusManager.instance.removeListener(_onPrimaryFocusChanged);
    contextMenuVisible.removeListener(_onContextMenuVisibilityChanged);
    libraryFoldersCanGoUp.removeListener(_onLibraryFoldersStateChanged);
    miniPlayerVolumePopupVisible.removeListener(_onMiniPlayerPopupStateChanged);
    miniPlayerVolumePopupDismiss.removeListener(_onMiniPlayerPopupStateChanged);
    settingsThemePopupVisible.removeListener(_onMiniPlayerPopupStateChanged);
    settingsThemePopupDismiss.removeListener(_onMiniPlayerPopupStateChanged);
    settingsColorPopupVisible.removeListener(_onMiniPlayerPopupStateChanged);
    settingsColorPopupDismiss.removeListener(_onMiniPlayerPopupStateChanged);
    super.dispose();
  }

  /// Focus the nav rail item matching the current route index.
  void _focusNavRail() => _focusNearestInScope(_navRailFocus);

  /// Move focus from nav rail to the content area.
  /// Picks the content item whose vertical center is closest to the nav rail item,
  /// and is the leftmost in that row (within a small Y tolerance).
  void _focusContentFromNavRail() {
    final currentRoute = ref.read(navigationProvider);
    if (currentRoute == '/home') {
      final homeEntry = _preferredHomeEntryFocus();
      if (homeEntry != null) {
        _requestManagedFocus(homeEntry, direction: TraversalDirection.right);
        return;
      }
    }
    if (RegExp(r'^/playlists/\d+$').hasMatch(currentRoute)) {
      final playlistEntry = _preferredPlaylistDetailEntryFocus();
      if (playlistEntry != null) {
        _requestManagedFocus(
          playlistEntry,
          direction: TraversalDirection.right,
        );
        return;
      }
    }

    final navItem = FocusManager.instance.primaryFocus;
    if (navItem == null || !_navRailFocus.hasFocus) return;
    final navY = navItem.rect.center.dy;
    final contentItems = _focusableDescendantsOf(_contentFocus);
    if (contentItems.isEmpty) return;
    const rowTolerance = 4.0;
    // Pass 1: find the closest row by Y distance.
    double minDistance = double.infinity;
    for (final node in contentItems) {
      try {
        final dist = (node.rect.center.dy - navY).abs();
        if (dist < minDistance) minDistance = dist;
      } catch (_) {}
    }
    // Pass 2: among items in that closest row, pick the leftmost.
    FocusNode? nearest;
    double nearestX = double.infinity;
    for (final node in contentItems) {
      try {
        final rect = node.rect;
        final dist = (rect.center.dy - navY).abs();
        if ((dist - minDistance).abs() <= rowTolerance &&
            rect.left < nearestX) {
          nearestX = rect.left;
          nearest = node;
        }
      } catch (_) {}
    }
    _requestManagedFocus(
      nearest ?? contentItems.first,
      direction: TraversalDirection.right,
    );
  }

  FocusNode? _preferredHomeEntryFocus() {
    final contentItems = _focusableDescendantsOf(_contentFocus);
    for (final label in const ['Home-resume', 'Home-firstSection']) {
      for (final node in contentItems) {
        if (node.debugLabel == label) return node;
      }
    }
    return null;
  }

  FocusNode? _preferredPlaylistDetailEntryFocus() {
    final contentItems = _focusableDescendantsOf(_contentFocus);
    for (final node in contentItems) {
      if (node.debugLabel == 'PlaylistDetail-default') return node;
    }
    return null;
  }

  /// Move focus from content area to nav rail.
  /// Picks the nav rail item whose vertical center is closest to the content item.
  void _focusNavRailFromContent() {
    final contentItem = FocusManager.instance.primaryFocus;
    if (contentItem == null || !_contentFocus.hasFocus) return;
    final contentY = contentItem.rect.center.dy;
    final navItems = _focusableDescendantsOf(_navRailFocus);
    if (navItems.isEmpty) return;
    double minDistance = double.infinity;
    FocusNode? nearest;
    for (final node in navItems) {
      try {
        final dist = (node.rect.center.dy - contentY).abs();
        if (dist < minDistance) {
          minDistance = dist;
          nearest = node;
        }
      } catch (_) {}
    }
    _requestManagedFocus(
      nearest ?? navItems.first,
      direction: TraversalDirection.left,
    );
  }

  /// Return the focusable descendants that are actual interactive widgets
  /// inside [scopeNode]. Excludes [FocusScopeNode]s (container scopes from
  /// Navigator, FocusScope, etc.) which should never receive direct focus.
  List<FocusNode> _focusableDescendantsOf(FocusNode scopeNode) {
    return scopeNode.descendants
        .where((node) =>
            _isTraversalCandidate(node) &&
            _isNodeWithinScopeSubtree(node, scopeNode))
        .toList();
  }

  /// Find the focusable descendant in [scopeNode] whose vertical center is
  /// closest to the currently focused widget. Falls back to the first
  /// descendant when no spatial comparison is possible.
  void _focusNearestInScope(FocusNode scopeNode) {
    final descendants = _focusableDescendantsOf(scopeNode);
    if (descendants.isEmpty) return;

    final current = FocusManager.instance.primaryFocus;
    if (current == null || current.context == null) {
      _requestManagedFocus(descendants.first);
      return;
    }

    final currentCenterY = current.rect.center.dy;

    // Items within this Y tolerance are considered on the same row.
    const rowTolerance = 4.0;

    // Pass 1: find the closest row by Y distance.
    double minDistance = double.infinity;
    for (final node in descendants) {
      try {
        final dist = (node.rect.center.dy - currentCenterY).abs();
        if (dist < minDistance) minDistance = dist;
      } catch (_) {}
    }

    // Pass 2: among items in that closest row, pick the leftmost.
    FocusNode? nearest;
    double nearestX = double.infinity;
    for (final node in descendants) {
      try {
        final rect = node.rect;
        final dist = (rect.center.dy - currentCenterY).abs();
        if ((dist - minDistance).abs() <= rowTolerance &&
            rect.left < nearestX) {
          nearestX = rect.left;
          nearest = node;
        }
      } catch (_) {}
    }

    _requestManagedFocus(nearest ?? descendants.first);
  }

  /// Focus the topmost (smallest Y) focusable descendant in [scopeNode].
  void _focusTopmostInScope(FocusNode scopeNode) {
    final descendants = _focusableDescendantsOf(scopeNode);
    if (descendants.isEmpty) return;

    const rowTolerance = 4.0;

    // Pass 1: find the minimum Y (topmost row).
    double minY = double.infinity;
    for (final node in descendants) {
      try {
        final y = node.rect.top;
        if (y < minY) minY = y;
      } catch (_) {}
    }

    // Pass 2: among items in that topmost row, pick the leftmost.
    FocusNode? topmost;
    double topmostX = double.infinity;
    for (final node in descendants) {
      try {
        final rect = node.rect;
        if ((rect.top - minY).abs() <= rowTolerance && rect.left < topmostX) {
          topmostX = rect.left;
          topmost = node;
        }
      } catch (_) {}
    }

    _requestManagedFocus(topmost ?? descendants.first);
  }

  /// Find the next focusable descendant below [current] inside [scopeNode]
  /// by screen Y position. Returns null if already at the bottom.
  FocusNode? _nextBelow(FocusNode scopeNode, FocusNode current) {
    if (current.context == null) return null;
    final currentY = current.rect.center.dy;
    FocusNode? best;
    double bestDist = double.infinity;
    for (final node in _focusableDescendantsOf(scopeNode)) {
      try {
        final dist = node.rect.center.dy - currentY;
        if (dist > 1 && dist < bestDist) {
          bestDist = dist;
          best = node;
        }
      } catch (_) {}
    }
    return best;
  }

  /// Find the next focusable descendant above [current] inside [scopeNode]
  /// by screen Y position. Returns null if already at the top.
  FocusNode? _nextAbove(FocusNode scopeNode, FocusNode current) {
    if (current.context == null) return null;
    final currentY = current.rect.center.dy;
    FocusNode? best;
    double bestDist = double.infinity;
    for (final node in _focusableDescendantsOf(scopeNode)) {
      try {
        final dist = currentY - node.rect.center.dy;
        if (dist > 1 && dist < bestDist) {
          bestDist = dist;
          best = node;
        }
      } catch (_) {}
    }
    return best;
  }

  KeyEventResult _handleShellKey(FocusNode node, KeyEvent event) {
    // When a modal route (dialog/popup route) is on top, suspend shell-level
    // key handling so focus/navigation stays inside that modal.
    final shellRoute = ModalRoute.of(context);
    if (shellRoute != null && !shellRoute.isCurrent) {
      return KeyEventResult.ignored;
    }

    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;
    final isLeft = key == LogicalKeyboardKey.arrowLeft;
    final isRight = key == LogicalKeyboardKey.arrowRight;
    final isDown = key == LogicalKeyboardKey.arrowDown;
    final isUp = key == LogicalKeyboardKey.arrowUp;

    // ── LB/RB = tab switch on /library, global prev/next elsewhere ──────
    final route = ref.read(navigationProvider);
    if (route == '/library' &&
        (key == LogicalKeyboardKey.gameButtonLeft1 ||
            key == LogicalKeyboardKey.gameButtonRight1)) {
      return KeyEventResult.ignored;
    }

    // ── LB/RB = global prev/next track when nothing else consumes them ──
    if (key == LogicalKeyboardKey.gameButtonLeft1) {
      ref.read(playbackProvider.notifier).skipPrevious();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.gameButtonRight1) {
      ref.read(playbackProvider.notifier).skipNext();
      return KeyEventResult.handled;
    }

    // ── D-pad left: content → nav rail ──────────────────────────────────
    if (isLeft) {
      if (_contentFocus.hasFocus) {
        // Try normal traversal within the content group first.
        if (_moveWithinScope(_contentFocus, TraversalDirection.left)) {
          return KeyEventResult.handled;
        }
        _focusNavRailFromContent();
        return KeyEventResult.handled;
      }
      if (_miniPlayerFocus.hasFocus) {
        // Try within mini player first.
        if (_moveWithinScope(_miniPlayerFocus, TraversalDirection.left)) {
          return KeyEventResult.handled;
        }
        _focusNavRail();
        return KeyEventResult.handled;
      }
    }

    // ── D-pad right: nav rail → content; within mini player stay contained ──
    if (isRight) {
      if (_navRailFocus.hasFocus) {
        _focusContentFromNavRail();
        return KeyEventResult.handled;
      }
      if (_miniPlayerFocus.hasFocus) {
        // Try to move right within the mini player controls row.
        if (_moveWithinScope(_miniPlayerFocus, TraversalDirection.right)) {
          return KeyEventResult.handled;
        }
        // Already at the rightmost control — consume so focus never escapes
        // the mini player into the content area above.
        return KeyEventResult.handled;
      }
    }

    // ── D-pad down: content → mini player ───────────────────────────────
    if (isDown) {
      AppLogger.debug(
        'Down pressed: ${_regionSnapshot()}',
        tag: 'ShellFocus',
      );
      if (_contentFocus.hasFocus) {
        if (FocusManager.instance.primaryFocus != null) {
          // Let Flutter's built-in directional focus handle movement
          // within the content area (it respects nested traversal groups).
          if (_moveWithinScope(_contentFocus, TraversalDirection.down)) {
            AppLogger.debug(
              'Down moved within content to ${_focusLabel(FocusManager.instance.primaryFocus)}',
              tag: 'ShellFocus',
            );
            return KeyEventResult.handled;
          }
          // At the bottom of content — jump to mini player.
          if (_hasMiniPlayer) {
            _focusNearestInScope(_miniPlayerFocus);
            AppLogger.debug(
              'Down jumped content -> mini, now ${_focusLabel(FocusManager.instance.primaryFocus)}',
              tag: 'ShellFocus',
            );
            return KeyEventResult.handled;
          }
        }
      }
      if (_miniPlayerFocus.hasFocus) {
        final primary = FocusManager.instance.primaryFocus;
        final below =
            primary == null ? null : _nextBelow(_miniPlayerFocus, primary);
        if (below != null) {
          _requestManagedFocus(
            below,
            direction: TraversalDirection.down,
          );
          _ensurePrimaryFocusVisible(TraversalDirection.down);
          AppLogger.debug(
            'Down moved within mini to ${_focusLabel(FocusManager.instance.primaryFocus)}',
            tag: 'ShellFocus',
          );
          return KeyEventResult.handled;
        }
        // No region exists below mini player. Never traverse down from mini,
        // otherwise focus can escape to non-content controls (e.g. hints bar).
        AppLogger.debug('Down at mini boundary consumed', tag: 'ShellFocus');
        return KeyEventResult.handled;
      }
      if (_navRailFocus.hasFocus) {
        final primary = FocusManager.instance.primaryFocus;
        if (primary != null) {
          final below = _nextBelow(_navRailFocus, primary);
          if (below != null) {
            _requestManagedFocus(
              below,
              direction: TraversalDirection.down,
            );
            return KeyEventResult.handled;
          }
          // At bottom of nav rail — jump to mini player if available.
          if (_hasMiniPlayer) {
            _focusNearestInScope(_miniPlayerFocus);
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.handled;
      }
    }

    // ── D-pad up: mini player → content ─────────────────────────────────
    if (isUp) {
      AppLogger.debug(
        'Up pressed: ${_regionSnapshot()}',
        tag: 'ShellFocus',
      );
      if (_contentFocus.hasFocus) {
        if (FocusManager.instance.primaryFocus != null) {
          if (_moveWithinScope(_contentFocus, TraversalDirection.up)) {
            AppLogger.debug(
              'Up moved within content to ${_focusLabel(FocusManager.instance.primaryFocus)}',
              tag: 'ShellFocus',
            );
            return KeyEventResult.handled;
          }
          _focusNavRailFromContent();
          AppLogger.debug(
            'Up jumped content -> nav, now ${_focusLabel(FocusManager.instance.primaryFocus)}',
            tag: 'ShellFocus',
          );
          return KeyEventResult.handled;
        }
      }
      if (_miniPlayerFocus.hasFocus) {
        final primary = FocusManager.instance.primaryFocus;
        final above =
            primary == null ? null : _nextAbove(_miniPlayerFocus, primary);
        if (above != null) {
          _requestManagedFocus(
            above,
            direction: TraversalDirection.up,
          );
          _ensurePrimaryFocusVisible(TraversalDirection.up);
          AppLogger.debug(
            'Up moved within mini to ${_focusLabel(FocusManager.instance.primaryFocus)}',
            tag: 'ShellFocus',
          );
          return KeyEventResult.handled;
        }
        _focusNearestInScope(_contentFocus);
        AppLogger.debug(
          'Up jumped mini -> content, now ${_focusLabel(FocusManager.instance.primaryFocus)}',
          tag: 'ShellFocus',
        );
        return KeyEventResult.handled;
      }
      if (_navRailFocus.hasFocus) {
        final primary = FocusManager.instance.primaryFocus;
        if (primary != null) {
          final above = _nextAbove(_navRailFocus, primary);
          if (above != null) {
            _requestManagedFocus(
              above,
              direction: TraversalDirection.up,
            );
            return KeyEventResult.handled;
          }
        }
        // Already at top — nowhere to go.
        return KeyEventResult.handled;
      }
    }

    // ── Back from shell contexts → close queue or leave nav rail ─────────
    if (key == LogicalKeyboardKey.escape ||
        key == LogicalKeyboardKey.gameButtonB ||
        key == LogicalKeyboardKey.keyB) {
      if (_showQueueDrawer) {
        _closeQueueDrawer();
        return KeyEventResult.handled;
      }
      if (_navRailFocus.hasFocus) {
        _focusContentFromNavRail();
        return KeyEventResult.handled;
      }
    }

    if (key == LogicalKeyboardKey.gameButtonLeft2) {
      if (_hasMiniPlayer && ref.read(navigationProvider) != '/now-playing') {
        _openNowPlayingScreen();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    if (key == LogicalKeyboardKey.gameButtonRight2) {
      if (_hasMiniPlayer && ref.read(navigationProvider) != '/now-playing') {
        if (_showQueueDrawer) {
          _closeQueueDrawer();
        } else {
          _openQueueDrawer();
        }
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    return KeyEventResult.ignored;
  }

  bool get _hasMiniPlayer =>
      ref.read(playbackProvider.select((s) => s.currentSong != null));

  void _toggleWideNavRail() {
    _hasManualWideNavRailChoice = true;
    final expanded = !_isWideNavRailExpanded;
    setState(() => _isWideNavRailExpanded = expanded);
    unawaited(_persistWideNavRailPreference(expanded));
  }

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);
    final isWideLayout =
        MediaQuery.sizeOf(context).width >= AppConstants.layoutBreakpoint;
    final isNavRailExpanded = isWideLayout && _isWideNavRailExpanded;
    final hasSong = ref.watch(
      playbackProvider.select((s) => s.currentSong != null),
    );
    final isPlaying = ref.watch(
      playbackProvider.select((s) => s.isPlaying),
    );
    final currentRoute = ref.watch(navigationProvider);
    final multiSelect = ref.watch(multiSelectProvider);
    ref.watch(animateFocusScrollingProvider);

    return DropTarget(
      onDragEntered: (_) => setState(() => _isDragging = true),
      onDragExited: (_) => setState(() => _isDragging = false),
      onDragDone: (details) {
        setState(() => _isDragging = false);
        _handleDroppedFiles(details);
      },
      child: Focus(
        focusNode: _shellFocusNode,
        onKeyEvent: _handleShellKey,
        child: Stack(
          children: [
            ExcludeFocus(
              excluding: _showQueueDrawer,
              child: Column(
                children: [
                  // ── Title bar ─────────────────────────────────────────────────
                  const CustomTitleBar(),

                  // ── Main body ─────────────────────────────────────────────────
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              // ── Nav rail ────────────────────────────────────────────
                              Focus(
                                focusNode: _navRailFocus,
                                canRequestFocus: false,
                                skipTraversal: true,
                                child: FocusTraversalGroup(
                                  policy: OrderedTraversalPolicy(),
                                  child: SideNavRail(
                                    expanded: isNavRailExpanded,
                                    showToggle: isWideLayout,
                                    onToggleExpanded: _toggleWideNavRail,
                                  ),
                                ),
                              ),

                              // ── Content area ────────────────────────────────────────
                              Expanded(
                                child: Focus(
                                  focusNode: _contentFocus,
                                  canRequestFocus: false,
                                  skipTraversal: true,
                                  child: FocusTraversalGroup(
                                    policy: OrderedTraversalPolicy(
                                      requestFocusCallback:
                                          _requestTraversalFocus,
                                    ),
                                    child: widget.navigationShell,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Mini player (only when a track is loaded) — full width
                        if (hasSong)
                          Focus(
                            focusNode: _miniPlayerFocus,
                            canRequestFocus: false,
                            skipTraversal: true,
                            child: FocusTraversalGroup(
                              policy: OrderedTraversalPolicy(),
                              child: MiniPlayerBar(
                                onOpenNowPlaying: _openNowPlayingScreen,
                                onOpenQueue: _openQueueDrawer,
                              ),
                            ),
                          ),
                        // Gamepad button hints (always visible) — full width
                        ValueListenableBuilder<QueuePanelHintState?>(
                          valueListenable: queuePanelHintState,
                          builder: (context, queueHints, _) {
                            final hints = _hintsForContext(
                              context,
                              route: currentRoute,
                              hasSong: hasSong,
                              isPlaying: isPlaying,
                              multiSelect: multiSelect,
                              queueHints: queueHints,
                            );
                            return GamepadButtonHints(
                              aLabel: hints.aLabel,
                              bLabel: hints.bLabel,
                              xLabel: hints.xLabel,
                              yLabel: hints.yLabel,
                              startLabel: hints.startLabel,
                              leftLabel: hints.leftLabel,
                              rightLabel: hints.rightLabel,
                              upLabel: hints.upLabel,
                              downLabel: hints.downLabel,
                              lbLabel: hints.lbLabel,
                              rbLabel: hints.rbLabel,
                              onAPressed: hints.onAPressed,
                              onBPressed: hints.onBPressed,
                              onXPressed: hints.onXPressed,
                              onYPressed: hints.onYPressed,
                              onStartPressed: hints.onStartPressed,
                              onLeftPressed: hints.onLeftPressed,
                              onRightPressed: hints.onRightPressed,
                              onUpPressed: hints.onUpPressed,
                              onDownPressed: hints.onDownPressed,
                              onLbPressed: hints.onLbPressed,
                              onRbPressed: hints.onRbPressed,
                              backgroundColor:
                                  hasSong ? context.appTheme.bgSurface : null,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: sizes.titleBarHeight,
              left: 0,
              right: 0,
              bottom: sizes.buttonHintsHeight,
              child: QueueDrawer(
                isOpen: _showQueueDrawer,
                onDismiss: _closeQueueDrawer,
              ),
            ),
            if (_isDragging) const DropOverlay(),
          ],
        ),
      ),
    );
  }

  void _handleDroppedFiles(DropDoneDetails details) {
    final validExtensions = AppConstants.supportedAudioExtensions
        .map((e) => e.toLowerCase())
        .toSet();

    final audioPaths = <String>[];

    for (final file in details.files) {
      final path = file.path;
      if (FileSystemEntity.isDirectorySync(path)) {
        // Recursively collect audio files from dropped directories.
        final dir = Directory(path);
        try {
          for (final entity
              in dir.listSync(recursive: true, followLinks: false)) {
            if (entity is File) {
              final ext = entity.path.split('.').last.toLowerCase();
              if (validExtensions.contains('.$ext')) {
                audioPaths.add(entity.path);
              }
            }
          }
        } catch (_) {
          // Directory inaccessible — skip silently.
        }
      } else {
        final ext = path.split('.').last.toLowerCase();
        if (validExtensions.contains('.$ext')) {
          audioPaths.add(path);
        }
      }
    }

    if (audioPaths.isEmpty) return;

    final l10n = AppLocalizations.of(context);
    ref.read(scanProvider.notifier).scanSpecificFiles(audioPaths);
    ref.read(toastProvider.notifier).show(
          l10n?.scanningDroppedFiles(audioPaths.length) ??
              'Adding ${audioPaths.length} file(s) to library\u2026',
        );
  }

  _ButtonHintsData _hintsForContext(
    BuildContext context, {
    required String route,
    required bool hasSong,
    required bool isPlaying,
    required ({bool isActive, Set<int> selectedIds}) multiSelect,
    QueuePanelHintState? queueHints,
  }) {
    final inNav = _isFocusWithinScope(_navRailFocus);
    final inMini = _isFocusWithinScope(_miniPlayerFocus);
    final inContent = _isFocusWithinScope(_contentFocus);
    final canPop = GoRouter.of(context).canPop();
    final focusedCaps = focusedHintCapabilities.value;

    // Context menu has highest priority while open.
    if (contextMenuVisible.value) {
      return const _ButtonHintsData(
        aLabel: 'Select',
        bLabel: 'Close',
        onAPressed: requestContextMenuSelect,
        onBPressed: requestContextMenuDismiss,
      );
    }

    if (miniPlayerVolumePopupVisible.value) {
      final notifier = ref.read(playbackProvider.notifier);
      final current = ref.read(playbackProvider.select((s) => s.volume));
      return _ButtonHintsData(
        bLabel: AppLocalizations.of(context)!.hintClose,
        upLabel: AppLocalizations.of(context)!.hintVolumeUp,
        downLabel: AppLocalizations.of(context)!.hintVolumeDown,
        onBPressed: miniPlayerVolumePopupDismiss.value,
        onUpPressed: () => notifier.setVolume((current + 0.05).clamp(0.0, 1.0)),
        onDownPressed: () =>
            notifier.setVolume((current - 0.05).clamp(0.0, 1.0)),
      );
    }

    if (settingsThemePopupVisible.value) {
      return _ButtonHintsData(
        bLabel: 'Back',
        onBPressed: settingsThemePopupDismiss.value,
      );
    }

    if (settingsColorPopupVisible.value) {
      return _ButtonHintsData(
        aLabel: 'Select',
        bLabel: 'Back',
        onAPressed: focusedCaps?.onA,
        onBPressed: settingsColorPopupDismiss.value,
      );
    }

    if (_showQueueDrawer && queueHints != null) {
      return _ButtonHintsData(
        aLabel: queueHints.aLabel,
        bLabel: queueHints.bLabel,
        xLabel: queueHints.xLabel,
        yLabel: queueHints.yLabel,
        upLabel: queueHints.upLabel,
        downLabel: queueHints.downLabel,
        onAPressed: queueHints.onAPressed,
        onBPressed: queueHints.onBPressed,
        onXPressed: queueHints.onXPressed,
        onYPressed: queueHints.onYPressed,
        onUpPressed: queueHints.onUpPressed,
        onDownPressed: queueHints.onDownPressed,
      );
    }

    // Region-level overrides come first.
    if (inNav) {
      return _withStartHint(
        _ButtonHintsData(
          aLabel: 'Select',
          onAPressed: focusedCaps?.onA,
        ),
        hasSong: hasSong,
        isPlaying: isPlaying,
      );
    }

    if (inMini) {
      final isSeekFocused =
          focusedCaps?.node.debugLabel == 'MiniPlayer-seekBar';
      final playbackState = ref.read(playbackProvider);
      final totalMs = playbackState.duration.inMilliseconds;

      void seekByStep(int deltaMs) {
        if (totalMs <= 0) return;
        final targetMs =
            (playbackState.position.inMilliseconds + deltaMs).clamp(0, totalMs);
        ref
            .read(playbackProvider.notifier)
            .seek(Duration(milliseconds: targetMs));
      }

      return _withStartHint(
        _ButtonHintsData(
          aLabel: focusedCaps?.supportsA == true ? 'Select' : null,
          onAPressed: focusedCaps?.onA,
          xLabel: focusedCaps?.supportsX == true ? 'Options' : null,
          onXPressed: focusedCaps?.onX,
          yLabel: focusedCaps?.supportsY == true ? 'Favorite' : null,
          onYPressed: focusedCaps?.onY,
          leftLabel: isSeekFocused ? 'Rewind' : null,
          rightLabel: isSeekFocused ? 'Forward' : null,
          onLeftPressed:
              isSeekFocused ? () => seekByStep(-AppConstants.seekStepMs) : null,
          onRightPressed:
              isSeekFocused ? () => seekByStep(AppConstants.seekStepMs) : null,
          lbLabel: hasSong ? 'Prev' : null,
          rbLabel: hasSong ? 'Next' : null,
          onLbPressed: hasSong
              ? () => ref.read(playbackProvider.notifier).skipPrevious()
              : null,
          onRbPressed: hasSong
              ? () => ref.read(playbackProvider.notifier).skipNext()
              : null,
        ),
        hasSong: hasSong,
        isPlaying: isPlaying,
      );
    }

    // Content region: start from route defaults, then trim by focused widget
    // capability if available.
    var base = _hintsForRoute(route, canPop: canPop);

    if (route == '/library' && inContent && multiSelect.isActive) {
      return _ButtonHintsData(
        aLabel: 'Select',
        bLabel: 'Cancel',
        xLabel: 'Add Queue',
        yLabel: 'Add Playlist',
        lbLabel: 'Select All',
        onAPressed: focusedCaps?.onA,
        onBPressed: librarySelectionCancel.value,
        onXPressed: librarySelectionAddToQueue.value,
        onYPressed: librarySelectionAddToPlaylist.value,
        onLbPressed: librarySelectionSelectAll.value,
      );
    }

    if (inContent && focusedCaps != null) {
      base = base.copyWith(
        aLabel: focusedCaps.supportsA ? (base.aLabel ?? 'Select') : null,
        xLabel: focusedCaps.supportsX ? (base.xLabel ?? 'Options') : null,
        yLabel: focusedCaps.supportsY ? (base.yLabel ?? 'Favorite') : null,
        onAPressed: focusedCaps.supportsA ? focusedCaps.onA : null,
        onXPressed: focusedCaps.supportsX ? focusedCaps.onX : null,
        onYPressed: focusedCaps.supportsY ? focusedCaps.onY : null,
      );

      final isLibraryTabStrip = route == '/library' &&
          (focusedCaps.node.debugLabel?.startsWith('LibraryPage-tab-') ??
              false);
      if (isLibraryTabStrip) {
        base = base.copyWith(
          aLabel: 'Switch Tab',
          onAPressed: focusedCaps.onA,
          xLabel: null,
          onXPressed: null,
          yLabel: null,
          onYPressed: null,
        );
      }
    }

    final isLibraryTabs = route == '/library' && inContent;
    final canGoUpInLibraryFolders =
        route == '/library' && inContent && libraryFoldersCanGoUp.value;

    return _withStartHint(
        base.copyWith(
          lbLabel: isLibraryTabs ? 'Prev Tab' : (hasSong ? 'Prev' : null),
          rbLabel: isLibraryTabs ? 'Next Tab' : (hasSong ? 'Next' : null),
          onLbPressed: isLibraryTabs
              ? () {
                  libraryTabCommand.value = LibraryTabCommand(
                    id: DateTime.now().microsecondsSinceEpoch,
                    delta: -1,
                  );
                }
              : (hasSong
                  ? () => ref.read(playbackProvider.notifier).skipPrevious()
                  : null),
          onRbPressed: isLibraryTabs
              ? () {
                  libraryTabCommand.value = LibraryTabCommand(
                    id: DateTime.now().microsecondsSinceEpoch,
                    delta: 1,
                  );
                }
              : (hasSong
                  ? () => ref.read(playbackProvider.notifier).skipNext()
                  : null),
          bLabel: canGoUpInLibraryFolders ? 'Back' : (canPop ? 'Back' : null),
          onBPressed: canGoUpInLibraryFolders
              ? requestLibraryFoldersGoUp
              : (canPop ? () => GoRouter.of(context).pop() : null),
        ),
        hasSong: hasSong,
        isPlaying: isPlaying);
  }

  _ButtonHintsData _withStartHint(
    _ButtonHintsData hints, {
    required bool hasSong,
    required bool isPlaying,
  }) {
    if (!hasSong) return hints.copyWith(startLabel: null, onStartPressed: null);
    if (hints.faceButtonCount > 3) {
      return hints.copyWith(startLabel: null, onStartPressed: null);
    }

    return hints.copyWith(
      startLabel: isPlaying ? 'Pause' : 'Play',
      onStartPressed: () =>
          ref.read(playbackProvider.notifier).togglePlayPause(),
    );
  }

  /// Derive default gamepad button hints for route-level content context.
  static _ButtonHintsData _hintsForRoute(String route, {required bool canPop}) {
    // Detail pages (album, artist, genre, playlist detail) — full context
    if (route.startsWith('/library/album') ||
        route.startsWith('/library/artist') ||
        route.startsWith('/library/genre') ||
        RegExp(r'^/playlists/\d+').hasMatch(route)) {
      return const _ButtonHintsData(
        aLabel: 'Play',
        bLabel: 'Back',
        xLabel: 'Options',
        yLabel: 'Favorite',
      );
    }

    // Favorites
    if (route == '/favorites') {
      return const _ButtonHintsData(
        aLabel: 'Play',
        bLabel: 'Back',
        xLabel: 'Options',
        yLabel: 'Favorite',
      );
    }

    // Playlists list
    if (route == '/playlists') {
      return const _ButtonHintsData(
        aLabel: 'Open',
        bLabel: 'Back',
        xLabel: 'Options',
      );
    }

    // Recently played
    if (route.endsWith('/recently-played')) {
      return const _ButtonHintsData(
        aLabel: 'Play',
        bLabel: 'Back',
        yLabel: 'Favorite',
      );
    }

    // Library (songs/albums/artists/genres tabs)
    if (route == '/library') {
      return const _ButtonHintsData(
        aLabel: 'Select',
        bLabel: null,
        xLabel: 'Options',
        yLabel: 'Favorite',
      );
    }

    // Search — minimal
    if (route == '/search') {
      return const _ButtonHintsData(
        aLabel: 'Select',
        bLabel: null,
      );
    }

    // Settings
    if (route.startsWith('/settings')) {
      return const _ButtonHintsData(
        aLabel: 'Select',
        bLabel: null,
      );
    }

    if (route == '/home') {
      return const _ButtonHintsData(
        aLabel: 'Select',
        xLabel: 'Options',
      );
    }

    // Fallback
    return _ButtonHintsData(
      aLabel: 'Select',
      bLabel: canPop ? 'Back' : null,
      xLabel: 'Options',
      yLabel: 'Favorite',
    );
  }
}

class _ButtonHintsData {
  const _ButtonHintsData({
    this.aLabel,
    this.bLabel,
    this.xLabel,
    this.yLabel,
    this.startLabel,
    this.leftLabel,
    this.rightLabel,
    this.upLabel,
    this.downLabel,
    this.lbLabel,
    this.rbLabel,
    this.onAPressed,
    this.onBPressed,
    this.onXPressed,
    this.onYPressed,
    this.onStartPressed,
    this.onLeftPressed,
    this.onRightPressed,
    this.onUpPressed,
    this.onDownPressed,
    this.onLbPressed,
    this.onRbPressed,
  });
  final String? aLabel;
  final String? bLabel;
  final String? xLabel;
  final String? yLabel;
  final String? startLabel;
  final String? leftLabel;
  final String? rightLabel;
  final String? upLabel;
  final String? downLabel;
  final String? lbLabel;
  final String? rbLabel;
  final VoidCallback? onAPressed;
  final VoidCallback? onBPressed;
  final VoidCallback? onXPressed;
  final VoidCallback? onYPressed;
  final VoidCallback? onStartPressed;
  final VoidCallback? onLeftPressed;
  final VoidCallback? onRightPressed;
  final VoidCallback? onUpPressed;
  final VoidCallback? onDownPressed;
  final VoidCallback? onLbPressed;
  final VoidCallback? onRbPressed;

  int get faceButtonCount {
    var count = 0;
    if (aLabel != null) count += 1;
    if (bLabel != null) count += 1;
    if (xLabel != null) count += 1;
    if (yLabel != null) count += 1;
    return count;
  }

  static const _unset = Object();

  _ButtonHintsData copyWith({
    Object? aLabel = _unset,
    Object? bLabel = _unset,
    Object? xLabel = _unset,
    Object? yLabel = _unset,
    Object? startLabel = _unset,
    Object? leftLabel = _unset,
    Object? rightLabel = _unset,
    Object? upLabel = _unset,
    Object? downLabel = _unset,
    Object? lbLabel = _unset,
    Object? rbLabel = _unset,
    Object? onAPressed = _unset,
    Object? onBPressed = _unset,
    Object? onXPressed = _unset,
    Object? onYPressed = _unset,
    Object? onStartPressed = _unset,
    Object? onLeftPressed = _unset,
    Object? onRightPressed = _unset,
    Object? onUpPressed = _unset,
    Object? onDownPressed = _unset,
    Object? onLbPressed = _unset,
    Object? onRbPressed = _unset,
  }) {
    return _ButtonHintsData(
      aLabel: identical(aLabel, _unset) ? this.aLabel : aLabel as String?,
      bLabel: identical(bLabel, _unset) ? this.bLabel : bLabel as String?,
      xLabel: identical(xLabel, _unset) ? this.xLabel : xLabel as String?,
      yLabel: identical(yLabel, _unset) ? this.yLabel : yLabel as String?,
      startLabel: identical(startLabel, _unset)
          ? this.startLabel
          : startLabel as String?,
      leftLabel:
          identical(leftLabel, _unset) ? this.leftLabel : leftLabel as String?,
      rightLabel: identical(rightLabel, _unset)
          ? this.rightLabel
          : rightLabel as String?,
      upLabel: identical(upLabel, _unset) ? this.upLabel : upLabel as String?,
      downLabel:
          identical(downLabel, _unset) ? this.downLabel : downLabel as String?,
      lbLabel: identical(lbLabel, _unset) ? this.lbLabel : lbLabel as String?,
      rbLabel: identical(rbLabel, _unset) ? this.rbLabel : rbLabel as String?,
      onAPressed: identical(onAPressed, _unset)
          ? this.onAPressed
          : onAPressed as VoidCallback?,
      onBPressed: identical(onBPressed, _unset)
          ? this.onBPressed
          : onBPressed as VoidCallback?,
      onXPressed: identical(onXPressed, _unset)
          ? this.onXPressed
          : onXPressed as VoidCallback?,
      onYPressed: identical(onYPressed, _unset)
          ? this.onYPressed
          : onYPressed as VoidCallback?,
      onStartPressed: identical(onStartPressed, _unset)
          ? this.onStartPressed
          : onStartPressed as VoidCallback?,
      onLeftPressed: identical(onLeftPressed, _unset)
          ? this.onLeftPressed
          : onLeftPressed as VoidCallback?,
      onRightPressed: identical(onRightPressed, _unset)
          ? this.onRightPressed
          : onRightPressed as VoidCallback?,
      onUpPressed: identical(onUpPressed, _unset)
          ? this.onUpPressed
          : onUpPressed as VoidCallback?,
      onDownPressed: identical(onDownPressed, _unset)
          ? this.onDownPressed
          : onDownPressed as VoidCallback?,
      onLbPressed: identical(onLbPressed, _unset)
          ? this.onLbPressed
          : onLbPressed as VoidCallback?,
      onRbPressed: identical(onRbPressed, _unset)
          ? this.onRbPressed
          : onRbPressed as VoidCallback?,
    );
  }
}
