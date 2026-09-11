import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/header_sort_dropdown.dart';
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
  @override
  Widget build(BuildContext context) {
    return HeaderSortDropdown(
      height: widget.height,
      value: widget.value,
      ascending: widget.ascending,
      focusDebugLabel: 'LibraryPage-sortDropdown',
      options: widget.options
          .map(
            (option) => HeaderSortOption(
              key: option.$1,
              label: option.$2,
            ),
          )
          .toList(growable: false),
      onChanged: widget.onChanged,
    );
  }
}
