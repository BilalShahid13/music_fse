import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_enums.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/focus_highlight.dart';
import '../../widgets/settings_popup_registry.dart';

/// Predefined accent color swatches available to the user.
///
/// Each entry is (label, color). These are shown as a grid of colored chips.
const List<(String, Color)> kAccentColorOptions = [
  ('Orange', Color(0xFFC76E00)),
  ('Blue', Color(0xFF2196F3)),
  ('Green', Color(0xFF4CAF50)),
  ('Red', Color(0xFFE53935)),
  ('Purple', Color(0xFF9C27B0)),
  ('Pink', Color(0xFFE91E63)),
  ('Teal', Color(0xFF009688)),
  ('Yellow', Color(0xFFFFC107)),
  ('Indigo', Color(0xFF3F51B5)),
  ('Cyan', Color(0xFF00BCD4)),
  ('Lime', Color(0xFF8BC34A)),
  ('Amber', Color(0xFFFF8F00)),
];

/// Dialog for selecting an accent color.
///
/// Spec (REQUIREMENTS §7.17):
/// - Width: 380px, bgSurface, borderRadius 16px, padding 24px
/// - 12-color grid of chips (28×28 each, 4 columns, 8px gap)
/// - Selected chip: white checkmark icon overlay
/// - Custom hex input field below the grid
/// - Confirm (accent) + Cancel buttons
///
/// Returns the selected [Color], or null if cancelled.
///
/// Usage:
/// ```dart
/// final selection = await showColorPickerDialog(
///   context,
///   initial: Theme.of(context).colorScheme.primary,
/// );
/// if (selection != null) { /* apply */ }
/// ```
Future<AccentColorSelection?> showColorPickerDialog(
  BuildContext context, {
  required Color initial,
  required AccentTextColorSetting initialTextColor,
}) {
  return showDialog<AccentColorSelection>(
    context: context,
    barrierDismissible: true,
    traversalEdgeBehavior: TraversalEdgeBehavior.closedLoop,
    builder: (_) => _ColorPickerDialog(
      initial: initial,
      initialTextColor: initialTextColor,
    ),
  );
}

final class AccentColorSelection {
  const AccentColorSelection({
    required this.color,
    required this.textColor,
  });

  final Color color;
  final AccentTextColorSetting textColor;
}

// ---------------------------------------------------------------------------
// Implementation
// ---------------------------------------------------------------------------

