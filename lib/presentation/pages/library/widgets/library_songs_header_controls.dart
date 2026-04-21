import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/focus_highlight.dart';

class LibrarySongsSelectModeButton extends StatelessWidget {
  const LibrarySongsSelectModeButton({
    super.key,
    required this.height,
    required this.isActive,
    required this.onPressed,
    this.countLabel,
  });

  final double height;
  final bool isActive;
  final VoidCallback onPressed;
  final String? countLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ext = context.appTheme;
    final accent = Theme.of(context).colorScheme.primary;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          height: AppConstants.minFocusableSize,
          child: Center(
            child: FocusHighlight(
              borderRadius: AppConstants.btnRadius,
              onPressed: onPressed,
              child: GestureDetector(
                onTap: onPressed,
                child: Container(
                  height: height,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: isActive ? accent.withValues(alpha: 0.16) : ext.bgCard,
                    borderRadius: BorderRadius.circular(AppConstants.btnRadius),
                    border: Border.all(
                      color: isActive ? accent : ext.borderSubtle,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isActive ? LucideIcons.x : LucideIcons.square,
                        size: 18,
                        color: isActive ? accent : ext.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isActive ? l10n.cancel : l10n.hintSelect,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isActive ? accent : ext.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (countLabel != null)
          Positioned(
            right: 4,
            bottom: AppConstants.minFocusableSize + 4,
            child: Text(
              countLabel!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: ext.textTertiary,
                  ),
            ),
          ),
      ],
    );
  }
}

class LibrarySongsSortDropdown extends StatefulWidget {
  const LibrarySongsSortDropdown({
    super.key,
    required this.height,
    required this.value,
    required this.options,
    required this.ascending,
    required this.onChanged,
  });

  final double height;
  final String value;
  final List<(String, String)> options;
  final bool ascending;
  final void Function(String key, bool ascending) onChanged;

  @override
  State<LibrarySongsSortDropdown> createState() => _LibrarySongsSortDropdownState();
}

class _LibrarySongsSortDropdownState extends State<LibrarySongsSortDropdown> {
  late final FocusNode _focusNode;
  final GlobalKey<PopupMenuButtonState<String>> _menuKey = GlobalKey<PopupMenuButtonState<String>>();

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(debugLabel: 'LibraryPage-sortDropdown');
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _openMenu() {
    _menuKey.currentState?.showButtonMenu();
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;
    final accent = Theme.of(context).colorScheme.primary;
    final sizes = AppSizes.of(context);

    final currentLabel = widget.options.firstWhere((o) => o.$1 == widget.value, orElse: () => widget.options.first).$2;

    return SizedBox(
      height: AppConstants.minFocusableSize,
      child: Center(
        child: FocusHighlight(
          focusNode: _focusNode,
          borderRadius: AppConstants.btnRadius,
          onPressed: _openMenu,
          child: PopupMenuButton<String>(
            key: _menuKey,
            initialValue: widget.value,
            tooltip: 'Sort',
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(sizes.cardRadiusSm),
            ),
            color: ext.bgSurface,
            onSelected: (key) {
              if (key == widget.value) {
                widget.onChanged(key, !widget.ascending);
              } else {
                widget.onChanged(key, true);
              }
            },
            itemBuilder: (_) => widget.options
                .map(
                  (o) => PopupMenuItem<String>(
                    value: o.$1,
                    child: Row(
                      children: [
                        if (o.$1 == widget.value) ...[
                          Icon(
                            widget.ascending ? LucideIcons.arrowUp : LucideIcons.arrowDown,
                            size: 14,
                            color: accent,
                          ),
                          const SizedBox(width: 6),
                        ] else
                          const SizedBox(width: 20),
                        Text(
                          o.$2,
                          style: tt.bodyMedium?.copyWith(
                            color: o.$1 == widget.value ? accent : ext.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
            child: Container(
              height: widget.height,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: ext.bgInput,
                borderRadius: BorderRadius.circular(AppConstants.btnRadius),
                border: Border.all(color: ext.borderSubtle),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.arrowUpDown, size: 14, color: ext.textTertiary),
                  const SizedBox(width: 6),
                  Text(currentLabel, style: tt.bodySmall?.copyWith(color: ext.textSecondary)),
                  const SizedBox(width: 4),
                  Icon(
                    widget.ascending ? LucideIcons.arrowUp : LucideIcons.arrowDown,
                    size: 12,
                    color: ext.textTertiary,
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
