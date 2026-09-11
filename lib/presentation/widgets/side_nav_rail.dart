import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/localization/generated/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../providers/navigation_provider.dart';
import 'focus_highlight.dart';

/// Navigation rail rendered on the left side of the app shell.
///
/// Spec (REQUIREMENTS §6.2 / mockup):
/// - Width: 220px when expanded, 72px when collapsed
/// - Background: bgDeep, right border 1px borderSubtle
/// - Top 64px header: icon + "Music FSE" text (hidden when collapsed)
/// - Nav items: Home, Library, Search, — separator —, Playlists, Favorites
/// - Bottom items: Settings + wide-layout collapse toggle
/// - Active item: accent.withOpacity(0.08) background, icon+label in accent
/// - Items: 48px min height, FocusHighlight on each
class SideNavRail extends ConsumerWidget {
  const SideNavRail({
    super.key,
    required this.expanded,
    this.showToggle = false,
    this.onToggleExpanded,
  });

  final bool expanded;
  final bool showToggle;
  final VoidCallback? onToggleExpanded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sizes = AppSizes.of(context);
    final navWidth = expanded
        ? AppConstants.navRailExpandedWidth
        : sizes.navRailCollapsedWidth;

    final ext = context.appTheme;
    final currentRoute = ref.watch(navigationProvider);
    final l10n = AppLocalizations.of(context)!;

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
          const _NavSeparator(),

          // ── Main items (scrollable when space is tight) ─────────────────
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: false,
              children: [
                _NavItem(
                  icon: LucideIcons.house,
                  label: l10n.navHome,
                  route: '/home',
                  currentRoute: currentRoute,
                  expanded: expanded,
                ),
                _NavItem(
                  icon: LucideIcons.library,
                  label: l10n.navLibrary,
                  route: '/library',
                  currentRoute: currentRoute,
                  expanded: expanded,
                ),
                _NavItem(
                  icon: LucideIcons.search,
                  label: l10n.navSearch,
                  route: '/search',
                  currentRoute: currentRoute,
                  expanded: expanded,
                ),
                const _NavSeparator(),
                _NavItem(
                  icon: LucideIcons.listMusic,
                  label: l10n.navPlaylists,
                  route: '/playlists',
                  currentRoute: currentRoute,
                  expanded: expanded,
                ),
                _NavItem(
                  icon: LucideIcons.heart,
                  label: l10n.navFavorites,
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
            label: l10n.navSettings,
            route: '/settings',
            currentRoute: currentRoute,
            expanded: expanded,
          ),
          if (showToggle && onToggleExpanded != null) ...[
            const _NavSeparator(),
            _NavRailToggleButton(
              expanded: expanded,
              onPressed: onToggleExpanded!,
            ),
          ],
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
    final l10n = AppLocalizations.of(context)!;

    final compact = AppSizes.of(context).isCompact;
    final brandIconSize = compact ? 32.0 : 26.0;
    final brandGap = compact ? 12.0 : 12.0;

    return SizedBox(
      height: compact ? 56.0 : 64.0,
      child: expanded
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.music,
                      size: brandIconSize,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    SizedBox(width: brandGap),
                    Text(
                      l10n.appName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.titleSmall?.copyWith(
                        color: ext.textPrimary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.1,
                        height: 1.0,
                        fontSize: 16
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Center(
              child: Icon(
                LucideIcons.music,
                size: brandIconSize,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
    );
  }
}

class _NavRailToggleButton extends StatefulWidget {
  const _NavRailToggleButton({
    required this.expanded,
    required this.onPressed,
  });

  final bool expanded;
  final VoidCallback onPressed;

  @override
  State<_NavRailToggleButton> createState() => _NavRailToggleButtonState();
}

class _NavRailToggleButtonState extends State<_NavRailToggleButton> {
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

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;
    final sizes = AppSizes.of(context);
    final l10n = AppLocalizations.of(context)!;
    final label = widget.expanded ? l10n.navCollapse : l10n.navExpand;
    final icon = widget.expanded
        ? LucideIcons.chevronsLeft
        : LucideIcons.chevronsRight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Tooltip(
        message: label,
        waitDuration: const Duration(milliseconds: 300),
        child: FocusHighlight(
          focusNode: _focusNode,
          borderRadius: sizes.cardRadiusSm,
          onPressed: widget.onPressed,
          child: GestureDetector(
            onTap: widget.onPressed,
            child: Container(
              constraints: const BoxConstraints(minHeight: 48),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(sizes.cardRadiusSm),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: widget.expanded ? 12 : 0,
              ),
              child: widget.expanded
                  ? Row(
                      children: [
                        Icon(icon, size: 18, color: ext.textSecondary),
                        const SizedBox(width: 12),
                        Text(
                          label,
                          style: tt.bodyMedium?.copyWith(
                            color: ext.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Icon(icon, size: 20, color: ext.textSecondary),
                    ),
            ),
          ),
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
    return widget.currentRoute == widget.route || (widget.route != '/home' && widget.currentRoute.startsWith(widget.route));
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;
    final accent = Theme.of(context).colorScheme.primary;
    final sizes = AppSizes.of(context);

    final iconColor = _isActive ? accent : ext.textSecondary;
    final bgColor = _isActive ? accent.withOpacity(0.08) : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: FocusHighlight(
        focusNode: _focusNode,
        borderRadius: sizes.cardRadiusSm,
        onPressed: () => context.go(widget.route),
        child: GestureDetector(
          onTap: () => context.go(widget.route),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: AppConstants.focusTransitionMs),
            constraints: const BoxConstraints(minHeight: 48),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(sizes.cardRadiusSm),
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
                          fontWeight: _isActive ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Icon(widget.icon, size: 22, color: iconColor),
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
