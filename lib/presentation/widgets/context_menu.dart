import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_theme.dart';

/// True while any app context menu overlay is visible.
final ValueNotifier<bool> contextMenuVisible = ValueNotifier<bool>(false);

/// Increment to request selecting the currently focused context-menu item.
final ValueNotifier<int> contextMenuSelectRequest = ValueNotifier<int>(0);

/// Increment to request dismissing the active context menu.
final ValueNotifier<int> contextMenuDismissRequest = ValueNotifier<int>(0);

void requestContextMenuSelect() {
  contextMenuSelectRequest.value = contextMenuSelectRequest.value + 1;
}

void requestContextMenuDismiss() {
  contextMenuDismissRequest.value = contextMenuDismissRequest.value + 1;
}

// =============================================================================
// Public model
// =============================================================================

/// A single item in an [AppContextMenu].
@immutable
class ContextMenuItem {
  const ContextMenuItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isDangerous = false,
    this.submenu,
  });

  /// Display text.
  final String label;

  /// Lucide icon shown to the left of the label.
  final IconData icon;

  /// Invoked when the item is selected (A button or click).
  final VoidCallback onTap;

  /// When true, the label renders in the error/destructive color.
  final bool isDangerous;

  /// When non-null, pressing A or D-pad right opens this sub-menu.
  final List<ContextMenuItem>? submenu;
}

/// A visual separator that can be inserted between [ContextMenuItem] groups.
@immutable
class ContextMenuSeparator {
  const ContextMenuSeparator();
}

/// Union type accepted as entries by [AppContextMenu].
/// Either a [ContextMenuItem] or a [ContextMenuSeparator].
typedef ContextMenuEntry = Object; // ContextMenuItem | ContextMenuSeparator

// =============================================================================
// AppContextMenu
// =============================================================================

/// Reusable context menu overlay.
///
/// Spec (REQUIREMENTS §6.9):
/// - Width: 240px
/// - Background: bgSurface
/// - Border: 1px borderSubtle
/// - BorderRadius: 12px
/// - Shadow: 0 8px 32px rgba(0,0,0,0.8)
/// - Item height: 40px, padding 0 16px
/// - Icon: 18×18 textSecondary, 12px gap to text
/// - Focus: bgCardHover background
/// - Separator: 1px borderSubtle, margin 4px 0
///
/// Gamepad:
/// - Opens → focus goes to first item
/// - D-pad up/down: navigate items
/// - A: select
/// - B: close
/// - D-pad right / A on item with submenu: opens sub-menu
/// - D-pad left / B in sub-menu: returns to parent
///
/// Show via [showAppContextMenu] helper. It inserts an [OverlayEntry] that
/// the menu removes itself when dismissed.
class AppContextMenu extends StatefulWidget {
  const AppContextMenu({
    super.key,
    required this.entries,
    required this.position,
    required this.onDismiss,
  });

  /// Items and separators to display.
  final List<ContextMenuEntry> entries;

  /// Global position where the menu should appear (typically near the focused
  /// widget or pointer location).
  final Offset position;

  /// Called when the menu should be closed (B button, tap outside, etc.).
  final VoidCallback onDismiss;

  @override
  State<AppContextMenu> createState() => _AppContextMenuState();
}

class _AppContextMenuState extends State<AppContextMenu> with SingleTickerProviderStateMixin {
  static const double _menuWidth = 240;
  static const double _itemHeight = 40;

  late final AnimationController _animController;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  // Focus nodes — one per selectable item (separators excluded)
  late final List<FocusNode> _focusNodes;
  int _focusedIndex = 0;

  // When non-null, the sub-menu for this item index is shown
  int? _openSubmenuIndex;

  late final FocusNode _keyListenerFocusNode;
  int _lastSelectRequest = 0;
  int _lastDismissRequest = 0;

