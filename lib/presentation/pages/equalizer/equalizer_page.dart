import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/eq_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/focus_highlight.dart';
import '../../widgets/gamepad_button_hints.dart';
import '../dialogs/text_input_dialog.dart';

/// Equalizer page with 10 vertical band sliders.
///
/// Route: `/equalizer`
///
/// LB/RB cycle through EQ presets.
class EqualizerPage extends ConsumerStatefulWidget {
  const EqualizerPage({super.key});

  @override
  ConsumerState<EqualizerPage> createState() => _EqualizerPageState();
}

class _EqualizerPageState extends ConsumerState<EqualizerPage> {
  late final FocusNode _enableToggleFocus;
  late final FocusNode _presetFocus;
  late final FocusNode _keyListenerFocusNode;
  final List<FocusNode> _bandFocusNodes = List.generate(
    AppConstants.eqBandCount,
    (i) => FocusNode(debugLabel: 'EQ-band-$i'),
  );

  @override
  void initState() {
    super.initState();
    _enableToggleFocus = FocusNode(debugLabel: 'EQ-enable');
    _presetFocus = FocusNode(debugLabel: 'EQ-preset');
    _keyListenerFocusNode = FocusNode(debugLabel: 'EqualizerPage-keyListener')..skipTraversal = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _enableToggleFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _enableToggleFocus.dispose();
    _presetFocus.dispose();
    _keyListenerFocusNode.dispose();
    for (final f in _bandFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _cyclePrevPreset(EqState eq) {
    final presets = eq.presets;
    if (presets.isEmpty) return;
    final currentIdx = presets.indexWhere((p) => p.id == eq.selectedPresetId);
    final nextIdx = (currentIdx - 1 + presets.length) % presets.length;
    ref.read(eqProvider.notifier).selectPreset(presets[nextIdx].id);
  }

  void _cycleNextPreset(EqState eq) {
    final presets = eq.presets;
    if (presets.isEmpty) return;
    final currentIdx = presets.indexWhere((p) => p.id == eq.selectedPresetId);
    final nextIdx = (currentIdx + 1) % presets.length;
    ref.read(eqProvider.notifier).selectPreset(presets[nextIdx].id);
  }

  KeyEventResult _handleKey(KeyEvent event, EqState eq) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    switch (event.logicalKey) {
      case LogicalKeyboardKey.escape:
      case LogicalKeyboardKey.gameButtonB:
      case LogicalKeyboardKey.keyB:
        Navigator.of(context).maybePop();
        return KeyEventResult.handled;

      case LogicalKeyboardKey.gameButtonLeft1: // LB
        _cyclePrevPreset(eq);
        return KeyEventResult.handled;

      case LogicalKeyboardKey.gameButtonRight1: // RB
        _cycleNextPreset(eq);
        return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Future<void> _saveCustomPreset() async {
    final l10n = AppLocalizations.of(context)!;
    final name = await showTextInputDialog(
      context,
      title: l10n.savePreset,
      hint: l10n.presetNameHint,
      confirmLabel: l10n.save,
      cancelLabel: l10n.cancel,
    );
    if (name != null && name.trim().isNotEmpty) {
      await ref.read(eqProvider.notifier).saveCustomPreset(name.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final sizes = AppSizes.of(context);
    final eqAsync = ref.watch(eqProvider);

    return eqAsync.when(
      data: (eq) => KeyboardListener(
        focusNode: _keyListenerFocusNode,
        onKeyEvent: (event) => _handleKey(event, eq),
        child: Scaffold(
          backgroundColor: ext.bgDeep,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ─────────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(
                  sizes.screenEdgePadding,
                  sizes.screenEdgePadding,
                  sizes.screenEdgePadding,
                  0,
                ),
                child: Row(
                  children: [
                    Text(
                      l10n.equalizer,
                      style: tt.headlineLarge?.copyWith(
                        color: ext.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    // Enable toggle
                    _EnableToggle(
                      focusNode: _enableToggleFocus,
                      isEnabled: eq.isEnabled,
                      onToggle: (v) => ref.read(eqProvider.notifier).toggleEq(enabled: v),
                    ),
                  ],
                ),
              ),

              // ── Preset selector ────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: sizes.screenEdgePadding, vertical: 16),
                child: Row(
                  children: [
                    // LB arrow
                    GestureDetector(
                      onTap: () => _cyclePrevPreset(eq),
                      child: Icon(LucideIcons.chevronLeft, size: 20, color: ext.textSecondary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FocusHighlight(
                        focusNode: _presetFocus,
                        borderRadius: sizes.cardRadiusSm,
                        onPressed: () {},
                        child: PopupMenuButton<int>(
                          onSelected: (id) => ref.read(eqProvider.notifier).selectPreset(id),
                          color: ext.bgSurface,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: ext.bgCard,
                              borderRadius: BorderRadius.circular(sizes.cardRadiusSm),
                              border: Border.all(color: ext.borderCard),
                            ),
                            child: Row(
                              children: [
                                Icon(LucideIcons.slidersHorizontal, size: 16, color: ext.textSecondary),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    eq.selectedPreset?.name ?? l10n.eqCustom,
                                    style: tt.bodyMedium?.copyWith(color: ext.textPrimary),
                                  ),
                                ),
                                Icon(LucideIcons.chevronsUpDown, size: 14, color: ext.textTertiary),
                              ],
                            ),
                          ),
                          itemBuilder: (_) => eq.presets
                              .map((p) => PopupMenuItem<int>(
                                    value: p.id,
                                    child: Row(
                                      children: [
                                        if (p.id == eq.selectedPresetId)
                                          Icon(LucideIcons.check, size: 14, color: Theme.of(context).colorScheme.primary)
                                        else
                                          const SizedBox(width: 14),
                                        const SizedBox(width: 8),
                                        Text(p.name, style: tt.bodySmall?.copyWith(color: ext.textPrimary)),
                                        if (p.isBuiltin) ...[
                                          const Spacer(),
                                          Text(l10n.eqBuiltIn, style: tt.labelSmall?.copyWith(color: ext.textTertiary)),
                                        ],
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // RB arrow
                    GestureDetector(
                      onTap: () => _cycleNextPreset(eq),
                      child: Icon(LucideIcons.chevronRight, size: 20, color: ext.textSecondary),
                    ),
                  ],
                ),
              ),

              // ── Band sliders ───────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: sizes.screenEdgePadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(AppConstants.eqBandCount, (i) {
                      final gain = eq.hasBands ? eq.bands[i] : 0.0;
                      return _BandSlider(
                        key: ValueKey(i),
                        focusNode: _bandFocusNodes[i],
                        label: AppConstants.eqBandLabels[i],
                        value: gain,
                        isEnabled: eq.isEnabled,
                        onChanged: eq.isEnabled ? (v) => ref.read(eqProvider.notifier).setBandValue(i, v) : null,
                      );
                    }),
                  ),
                ),
              ),

              // ── Bottom actions ─────────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(
                  sizes.screenEdgePadding,
                  12,
                  sizes.screenEdgePadding,
                  12,
                ),
                child: Row(
                  children: [
                    _TextBtn(
                      label: l10n.eqSaveAsPreset,
                      onTap: eq.isEnabled ? _saveCustomPreset : null,
                    ),
                    const SizedBox(width: 16),
                    _TextBtn(
                      label: l10n.eqReset,
                      onTap: eq.selectedPresetId == null ? null : () => ref.read(eqProvider.notifier).selectPreset(eq.selectedPresetId!),
                    ),
                  ],
                ),
              ),

              // ── Gamepad button hints ───────────────────────────────────
              GamepadButtonHints(
                aLabel: 'Select',
                bLabel: 'Back',
                lbLabel: 'Prev Preset',
                rbLabel: 'Next Preset',
                backgroundColor: ext.bgSurface,
              ),
            ],
          ),
        ),
      ),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Scaffold(
        body: EmptyState(
          icon: LucideIcons.circleAlert,
          title: l10n.eqFailed,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Enable toggle
// ---------------------------------------------------------------------------

class _EnableToggle extends StatelessWidget {
  const _EnableToggle({
    required this.focusNode,
    required this.isEnabled,
    required this.onToggle,
  });
  final FocusNode focusNode;
  final bool isEnabled;
  final void Function(bool) onToggle;

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return FocusHighlight(
      focusNode: focusNode,
      borderRadius: 24,
      onPressed: () => onToggle(!isEnabled),
      child: GestureDetector(
        onTap: () => onToggle(!isEnabled),
        child: Row(
          children: [
            Text(l10n.eqToggle, style: tt.bodyMedium?.copyWith(color: ext.textSecondary)),
            const SizedBox(width: 8),
            Switch(
              value: isEnabled,
              onChanged: onToggle,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Band slider (vertical)
// ---------------------------------------------------------------------------

class _BandSlider extends StatefulWidget {
  const _BandSlider({
    super.key,
    required this.focusNode,
    required this.label,
    required this.value,
    required this.isEnabled,
    this.onChanged,
  });

  final FocusNode focusNode;
  final String label;
  final double value;
  final bool isEnabled;
  final void Function(double)? onChanged;

  @override
  State<_BandSlider> createState() => _BandSliderState();
}

class _BandSliderState extends State<_BandSlider> {
  static const _step = 0.5; // dB per arrow press

  // Prevents Slider's internal focus from double-handling arrow keys.
  final _sliderFocus = FocusNode(canRequestFocus: false, skipTraversal: true);

  @override
  void dispose() {
    _sliderFocus.dispose();
    super.dispose();
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (!widget.isEnabled || widget.onChanged == null) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      widget.onChanged!((widget.value + _step).clamp(-12.0, 12.0));
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      widget.onChanged!((widget.value - _step).clamp(-12.0, 12.0));
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return FocusHighlight(
      focusNode: widget.focusNode,
      borderRadius: 8,
      onPressed: null,
      onKeyEvent: _handleKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Gain label
          Text(
            '${widget.value >= 0 ? '+' : ''}${widget.value.toStringAsFixed(1)}',
            style: tt.labelSmall?.copyWith(
              color: widget.isEnabled ? cs.primary : ext.textTertiary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),

          // Vertical slider
          SizedBox(
            height: AppConstants.eqSliderHeight,
            child: RotatedBox(
              quarterTurns: 3, // rotate slider to vertical
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: AppConstants.eqSliderWidth,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: AppConstants.eqThumbSize / 2,
                  ),
                  thumbColor: widget.isEnabled ? cs.primary : ext.textTertiary,
                  activeTrackColor: widget.isEnabled ? cs.primary.withOpacity(0.8) : ext.textTertiary,
                  inactiveTrackColor: ext.borderSubtle,
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                ),
                child: Slider(
                  value: widget.value.clamp(-12.0, 12.0),
                  min: -12.0,
                  max: 12.0,
                  onChanged: widget.isEnabled ? widget.onChanged : null,
                  focusNode: _sliderFocus,
                ),
              ),
            ),
          ),

          const SizedBox(height: 4),
          // Frequency label
          Text(
            widget.label,
            style: tt.labelSmall?.copyWith(
              color: ext.textTertiary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Text button
// ---------------------------------------------------------------------------

class _TextBtn extends StatefulWidget {
  const _TextBtn({required this.label, required this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  State<_TextBtn> createState() => _TextBtnState();
}

class _TextBtnState extends State<_TextBtn> {
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode();
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;

    return FocusHighlight(
      focusNode: _focus,
      borderRadius: AppConstants.btnRadius,
      onPressed: widget.onTap,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: ext.bgSurface,
            borderRadius: BorderRadius.circular(AppConstants.btnRadius),
            border: Border.all(color: ext.borderSubtle),
          ),
          child: Text(
            widget.label,
            style: tt.labelSmall?.copyWith(
              color: widget.onTap != null ? ext.textPrimary : ext.textTertiary,
            ),
          ),
        ),
      ),
    );
  }
}
