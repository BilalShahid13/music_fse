import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';

import 'queue_panel.dart';

class QueueDrawer extends StatefulWidget {
  const QueueDrawer({
    super.key,
    required this.isOpen,
    required this.onDismiss,
  });

  final bool isOpen;
  final VoidCallback onDismiss;

  @override
  State<QueueDrawer> createState() => _QueueDrawerState();
}

class _QueueDrawerState extends State<QueueDrawer> {
  bool _keepMounted = false;
  int _closeAnimationToken = 0;

  @override
  void initState() {
    super.initState();
    _keepMounted = widget.isOpen;
  }

  @override
  void didUpdateWidget(covariant QueueDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isOpen) {
      _closeAnimationToken += 1;
      if (!_keepMounted) {
        setState(() => _keepMounted = true);
      }
      return;
    }

    if (!oldWidget.isOpen || !_keepMounted) {
      return;
    }

    final closeAnimationToken = ++_closeAnimationToken;
    Future<void>.delayed(
      const Duration(milliseconds: AppConstants.queueSlideMs),
      () {
        if (!mounted || widget.isOpen || closeAnimationToken != _closeAnimationToken) {
          return;
        }
        setState(() => _keepMounted = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_keepMounted && !widget.isOpen) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !widget.isOpen,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: AppConstants.queueSlideMs),
              curve: Curves.easeOut,
              opacity: widget.isOpen ? 1 : 0,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: widget.onDismiss,
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.18),
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: IgnorePointer(
            ignoring: !widget.isOpen,
            child: ExcludeFocus(
              excluding: !widget.isOpen,
              child: ExcludeSemantics(
                excluding: !widget.isOpen,
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: AppConstants.queueSlideMs),
                  curve: Curves.easeOut,
                  offset: widget.isOpen ? Offset.zero : const Offset(1, 0),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: AppConstants.queueSlideMs),
                    curve: Curves.easeOut,
                    opacity: widget.isOpen ? 1 : 0,
                    child: QueuePanel(onDismiss: widget.onDismiss),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
