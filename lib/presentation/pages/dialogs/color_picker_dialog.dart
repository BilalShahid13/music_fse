import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
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
/// final color = await showColorPickerDialog(
///   context,
///   initial: Theme.of(context).colorScheme.primary,
/// );
/// if (color != null) { /* apply */ }
/// ```
Future<Color?> showColorPickerDialog(
  BuildContext context, {
  required Color initial,
}) {
  return showDialog<Color>(
    context: context,
    barrierDismissible: true,
    traversalEdgeBehavior: TraversalEdgeBehavior.closedLoop,
    builder: (_) => _ColorPickerDialog(initial: initial),
  );
}

// ---------------------------------------------------------------------------
// Implementation
// ---------------------------------------------------------------------------

class _ColorPickerDialog extends StatefulWidget {
  const _ColorPickerDialog({required this.initial});
  final Color initial;

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late Color _selected;
  late final TextEditingController _hexController;
  late final List<FocusNode> _chipFocusNodes;
  late final FocusNode _hexFocus;
  late final FocusNode _cancelFocus;
  late final FocusNode _applyFocus;
  String? _hexError;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
    _hexController = TextEditingController(text: _colorToHex(widget.initial));
    _chipFocusNodes = List<FocusNode>.generate(
      kAccentColorOptions.length,
      (index) => FocusNode(debugLabel: 'ColorPicker-chip-$index'),
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

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;
    final sizes = AppSizes.of(context);
    final accent = Theme.of(context).colorScheme.primary;
    final l10n = AppLocalizations.of(context)!;

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
                          ext: ext,
                          tt: tt,
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
                          ext: ext,
                          tt: tt,
                          accent: accent,
                          onPressed: () => Navigator.of(context).pop(_selected),
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

class _ColorChip extends StatefulWidget {
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
  State<_ColorChip> createState() => _ColorChipState();
}

class _ColorChipState extends State<_ColorChip> {
  late final FocusNode _focus;

  KeyEventResult _handleKey(FocusNode _, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space ||
        event.logicalKey == LogicalKeyboardKey.gameButtonA) {
      widget.onTap();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  void initState() {
    super.initState();
    _focus = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    // Only dispose if we created the node (not passed in).
    if (widget.focusNode == null) _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Focus(
      focusNode: _focus,
      onKeyEvent: _handleKey,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Tooltip(
          message: widget.label,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: AppConstants.focusTransitionMs),
            width: AppConstants.colorChipSize,
            height: AppConstants.colorChipSize,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
              border: Border.all(
                color: _focus.hasFocus ? accent : (widget.isSelected ? Colors.white : Colors.transparent),
                width: widget.isSelected || _focus.hasFocus ? 2.5 : 0,
              ),
              boxShadow: _focus.hasFocus
                  ? [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.4),
                        blurRadius: AppConstants.focusGlowBlur,
                      ),
                    ]
                  : null,
            ),
            child: widget.isSelected ? const Icon(LucideIcons.check, size: 16, color: Colors.white) : null,
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
    required this.ext,
    required this.tt,
    required this.onPressed,
    this.accent,
  });

  final FocusNode focusNode;
  final String label;
  final bool isPrimary;
  final AppThemeExtension ext;
  final TextTheme tt;
  final VoidCallback onPressed;
  final Color? accent;

  KeyEventResult _handleKey(FocusNode _, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space ||
        event.logicalKey == LogicalKeyboardKey.gameButtonA) {
      onPressed();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focusNode,
      onKeyEvent: _handleKey,
      child: Builder(
        builder: (context) {
          final hasFocus = focusNode.hasFocus;
          final resolvedAccent = accent ?? Theme.of(context).colorScheme.primary;
          return GestureDetector(
            onTap: onPressed,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: AppConstants.focusTransitionMs),
              curve: Curves.easeOut,
              constraints: const BoxConstraints(
                minWidth: 88,
                minHeight: AppConstants.minFocusableSize,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isPrimary ? resolvedAccent : Colors.transparent,
                borderRadius: BorderRadius.circular(AppConstants.btnRadius),
                border: Border.all(
                  color: hasFocus ? resolvedAccent : (isPrimary ? Colors.transparent : ext.borderSubtle),
                  width: hasFocus ? AppConstants.focusBorderWidth : 1,
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: tt.labelLarge?.copyWith(
                    color: isPrimary ? Colors.white : ext.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
