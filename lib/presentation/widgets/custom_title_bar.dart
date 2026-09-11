import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_theme.dart';
import '../pages/dialogs/close_to_tray_dialog.dart';
import '../providers/settings_provider.dart';

/// Custom title bar replacing the OS native title bar.
///
/// Spec (REQUIREMENTS §6.14 / CLAUDE.md §6.1):
/// - Height: 36px (AppConstants.titleBarHeight)
/// - bgDeep background matching the active app theme
/// - Left: 20×20 app icon + "Music FSE" label (label only at ≥1200px)
/// - Right: Minimize (46×36) → Maximize/Restore (46×36) → Close (46×36)
/// - Entire bar acts as a drag region except the three window control buttons
///
/// Not focusable via gamepad (title bar buttons are mouse-only per spec).
class CustomTitleBar extends ConsumerStatefulWidget {
  const CustomTitleBar({super.key});

  @override
  ConsumerState<CustomTitleBar> createState() => _CustomTitleBarState();
}

class _CustomTitleBarState extends ConsumerState<CustomTitleBar> with WindowListener {
  bool _isMaximized = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _syncMaximized();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  Future<void> _syncMaximized() async {
    final isMax = await windowManager.isMaximized();
    if (mounted) setState(() => _isMaximized = isMax);
  }

  Future<void> _handleClose() async {
    final prompted = ref.read(closeToTrayPromptedProvider).value ?? false;
    final closeToTray = ref.read(closeToTrayProvider).value ?? true;

    if (!prompted) {
      final result = await showDialog<({bool minimize, bool remember})>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const CloseToTrayDialog(),
      );
      if (result == null) return;

      if (result.remember) {
        await ref.read(closeToTrayProvider.notifier).set(result.minimize);
        await ref.read(closeToTrayPromptedProvider.notifier).set(true);
      }
      if (result.minimize) {
        await windowManager.hide();
      } else {
        await windowManager.destroy();
      }
    } else if (closeToTray) {
      await windowManager.hide();
    } else {
      await windowManager.destroy();
    }
  }

  @override
  void onWindowMaximize() => setState(() => _isMaximized = true);

  @override
  void onWindowUnmaximize() => setState(() => _isMaximized = false);

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);
    final ext = context.appTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: ext.bgDeep,
        border: Border(
          bottom: BorderSide(color: ext.borderSubtle),
        ),
      ),
      child: SizedBox(
        height: sizes.titleBarHeight,
        child: Row(
          children: [
            // ── Drag region + left identity ─────────────────────────────────
            const Expanded(
              child: DragToMoveArea(child: SizedBox.expand()),
            ),

            // ── Window controls ─────────────────────────────────────────────
            _WindowButton(
              icon: LucideIcons.minus,
              onPressed: windowManager.minimize,
              isCompact: sizes.isCompact,
            ),
            _WindowButton(
              icon: _isMaximized ? LucideIcons.minimize2 : LucideIcons.maximize2,
              isCompact: sizes.isCompact,
              onPressed: () async {
                if (_isMaximized) {
                  await windowManager.unmaximize();
                } else {
                  await windowManager.maximize();
                }
              },
            ),
            _CloseButton(onTap: _handleClose, isCompact: sizes.isCompact),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Window control button (non-close)
// =============================================================================

class _WindowButton extends StatelessWidget {
  const _WindowButton({
    required this.icon,
    required this.onPressed,
    this.isCompact = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final sizes = AppSizes.of(context);
    final btnWidth = isCompact ? 42.0 : 46.0;
    final iconSize = isCompact ? 12.0 : 14.0;

    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: btnWidth,
        height: sizes.titleBarHeight,
        color: Colors.transparent,
        child: Center(
          child: Icon(icon, size: iconSize, color: ext.textSecondary),
        ),
      ),
    );
  }
}

// =============================================================================
// Close button
// =============================================================================

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap, this.isCompact = false});

  final VoidCallback onTap;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final sizes = AppSizes.of(context);
    final btnWidth = isCompact ? 42.0 : 46.0;
    final iconSize = isCompact ? 12.0 : 14.0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: btnWidth,
        height: sizes.titleBarHeight,
        color: Colors.transparent,
        child: Center(
          child: Icon(LucideIcons.x, size: iconSize, color: ext.textSecondary),
        ),
      ),
    );
  }
}