class _ColorPickerDialog extends StatefulWidget {
  const _ColorPickerDialog({
    required this.initial,
    required this.initialTextColor,
  });
  final Color initial;
  final AccentTextColorSetting initialTextColor;

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late Color _selected;
  late AccentTextColorSetting _textColor;
  late final TextEditingController _hexController;
  late final List<FocusNode> _chipFocusNodes;
  late final List<FocusNode> _textColorFocusNodes;
  late final FocusNode _hexFocus;
  late final FocusNode _cancelFocus;
  late final FocusNode _applyFocus;
  String? _hexError;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
    _textColor = widget.initialTextColor;
    _hexController = TextEditingController(text: _colorToHex(widget.initial));
    _chipFocusNodes = List<FocusNode>.generate(
      kAccentColorOptions.length,
      (index) => FocusNode(debugLabel: 'ColorPicker-chip-$index'),
    );
    _textColorFocusNodes = List<FocusNode>.generate(
      AccentTextColorSetting.values.length,
      (index) => FocusNode(debugLabel: 'ColorPicker-textColor-$index'),
    );
    _hexFocus = FocusNode(debugLabel: 'ColorPicker-hex');
    _cancelFocus = FocusNode(debugLabel: 'ColorPicker-cancel');
    _applyFocus = FocusNode(debugLabel: 'ColorPicker-apply');
    settingsColorPopupDismiss.value = _dismissDialog;
    settingsColorPopupVisible.value = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focusSelectedChip();
    });
  }

  @override
  void dispose() {
    _closePopupState();
    _hexController.dispose();
    for (final node in _chipFocusNodes) {
      node.dispose();
    }
    for (final node in _textColorFocusNodes) {
      node.dispose();
    }
    _hexFocus.dispose();
    _cancelFocus.dispose();
    _applyFocus.dispose();
    super.dispose();
  }

  void _dismissDialog() {
    Navigator.of(context, rootNavigator: true).maybePop();
  }

  void _closePopupState() {
    settingsColorPopupVisible.value = false;
    if (identical(settingsColorPopupDismiss.value, _dismissDialog)) {
      settingsColorPopupDismiss.value = null;
    }
  }

  void _focusSelectedChip() {
    final selectedIndex = kAccentColorOptions.indexWhere((option) => option.$2.toARGB32() == _selected.toARGB32());
    final targetIndex = selectedIndex >= 0 ? selectedIndex : 0;
    _chipFocusNodes[targetIndex].requestFocus();
  }

  String _colorToHex(Color c) => '#${c.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

  Color? _parseHex(String input) {
    final clean = input.replaceAll('#', '').trim();
    if (clean.length == 6) {
      final value = int.tryParse('FF$clean', radix: 16);
      if (value != null) return Color(value);
    }
    return null;
  }

  void _onHexChanged(String value) {
    final parsed = _parseHex(value);
    setState(() {
      if (parsed != null) {
        _selected = parsed;
        _hexError = null;
      } else {
        _hexError = value.isEmpty ? null : 'Invalid hex color';
      }
    });
  }

  KeyEventResult _handleKey(FocusNode _, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape || event.logicalKey == LogicalKeyboardKey.gameButtonB) {
      Navigator.of(context).pop();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _focusHexNeighbors(TraversalDirection direction) {
    if (direction == TraversalDirection.down) {
      _textColorFocusNodes[_textColor.index].requestFocus();
      return;
    }
    _focusSelectedChip();
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;
    final sizes = AppSizes.of(context);
    final accent = Theme.of(context).colorScheme.primary;
    final l10n = AppLocalizations.of(context)!;
    final previewForeground = AppTheme.resolveOnAccentColor(_selected, _textColor);
    final textColorOptions = [
      (AccentTextColorSetting.auto, l10n.accentTextColorAuto),
      (AccentTextColorSetting.dark, l10n.themeDark),
      (AccentTextColorSetting.light, l10n.themeLight),
    ];

    return Focus(
      autofocus: true,
      skipTraversal: true,
      onKeyEvent: _handleKey,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: FocusTraversalGroup(
          policy: OrderedTraversalPolicy(),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppConstants.dialogWidth),
            child: Container(
              decoration: BoxDecoration(
                color: ext.bgSurface,
                borderRadius: BorderRadius.circular(sizes.cardRadius),
                border: Border.all(color: ext.borderSubtle),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xCC000000),
                    blurRadius: 32,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(AppConstants.dialogPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.accentColor,
                    style: tt.titleLarge?.copyWith(color: ext.textPrimary),
                  ),
                  const SizedBox(height: 20),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1,
                    ),
                    itemCount: kAccentColorOptions.length,
                    itemBuilder: (context, index) {
                      final (label, color) = kAccentColorOptions[index];
                      final isSelected = _selected.toARGB32() == color.toARGB32();
                      return FocusTraversalOrder(
                        order: NumericFocusOrder(index.toDouble()),
                        child: _ColorChip(
                          color: color,
                          label: label,
                          isSelected: isSelected,
                          focusNode: _chipFocusNodes[index],
                          onTap: () {
                            setState(() {
                              _selected = color;
                              _hexController.text = _colorToHex(color);
                              _hexError = null;
                            });
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  FocusTraversalOrder(
                    order: const NumericFocusOrder(100),
                    child: CallbackShortcuts(
                      bindings: {
                        const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
                            _focusHexNeighbors(TraversalDirection.down),
                        const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
                            _focusHexNeighbors(TraversalDirection.up),
                      },
                      child: TextField(
                        controller: _hexController,
                        focusNode: _hexFocus,
                        maxLength: 7,
                        style: tt.bodyMedium?.copyWith(
                          color: ext.textPrimary,
                          fontFamily: 'monospace',
                        ),
                        onChanged: _onHexChanged,
                        decoration: InputDecoration(
                          labelText: l10n.customHex,
                          labelStyle: tt.bodySmall?.copyWith(color: ext.textTertiary),
                          errorText: _hexError,
                          hintText: '#C76E00',
                          counterText: '',
                          filled: true,
                          fillColor: ext.bgInput,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(sizes.cardRadiusSm),
                            borderSide: BorderSide(color: ext.borderSubtle),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(sizes.cardRadiusSm),
                            borderSide: BorderSide(color: ext.borderSubtle),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(sizes.cardRadiusSm),
                            borderSide: BorderSide(color: accent, width: AppConstants.focusBorderWidth),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.accentTextColor,
                    style: tt.titleSmall?.copyWith(color: ext.textPrimary),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: ext.bgInput,
                      borderRadius: BorderRadius.circular(sizes.cardRadiusSm),
                      border: Border.all(color: ext.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 28,
                          decoration: BoxDecoration(
                            color: _selected,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Center(
                            child: Text(
                              'Aa',
                              style: tt.labelMedium?.copyWith(
                                color: previewForeground,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            textColorOptions[_textColor.index].$2,
                            style: tt.bodyMedium?.copyWith(color: ext.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: List<Widget>.generate(
                      textColorOptions.length,
                      (index) {
                        final option = textColorOptions[index];
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: index == textColorOptions.length - 1 ? 0 : 8),
                            child: FocusTraversalOrder(
                              order: NumericFocusOrder(100.1 + index),
                              child: _AccentTextColorOption(
                                focusNode: _textColorFocusNodes[index],
                                accentColor: _selected,
                                mode: option.$1,
                                label: option.$2,
                                isSelected: _textColor == option.$1,
                                onTap: () => setState(() => _textColor = option.$1),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FocusTraversalOrder(
                        order: const NumericFocusOrder(101),
                        child: _ColorDialogButton(
                          focusNode: _cancelFocus,
                          label: l10n.cancel,
                          isPrimary: false,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FocusTraversalOrder(
                        order: const NumericFocusOrder(102),
                        child: _ColorDialogButton(
                          focusNode: _applyFocus,
                          label: l10n.apply,
                          isPrimary: true,
                          onPressed: () => Navigator.of(context).pop(
                            AccentColorSelection(
                              color: _selected,
                              textColor: _textColor,
                            ),
                          ),
                        ),
                      ),
                    ],
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

// ---------------------------------------------------------------------------
// Color chip
// ---------------------------------------------------------------------------

class _ColorChip extends StatelessWidget {
  const _ColorChip({
    required this.color,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.focusNode,
  });

  final Color color;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: FocusHighlight(
        focusNode: focusNode,
        onPressed: onTap,
        isCircular: true,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: AppConstants.focusTransitionMs),
            width: AppConstants.colorChipSize,
            height: AppConstants.colorChipSize,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: isSelected ? 2.5 : 0,
              ),
            ),
            child: isSelected
                ? const Icon(LucideIcons.check, size: 16, color: Colors.white)
                : null,
          ),
        ),
      ),
    );
  }
}

class _AccentTextColorOption extends StatelessWidget {
  const _AccentTextColorOption({
    required this.focusNode,
    required this.accentColor,
    required this.mode,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final FocusNode focusNode;
  final Color accentColor;
  final AccentTextColorSetting mode;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;
    const innerBorderRadius = AppConstants.btnRadius > AppConstants.focusBorderWidth
        ? AppConstants.btnRadius - AppConstants.focusBorderWidth
        : AppConstants.btnRadius;
    const innerHeight = AppConstants.minFocusableSize - (AppConstants.focusBorderWidth * 2);
    final borderColor = isSelected
        ? Theme.of(context).colorScheme.primary
        : ext.borderSubtle;
    final previewForeground = AppTheme.resolveOnAccentColor(accentColor, mode);

    return FocusHighlight(
      focusNode: focusNode,
      borderRadius: AppConstants.btnRadius,
      padding: const EdgeInsets.all(AppConstants.focusBorderWidth),
      onPressed: onTap,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: innerHeight,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: ext.bgInput,
            borderRadius: BorderRadius.circular(innerBorderRadius),
            border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 20,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Center(
                  child: Text(
                    'Aa',
                    style: tt.labelSmall?.copyWith(
                      color: previewForeground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: tt.bodySmall?.copyWith(color: ext.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorDialogButton extends StatelessWidget {
  const _ColorDialogButton({
    required this.focusNode,
    required this.label,
    required this.isPrimary,
    required this.onPressed,
  });

  final FocusNode focusNode;
  final String label;
  final bool isPrimary;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return FilledButton(
        focusNode: focusNode,
        onPressed: onPressed,
        child: Text(label),
      );
    }

    return OutlinedButton(
      focusNode: focusNode,
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
