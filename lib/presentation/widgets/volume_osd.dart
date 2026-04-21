import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_theme.dart';

/// On-screen volume indicator shown when volume changes via gamepad triggers.
///
/// Spec (REQUIREMENTS §6.12):
/// - Position: top-right corner, 24px margin
/// - Background: bgSurface at 80% opacity, borderRadius 12px
/// - Content: volume icon + horizontal fill bar + percentage text
/// - Width: ~200px, height: ~44px
/// - Auto-dismiss: 1.5 seconds after the last volume change
/// - Entry/exit: 150ms fade
///
/// Usage: embed this widget in the shell scaffold's stack. Call [show] from
/// the playback controller whenever volume is changed via LT/RT.
class VolumeOsd extends StatefulWidget {
  const VolumeOsd({super.key});

  @override
  State<VolumeOsd> createState() => VolumeOsdState();
}

class VolumeOsdState extends State<VolumeOsd>
    with SingleTickerProviderStateMixin {
  static const Duration _autoDismissDelay = Duration(milliseconds: 1500);
  static const Duration _fadeDuration = Duration(milliseconds: 150);

  late final AnimationController _controller;
  late final Animation<double> _opacity;

  Timer? _dismissTimer;
  double _volume = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _fadeDuration);
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// Call this whenever the volume changes (e.g. from the playback provider).
  void show(double volume) {
    setState(() => _volume = volume.clamp(0.0, 1.0));
    _controller.forward();
    _dismissTimer?.cancel();
    _dismissTimer = Timer(_autoDismissDelay, () {
      if (mounted) _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;
    final accent = Theme.of(context).colorScheme.primary;
    final sizes = AppSizes.of(context);

    final icon = _volume == 0
        ? LucideIcons.volumeX
        : _volume < 0.4
            ? LucideIcons.volume1
            : LucideIcons.volume2;

    return Positioned(
      top: AppSizes.of(context).titleBarHeight + 24,
      right: 24,
      child: FadeTransition(
        opacity: _opacity,
        child: IgnorePointer(
          child: ExcludeFocus(
            child: Container(
              width: 200,
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: ext.bgSurface.withOpacity(0.9),
                borderRadius:
                    BorderRadius.circular(sizes.cardRadiusSm),
                border: Border.all(color: ext.borderSubtle),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 18, color: ext.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: _volume,
                        backgroundColor: ext.bgInput,
                        valueColor: AlwaysStoppedAnimation<Color>(accent),
                        minHeight: 4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 32,
                    child: Text(
                      '${(_volume * 100).round()}%',
                      style: tt.labelSmall?.copyWith(
                        color: ext.textSecondary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
