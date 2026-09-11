import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import 'focus_highlight.dart';

/// Full-screen overlay listing all keyboard / gamepad shortcuts.
///
/// Spec (REQUIREMENTS §6.16 / §4.2 FL-INPUT-*):
/// - Dark semi-opaque backdrop
/// - Centered card: 600×500 (scrollable content if needed), bgSurface
///   background, borderRadius 16, padding 28
/// - Grouped sections: Playback, Navigation, Library
/// - B button / Escape closes overlay
/// - Not created via `showDialog` — callers use [KeyboardShortcutsOverlay]
///   directly inside an [Overlay] or via a [Stack] in the shell.
///
/// Usage:
/// ```dart
/// // Open:
/// setState(() => _showShortcuts = true);
///
/// // Or push route / overlay.
/// ```
class KeyboardShortcutsOverlay extends StatefulWidget {
  const KeyboardShortcutsOverlay({
    super.key,
    required this.onClose,
  });

  final VoidCallback onClose;

  @override
  State<KeyboardShortcutsOverlay> createState() => _KeyboardShortcutsOverlayState();
}

class _KeyboardShortcutsOverlayState extends State<KeyboardShortcutsOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;
  late final FocusNode _keyListenerFocusNode;

  @override
  void initState() {
    super.initState();
    _keyListenerFocusNode = FocusNode(debugLabel: 'ShortcutsOverlay-keyListener');

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _keyListenerFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _keyListenerFocusNode.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await _controller.reverse();
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _keyListenerFocusNode,
      onKeyEvent: (event) {
        if (event is! KeyDownEvent) return;
        if (event.logicalKey == LogicalKeyboardKey.escape ||
            event.logicalKey == LogicalKeyboardKey.gameButtonB ||
            event.logicalKey == LogicalKeyboardKey.keyB) {
          _dismiss();
        }
      },
      child: FadeTransition(
        opacity: _opacity,
        child: GestureDetector(
          onTap: _dismiss,
          child: Container(
            color: Colors.black.withValues(alpha: 0.75),
            alignment: Alignment.center,
            child: ScaleTransition(
              scale: _scale,
              child: GestureDetector(
                // Prevent taps inside the card from closing the overlay
                onTap: () {},
                child: _ShortcutsCard(onClose: _dismiss),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Card body
// =============================================================================

class _ShortcutsCard extends StatelessWidget {
  const _ShortcutsCard({required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;
    final accent = Theme.of(context).colorScheme.primary;

    return Container(
      width: 600,
      height: 500,
      decoration: BoxDecoration(
        color: ext.bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ext.borderSubtle),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Row(
              children: [
                Icon(LucideIcons.keyboard, size: 20, color: accent),
                const SizedBox(width: 10),
                Text(
                  'Keyboard Shortcuts',
                  style: tt.titleMedium?.copyWith(
                    color: ext.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                FocusHighlight(
                  borderRadius: 8,
                  onPressed: onClose,
                  child: GestureDetector(
                    onTap: onClose,
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(LucideIcons.x, size: 18, color: ext.textSecondary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: ext.borderSubtle, height: 1),
          // Scrollable shortcut list
          const Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ShortcutGroup(
                    title: 'Playback',
                    items: [
                      _ShortcutEntry(key_: 'Space / Start', desc: 'Play / Pause'),
                      _ShortcutEntry(key_: 'Right Arrow / RB', desc: 'Next track'),
                      _ShortcutEntry(key_: 'Left Arrow / LB', desc: 'Previous track'),
                      _ShortcutEntry(key_: 'Right Stick ←→', desc: 'Seek current track'),
                      _ShortcutEntry(key_: 'RT / Volume Up', desc: 'Volume up'),
                      _ShortcutEntry(key_: 'LT / Volume Down', desc: 'Volume down'),
                      _ShortcutEntry(key_: 'M', desc: 'Toggle mute'),
                      _ShortcutEntry(key_: 'S', desc: 'Toggle shuffle'),
                      _ShortcutEntry(key_: 'R', desc: 'Cycle repeat mode'),
                    ],
                  ),
                  SizedBox(height: 24),
                  _ShortcutGroup(
                    title: 'Navigation',
                    items: [
                      _ShortcutEntry(key_: 'D-Pad / Arrow Keys', desc: 'Move focus'),
                      _ShortcutEntry(key_: 'A / Enter', desc: 'Select / Confirm'),
                      _ShortcutEntry(key_: 'B / Escape / Backspace', desc: 'Back / Cancel'),
                      _ShortcutEntry(key_: 'X / Application Key', desc: 'Context menu'),
                      _ShortcutEntry(key_: 'Y', desc: 'Toggle favorite'),
                      _ShortcutEntry(key_: 'Back / Ctrl+F', desc: 'Open search'),
                      _ShortcutEntry(key_: 'LB / RB', desc: 'Switch tabs in tabbed views'),
                    ],
                  ),
                  SizedBox(height: 24),
                  _ShortcutGroup(
                    title: 'Library',
                    items: [
                      _ShortcutEntry(key_: 'Ctrl+Shift+L', desc: 'Rescan library'),
                      _ShortcutEntry(key_: 'Ctrl+Q', desc: 'View queue'),
                      _ShortcutEntry(key_: '?', desc: 'Show this overlay'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Footer hint
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: ext.bgCard,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: ext.borderSubtle),
                  ),
                  child: Text('B  /  Esc', style: tt.bodySmall?.copyWith(color: ext.textSecondary)),
                ),
                const SizedBox(width: 8),
                Text('to close', style: tt.bodySmall?.copyWith(color: ext.textTertiary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Shortcut group
// =============================================================================

class _ShortcutGroup extends StatelessWidget {
  const _ShortcutGroup({required this.title, required this.items});

  final String title;
  final List<_ShortcutEntry> items;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: tt.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        ...items,
      ],
    );
  }
}

// =============================================================================
// Single shortcut entry row
// =============================================================================

class _ShortcutEntry extends StatelessWidget {
  const _ShortcutEntry({required this.key_, required this.desc});

  final String key_;
  final String desc;

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          _KeyChip(label: key_),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              desc,
              style: tt.bodyMedium?.copyWith(color: ext.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _KeyChip extends StatelessWidget {
  const _KeyChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      constraints: const BoxConstraints(minWidth: 130),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: ext.bgCard,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: ext.borderCard),
      ),
      child: Text(
        label,
        style: tt.labelSmall?.copyWith(
          color: ext.textPrimary,
          fontFamily: 'monospace',
        ),
        maxLines: 1,
      ),
    );
  }
}
