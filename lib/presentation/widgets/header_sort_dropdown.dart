import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import 'focus_highlight.dart';

class HeaderMenuButton<T> extends StatefulWidget {
  const HeaderMenuButton({
    super.key,
    required this.itemBuilder,
    required this.onSelected,
    required this.child,
    this.initialValue,
    this.height = 38.0,
    this.tooltip = 'Menu',
    this.focusDebugLabel,
    this.focusNode,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
  });

  final PopupMenuItemBuilder<T> itemBuilder;
  final PopupMenuItemSelected<T> onSelected;
  final Widget child;
  final T? initialValue;
  final double height;
  final String tooltip;
  final String? focusDebugLabel;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry padding;

  @override
  State<HeaderMenuButton<T>> createState() => _HeaderMenuButtonState<T>();
}

class _HeaderMenuButtonState<T> extends State<HeaderMenuButton<T>> {
  late final FocusNode _focusNode;
  final GlobalKey<PopupMenuButtonState<T>> _menuKey =
      GlobalKey<PopupMenuButtonState<T>>();

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode(debugLabel: widget.focusDebugLabel);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _openMenu() {
    _menuKey.currentState?.showButtonMenu();
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;

    return SizedBox(
      height: AppConstants.minFocusableSize,
      child: Center(
        child: FocusHighlight(
          focusNode: _focusNode,
          borderRadius: AppConstants.btnRadius,
          onPressed: _openMenu,
          child: PopupMenuButton<T>(
            key: _menuKey,
            initialValue: widget.initialValue,
            tooltip: widget.tooltip,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.btnRadius),
            ),
            color: ext.bgSurface,
            onSelected: widget.onSelected,
            itemBuilder: widget.itemBuilder,
            child: Container(
              height: widget.height,
              padding: widget.padding,
              decoration: BoxDecoration(
                color: ext.bgInput,
                borderRadius: BorderRadius.circular(AppConstants.btnRadius),
                border: Border.all(color: ext.borderSubtle),
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

class HeaderSortOption {
  const HeaderSortOption({
    required this.key,
    required this.label,
    this.defaultAscending = true,
  });

  final String key;
  final String label;
  final bool defaultAscending;
}

class HeaderSortDropdown extends StatefulWidget {
  const HeaderSortDropdown({
    super.key,
    required this.value,
    required this.options,
    required this.ascending,
    required this.onChanged,
    this.height = 38.0,
    this.tooltip = 'Sort',
    this.focusDebugLabel,
  });

  final String value;
  final List<HeaderSortOption> options;
  final bool ascending;
  final void Function(String key, bool ascending) onChanged;
  final double height;
  final String tooltip;
  final String? focusDebugLabel;

  @override
  State<HeaderSortDropdown> createState() => _HeaderSortDropdownState();
}

class _HeaderSortDropdownState extends State<HeaderSortDropdown> {
  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;
    final accent = Theme.of(context).colorScheme.primary;

    final currentOption = widget.options.firstWhere(
      (option) => option.key == widget.value,
      orElse: () => widget.options.first,
    );

    return HeaderMenuButton<String>(
      initialValue: widget.value,
      tooltip: widget.tooltip,
      focusDebugLabel: widget.focusDebugLabel,
      onSelected: (key) {
        final selectedOption = widget.options.firstWhere(
          (option) => option.key == key,
          orElse: () => widget.options.first,
        );
        final nextAscending = key == widget.value
            ? !widget.ascending
            : selectedOption.defaultAscending;
        widget.onChanged(key, nextAscending);
      },
      itemBuilder: (_) => widget.options
          .map(
            (option) => PopupMenuItem<String>(
              value: option.key,
              child: Row(
                children: [
                  if (option.key == widget.value) ...[
                    Icon(
                      widget.ascending
                          ? LucideIcons.arrowUp
                          : LucideIcons.arrowDown,
                      size: 14,
                      color: accent,
                    ),
                    const SizedBox(width: 6),
                  ] else
                    const SizedBox(width: 20),
                  Text(
                    option.label,
                    style: tt.bodyMedium?.copyWith(
                      color: option.key == widget.value
                          ? accent
                          : ext.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(growable: false),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.arrowUpDown,
            size: 14,
            color: ext.textTertiary,
          ),
          const SizedBox(width: 6),
          Text(
            currentOption.label,
            style: tt.bodySmall?.copyWith(color: ext.textSecondary),
          ),
          const SizedBox(width: 4),
          Icon(
            widget.ascending
                ? LucideIcons.arrowUp
                : LucideIcons.arrowDown,
            size: 12,
            color: ext.textTertiary,
          ),
        ],
      ),
    );
  }
}