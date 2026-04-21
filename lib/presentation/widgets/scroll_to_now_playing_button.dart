import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A floating action button that appears in song list screens when the
/// currently playing song is off-screen.
///
/// Spec (REQUIREMENTS §6.17):
/// - 36×36 circle, accent background, Lucide `arrowDown` icon
/// - Positioned bottom-right with 16px margin from the list edges
/// - Visible only when [isVisible] is true; animates in/out (scale + fade)
/// - Non-focusable via gamepad (it is a convenience mouse/touch hint)
///   because the playing song will always be reachable via D-pad scroll
///
/// Callers should track whether the current song is visible in the list
/// (using a [ScrollController] and [Scrollable.ensureVisible]) and toggle
/// [isVisible] accordingly.
class ScrollToNowPlayingButton extends StatelessWidget {
  const ScrollToNowPlayingButton({
    super.key,
    required this.onTap,
    required this.isVisible,
  });

  final VoidCallback onTap;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: AnimatedScale(
        scale: isVisible ? 1.0 : 0.7,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: IgnorePointer(
          ignoring: !isVisible,
          child: ExcludeFocus(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: accent.withOpacity(0.35),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      LucideIcons.arrowDown,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
