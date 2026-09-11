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
    this.scale = 1.0,
    required super.child,
  });

  /// The height breakpoint (in logical pixels) below which the compact tier
  /// is activated.
  static const double compactBreakpoint = 800.0;

  final DensityTier tier;
  final double scale;

  // ── Tier-switched getters ───────────────────────────────────────────────

  bool get isCompact => tier == DensityTier.compact;

  double _scaled(double value, {double? min, double? max}) {
    final scaledValue = value * scale;
    return scaledValue.clamp(min ?? double.negativeInfinity, max ?? double.infinity);
  }

  // Chrome
  double get titleBarHeight => _scaled(isCompact ? 32.0 : 36.0, min: 32.0);
  double get miniPlayerHeight => _scaled(isCompact ? 72.0 : 84.0, min: 72.0);
  double get buttonHintsHeight => _scaled(isCompact ? 36.0 : 44.0, min: 36.0);

  // Layout
  double get screenEdgePadding => _scaled(isCompact ? 16.0 : 20.0, min: 16.0);
  double get navRailCollapsedWidth => _scaled(isCompact ? 64.0 : 72.0, min: 64.0);
  double get sectionGap => _scaled(isCompact ? 14.0 : 20.0, min: 14.0);
  double get headerContentGap => _scaled(isCompact ? 6.0 : 8.0, min: 6.0);

  // Cards
  double get gridCardWidth => _scaled(isCompact ? 155.0 : 165.0, min: 155.0);
  double get gridCardHeight => _scaled(isCompact ? 170.0 : 210.0, min: 170.0);
  double get gridCardScrollRowWidth => _scaled(isCompact ? 170.0 : 210.0, min: 170.0);
  double get cardRadius => _scaled(isCompact ? 14.0 : 16.0, min: 14.0);
  double get cardRadiusSm => _scaled(isCompact ? 10.0 : 12.0, min: 10.0);
  double get cardPadding => _scaled(isCompact ? 10.0 : 12.0, min: 10.0);

  // Mini player
  double get miniPlayerArtSize => _scaled(isCompact ? 44.0 : 48.0, min: 44.0);
  double get miniPlayerPlayBtnSize => _scaled(isCompact ? 32.0 : 34.0, min: 32.0);

  // Now Playing
  double get nowPlayingArtMinSize => _scaled(isCompact ? 240.0 : 280.0, min: 240.0);
  double get nowPlayingArtMaxSize => _scaled(isCompact ? 420.0 : 500.0, min: 420.0);
  double get nowPlayingArtViewportFraction => (isCompact ? 0.55 : 0.65).clamp(0.55, 0.65);

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
  bool updateShouldNotify(AppSizes oldWidget) =>
      tier != oldWidget.tier || scale != oldWidget.scale;
}