  @override
  void initState() {
    super.initState();
    contextMenuVisible.value = true;
    _keyListenerFocusNode = FocusNode(debugLabel: 'ContextMenu-keyListener');
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppConstants.contextMenuOpenMs),
    );
    _scale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _opacity = CurvedAnimation(parent: _animController, curve: Curves.easeOut);

    final items = _selectableItems;
    _focusNodes = List.generate(items.length, (_) => FocusNode());

    _animController.forward();

    // Capture focus immediately so directional input does not leak to the
    // underlying page while the open animation is still running.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_focusNodes.isNotEmpty) {
        _focusNodes[0].requestFocus();
      } else {
        _keyListenerFocusNode.requestFocus();
      }
    });

    contextMenuSelectRequest.addListener(_handleExternalSelectRequest);
    contextMenuDismissRequest.addListener(_handleExternalDismissRequest);
  }

  @override
  void dispose() {
    contextMenuVisible.value = false;
    contextMenuSelectRequest.removeListener(_handleExternalSelectRequest);
    contextMenuDismissRequest.removeListener(_handleExternalDismissRequest);
    _animController.dispose();
    _keyListenerFocusNode.dispose();
    for (final n in _focusNodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _handleExternalSelectRequest() {
    final next = contextMenuSelectRequest.value;
    if (next == _lastSelectRequest) return;
    _lastSelectRequest = next;
    _selectFocused();
  }

  void _handleExternalDismissRequest() {
    final next = contextMenuDismissRequest.value;
    if (next == _lastDismissRequest) return;
    _lastDismissRequest = next;
    _dismiss();
  }

  List<ContextMenuItem> get _selectableItems => widget.entries.whereType<ContextMenuItem>().toList(growable: false);

  void _dismiss() {
    _animController
        .reverse(
          from: 1.0,
        )
        .then((_) => widget.onDismiss());
  }

  void _moveFocus(int delta) {
    final newIndex = (_focusedIndex + delta).clamp(0, _focusNodes.length - 1);
    if (newIndex != _focusedIndex) {
      setState(() => _focusedIndex = newIndex);
      _focusNodes[newIndex].requestFocus();
    }
  }

  void _selectFocused() {
    if (_focusedIndex < _selectableItems.length) {
      final item = _selectableItems[_focusedIndex];
      if (item.submenu != null) {
        setState(() => _openSubmenuIndex = _focusedIndex);
      } else {
        _dismiss();
        item.onTap();
      }
    }
  }

  KeyEventResult _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final keyName = event.logicalKey.debugName?.toLowerCase() ?? '';
    if (keyName.contains('dpad down') || keyName.contains('d-pad down')) {
      _moveFocus(1);
      return KeyEventResult.handled;
    }
    if (keyName.contains('dpad up') || keyName.contains('d-pad up')) {
      _moveFocus(-1);
      return KeyEventResult.handled;
    }
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowDown:
        _moveFocus(1);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowUp:
        _moveFocus(-1);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.enter:
      case LogicalKeyboardKey.space:
      case LogicalKeyboardKey.gameButtonA:
        _selectFocused();
        return KeyEventResult.handled;
      case LogicalKeyboardKey.escape:
      case LogicalKeyboardKey.gameButtonB:
      case LogicalKeyboardKey.keyB:
        _dismiss();
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowRight:
        final item = _focusedIndex < _selectableItems.length ? _selectableItems[_focusedIndex] : null;
        if (item?.submenu != null) {
          setState(() => _openSubmenuIndex = _focusedIndex);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    // Clamp position so the menu stays on screen
    final screenSize = MediaQuery.sizeOf(context);
    final itemCount = _selectableItems.length;
    final separatorCount = widget.entries.whereType<ContextMenuSeparator>().length;
    final menuHeight = itemCount * _itemHeight + separatorCount * 9.0 + 8; // 8px top+bot padding

    final left = (widget.position.dx + _menuWidth > screenSize.width) ? widget.position.dx - _menuWidth : widget.position.dx;
    final top = (widget.position.dy + menuHeight > screenSize.height) ? widget.position.dy - menuHeight : widget.position.dy;

    return Stack(
      children: [
        // Dismiss barrier
        Positioned.fill(
          child: GestureDetector(
            onTap: _dismiss,
            behavior: HitTestBehavior.opaque,
            child: const ColoredBox(color: Colors.transparent),
          ),
        ),
        // Menu panel
        Positioned(
          left: left,
          top: top,
          child: ScaleTransition(
            scale: _scale,
            alignment: Alignment.topLeft,
            child: FadeTransition(
              opacity: _opacity,
              child: KeyboardListener(
                focusNode: _keyListenerFocusNode,
                onKeyEvent: _handleKey,
                child: _MenuPanel(
                  entries: widget.entries,
                  selectableItems: _selectableItems,
                  focusNodes: _focusNodes,
                  focusedIndex: _focusedIndex,
                  openSubmenuIndex: _openSubmenuIndex,
                  onKeyEvent: _handleKey,
                  onItemFocused: (i) => setState(() => _focusedIndex = i),
                  onItemSelected: (item) {
                    _dismiss();
                    item.onTap();
                  },
                  onSubmenuClose: () => setState(() => _openSubmenuIndex = null),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Internal panel
// =============================================================================

class _MenuPanel extends StatelessWidget {
  const _MenuPanel({
    required this.entries,
    required this.selectableItems,
    required this.focusNodes,
    required this.focusedIndex,
    required this.openSubmenuIndex,
    required this.onKeyEvent,
    required this.onItemFocused,
    required this.onItemSelected,
    required this.onSubmenuClose,
  });

  final List<ContextMenuEntry> entries;
  final List<ContextMenuItem> selectableItems;
  final List<FocusNode> focusNodes;
  final int focusedIndex;
  final int? openSubmenuIndex;
  final KeyEventResult Function(KeyEvent event) onKeyEvent;
  final ValueChanged<int> onItemFocused;
  final ValueChanged<ContextMenuItem> onItemSelected;
  final VoidCallback onSubmenuClose;

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final sizes = AppSizes.of(context);

    int selectableIdx = 0;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 240,
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: ext.bgSurface,
          borderRadius: BorderRadius.circular(sizes.cardRadiusSm),
          border: Border.all(color: ext.borderSubtle),
          boxShadow: const [
            BoxShadow(
              color: Color(0xCC000000),
              blurRadius: 32,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: entries.map((entry) {
            if (entry is ContextMenuSeparator) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: ext.borderSubtle,
                ),
              );
            }
            final item = entry as ContextMenuItem;
            final idx = selectableIdx++;
            return _MenuItem(
              item: item,
              focusNode: focusNodes[idx],
              isFocused: focusedIndex == idx,
              hasOpenSubmenu: openSubmenuIndex == idx,
              onKeyEvent: onKeyEvent,
              onFocused: () => onItemFocused(idx),
              onSelected: () => onItemSelected(item),
            );
          }).toList(growable: false),
        ),
      ),
    );
  }
}

// =============================================================================
// Internal menu item
// =============================================================================

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.item,
    required this.focusNode,
    required this.isFocused,
    required this.hasOpenSubmenu,
    required this.onKeyEvent,
    required this.onFocused,
    required this.onSelected,
  });

  final ContextMenuItem item;
  final FocusNode focusNode;
  final bool isFocused;
  final bool hasOpenSubmenu;
  final KeyEventResult Function(KeyEvent event) onKeyEvent;
  final VoidCallback onFocused;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;

    final textColor = item.isDangerous ? ext.destructive : (isFocused ? ext.textPrimary : ext.textPrimary);
    final iconColor = item.isDangerous ? ext.destructive : ext.textSecondary;
    final bgColor = isFocused ? ext.bgCardHover : Colors.transparent;

    return GestureDetector(
      onTap: onSelected,
      child: Focus(
        focusNode: focusNode,
        onKeyEvent: (node, event) => onKeyEvent(event),
        onFocusChange: (focused) {
          if (focused) onFocused();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          color: bgColor,
          child: Row(
            children: [
              Icon(item.icon, size: 18, color: iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.label,
                  style: tt.bodyMedium?.copyWith(color: textColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (item.submenu != null)
                Icon(
                  LucideIcons.chevronRight,
                  size: 16,
                  color: ext.textTertiary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Helper — show context menu
// =============================================================================

/// Shows [AppContextMenu] at [position] using an [Overlay] entry.
///
/// Returns a future that completes when the menu is dismissed.
Future<void> showAppContextMenu({
  required BuildContext context,
  required Offset position,
  required List<ContextMenuEntry> entries,
}) {
  final completer = Completer<void>();
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (_) => AppContextMenu(
      entries: entries,
      position: position,
      onDismiss: () {
        overlayEntry.remove();
        if (!completer.isCompleted) completer.complete();
      },
    ),
  );

  Overlay.of(context).insert(overlayEntry);
  return completer.future;
}
