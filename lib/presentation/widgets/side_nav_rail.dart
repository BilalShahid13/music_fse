import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_theme.dart';
import '../providers/navigation_provider.dart';
import 'focus_highlight.dart';

/// Navigation rail rendered on the left side of the app shell.
///
/// Spec (REQUIREMENTS §6.2 / mockup):
/// - Width: 220px when window ≥ 1200px, 72px when < 1200px
/// - Background: bgDeep, right border 1px borderSubtle
/// - Top 64px header: icon + "Music FSE" text (hidden when collapsed)
/// - Nav items: Home, Library, Search, — separator —, Playlists, Favorites
/// - Bottom item: Settings (pushes to bottom via Spacer)
/// - Active item: accent.withOpacity(0.08) background, icon+label in accent
/// - Items: 48px min height, FocusHighlight on each
class SideNavRail extends ConsumerWidget {
  const SideNavRail({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final expanded = width >= AppConstants.layoutBreakpoint;
    final sizes = AppSizes.of(context);
    final navWidth = expanded
        ? AppConstants.navRailExpandedWidth
        : sizes.navRailCollapsedWidth;

    final ext = context.appTheme;
    final currentRoute = ref.watch(navigationProvider);

    return Container(
      width: navWidth,
      decoration: BoxDecoration(
        color: ext.bgDeep,
        border: Border(right: BorderSide(color: ext.borderSubtle)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ───────────────────────────────────────────────────────
          _NavHeader(expanded: expanded),

          // ── Main items (scrollable when space is tight) ─────────────────
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: false,
              children: [
                _NavItem(
                  icon: LucideIcons.house,
                  label: 'Home',
                  route: '/home',
                  currentRoute: currentRoute,
                  expanded: expanded,
                ),
                _NavItem(
                  icon: LucideIcons.library,
                  label: 'Library',
                  route: '/library',
                  currentRoute: currentRoute,
                  expanded: expanded,
                ),
                _NavItem(
                  icon: LucideIcons.search,
                  label: 'Search',
                  route: '/search',
                  currentRoute: currentRoute,
                  expanded: expanded,
                ),
                const _NavSeparator(),
                _NavItem(
                  icon: LucideIcons.listMusic,
                  label: 'Playlists',
                  route: '/playlists',
                  currentRoute: currentRoute,
                  expanded: expanded,
                ),
                _NavItem(
                  icon: LucideIcons.heart,
                  label: 'Favorites',
                  route: '/favorites',
                  currentRoute: currentRoute,
                  expanded: expanded,
                ),
              ],
            ),
          ),

          // ── Bottom: Settings ─────────────────────────────────────────────
          _NavItem(
            icon: LucideIcons.settings,
            label: 'Settings',
            route: '/settings',
            currentRoute: currentRoute,
            expanded: expanded,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// =============================================================================
// Header
// =============================================================================

class _NavHeader extends StatelessWidget {
  const _NavHeader({required this.expanded});
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;

    final compact = AppSizes.of(context).isCompact;
    final brandIconSize = compact ? 24.0 : 26.0;
    final brandGap = compact ? 10.0 : 12.0;

    return SizedBox(
      height: compact ? 56.0 : 64.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.music,
              size: brandIconSize,
              color: Theme.of(context).colorScheme.primary,
            ),
            if (expanded) ...[
              SizedBox(width: brandGap),
              Expanded(
                child: Text(
                  'Music FSE',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.titleSmall?.copyWith(
                    color: ext.textPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.1,
                    height: 1.0,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Individual nav item
// =============================================================================

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.currentRoute,
    required this.expanded,
  });

  final IconData icon;
  final String label;
  final String route;
  final String currentRoute;
  final bool expanded;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  bool get _isActive {
    // Match exact or prefix (e.g. /library/albums still highlights Library)
    return widget.currentRoute == widget.route ||
        (widget.route != '/home' &&
            widget.currentRoute.startsWith(widget.route));
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;
    final accent = Theme.of(context).colorScheme.primary;
    final sizes = AppSizes.of(context);

    final iconColor = _isActive ? accent : ext.textSecondary;
    final bgColor =
        _isActive ? accent.withOpacity(0.08) : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: FocusHighlight(
        focusNode: _focusNode,
        borderRadius: sizes.cardRadiusSm,
        onPressed: () => context.go(widget.route),
        child: GestureDetector(
          onTap: () => context.go(widget.route),
          child: AnimatedContainer(
            duration:
                const Duration(milliseconds: AppConstants.focusTransitionMs),
            constraints: const BoxConstraints(minHeight: 48),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius:
                  BorderRadius.circular(sizes.cardRadiusSm),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: widget.expanded ? 12 : 0,
            ),
            child: widget.expanded
                ? Row(
                    children: [
                      Icon(widget.icon, size: 20, color: iconColor),
                      const SizedBox(width: 12),
                      Text(
                        widget.label,
                        style: tt.bodyMedium?.copyWith(
                          color: iconColor,
                          fontWeight: _isActive
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  )
                : Center(
                    child:
                        Icon(widget.icon, size: 22, color: iconColor),
                  ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Separator
// =============================================================================

class _NavSeparator extends StatelessWidget {
  const _NavSeparator();

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: AppSizes.of(context).isCompact ? 4.0 : 6.0),
      child: Divider(color: ext.borderSubtle, height: 1, thickness: 1),
    );
  }
}
