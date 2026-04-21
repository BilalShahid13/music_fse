import 'package:flutter/widgets.dart';

/// Height-responsive density tier.
///
/// [standard] — Desktop / laptop (screen height ≥ 800 lp).
/// [compact]  — Handheld / small window (screen height < 800 lp).
enum DensityTier { standard, compact }

/// Height-responsive layout sizes.
///
/// Placed once in the widget tree (inside [MusicFseApp.build], wrapping the
/// [MaterialApp.router]). Every descendant reads values via:
///
///     final sizes = AppSizes.of(context);
///     sizes.miniPlayerHeight  // → 84.0 on desktop, 72.0 on handheld
///
/// Only the ~20 properties that differ between tiers live here.
/// All fixed constants (animation durations, focusable minimums, font sizes,
/// dialog sizes, etc.) remain in [AppConstants] and are NOT duplicated.
class AppSizes extends InheritedWidget {
  const AppSizes({
    super.key,
    required this.tier,
    required super.child,
  });

  /// The height breakpoint (in logical pixels) below which the compact tier
  /// is activated.
  static const double compactBreakpoint = 800.0;

  final DensityTier tier;

  // ── Tier-switched getters ───────────────────────────────────────────────

  bool get isCompact => tier == DensityTier.compact;

  // Chrome
  double get titleBarHeight => isCompact ? 32.0 : 36.0;
  double get miniPlayerHeight => isCompact ? 72.0 : 84.0;
  double get buttonHintsHeight => isCompact ? 36.0 : 44.0;

  // Layout
  double get screenEdgePadding => isCompact ? 16.0 : 20.0;
  double get navRailCollapsedWidth => isCompact ? 64.0 : 72.0;
  double get sectionGap => isCompact ? 14.0 : 20.0;
  double get headerContentGap => isCompact ? 6.0 : 8.0;

  // Cards
  double get gridCardWidth => isCompact ? 155.0 : 165.0;
  double get gridCardHeight => isCompact ? 170.0 : 210.0;
  double get gridCardScrollRowWidth => isCompact ? 170.0 : 210.0;
  double get cardRadius => isCompact ? 14.0 : 16.0;
  double get cardRadiusSm => isCompact ? 10.0 : 12.0;
  double get cardPadding => isCompact ? 10.0 : 12.0;

  // Mini player
  double get miniPlayerArtSize => isCompact ? 44.0 : 48.0;
  double get miniPlayerPlayBtnSize => isCompact ? 32.0 : 34.0;

  // Now Playing
  double get nowPlayingArtMinSize => isCompact ? 240.0 : 280.0;
  double get nowPlayingArtMaxSize => isCompact ? 420.0 : 500.0;
  double get nowPlayingArtViewportFraction => isCompact ? 0.55 : 0.65;

  // ── InheritedWidget boilerplate ─────────────────────────────────────────

  static AppSizes of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<AppSizes>();
    assert(result != null, 'No AppSizes found in context');
    return result!;
  }

  /// Non-rebuilding access (for callbacks / layout code that shouldn't trigger
  /// a dependency on the InheritedWidget).
  static AppSizes read(BuildContext context) {
    final result = context.getInheritedWidgetOfExactType<AppSizes>();
    assert(result != null, 'No AppSizes found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(AppSizes oldWidget) => tier != oldWidget.tier;
}
