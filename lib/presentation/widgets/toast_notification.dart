import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_theme.dart';
import '../providers/toast_provider.dart';

/// Persistent overlay that shows toast notifications driven by
/// [ToastNotifier].
///
/// Spec (REQUIREMENTS §6.11 / §4.6):
/// - Position: bottom-center, above the mini player + button hints bar
/// - Background: bgCard with 1px borderSubtle
/// - BorderRadius: 12px
/// - Padding: 12px 20px
/// - Max width: 400px
/// - Entry: slide-up 200ms + fade-in
/// - Exit: fade-out 150ms
/// - Non-focusable — never steals gamepad/keyboard focus
///
/// Embed this widget in the shell scaffold stack above the mini player area.
/// It listens to [toastProvider] directly.
class ToastNotificationOverlay extends ConsumerStatefulWidget {
  const ToastNotificationOverlay({super.key});

  @override
  ConsumerState<ToastNotificationOverlay> createState() =>
      _ToastNotificationOverlayState();
}

class _ToastNotificationOverlayState
    extends ConsumerState<ToastNotificationOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  ToastData? _current;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this)
      ..addStatusListener(_onAnimationStatus);

    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.dismissed) {
      if (mounted) setState(() => _current = null);
    }
  }

  void _show(ToastData data) {
    setState(() => _current = data);
    _controller.duration =
        const Duration(milliseconds: AppConstants.toastSlideInMs);
    _controller.forward(from: 0);
  }

  void _dismiss() {
    _controller.duration =
        const Duration(milliseconds: AppConstants.toastFadeOutMs);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    // React to provider changes (new toast or null = dismiss)
    ref.listen<ToastData?>(toastProvider, (prev, next) {
      if (next == null) {
        _dismiss();
      } else {
        _show(next);
      }
    });

    if (_current == null) return const SizedBox.shrink();

    return Positioned(
      left: 0,
      right: 0,
      // Sits above mini player + button hints
      bottom: AppSizes.of(context).miniPlayerHeight + AppSizes.of(context).buttonHintsHeight + 12,
      child: ExcludeFocus(
        child: IgnorePointer(
          ignoring: false, // Undo button should still be tappable
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: SlideTransition(
                position: _slide,
                child: FadeTransition(
                  opacity: _opacity,
                  child: _ToastCard(data: _current!),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Internal card widget
// ---------------------------------------------------------------------------

class _ToastCard extends StatelessWidget {
  const _ToastCard({required this.data});

  final ToastData data;

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;
    final accent = Theme.of(context).colorScheme.primary;
    final sizes = AppSizes.of(context);
    final textColor =
        data.isError ? ext.destructive : ext.textPrimary;

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: ext.bgCard,
          borderRadius:
              BorderRadius.circular(sizes.cardRadiusSm),
          border: Border.all(color: ext.borderSubtle),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                data.message,
                style: tt.bodyMedium?.copyWith(color: textColor),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (data.hasUndo) ...[
              const SizedBox(width: 12),
              TextButton(
                onPressed: data.undoAction,
                style: TextButton.styleFrom(
                  foregroundColor: accent,
                  minimumSize: const Size(48, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: Text(
                  data.undoLabel ?? 'Undo',
                  style: tt.labelMedium?.copyWith(color: accent),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
