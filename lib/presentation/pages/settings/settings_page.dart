import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_enums.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/scan_folder_provider.dart';
import '../../providers/scan_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/focus_highlight.dart';
import '../../widgets/settings_popup_registry.dart';
import '../dialogs/color_picker_dialog.dart';

/// Settings page — 7 sections.
///
/// Route: `/settings`
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late final FocusNode _defaultFocus;
  late final FocusNode _keyListenerFocusNode;

  @override
  void initState() {
    super.initState();
    _defaultFocus = FocusNode(debugLabel: 'Settings-default');
    _keyListenerFocusNode = FocusNode(debugLabel: 'SettingsPage-keyListener')..skipTraversal = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _defaultFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _defaultFocus.dispose();
    _keyListenerFocusNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.escape || event.logicalKey == LogicalKeyboardKey.gameButtonB) {
      if (settingsColorPopupVisible.value) {
        settingsColorPopupDismiss.value?.call();
        return KeyEventResult.handled;
      }
      if (settingsThemePopupVisible.value) {
        settingsThemePopupDismiss.value?.call();
        return KeyEventResult.handled;
      }
      context.pop();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final sizes = AppSizes.of(context);

    // Providers
    final theme = ref.watch(themeProvider);
    final autoScanAsync = ref.watch(autoScanProvider);
    final gaplessAsync = ref.watch(gaplessPlaybackProvider);
    final resumeAsync = ref.watch(resumeOnLaunchProvider);
    final crossfadeAsync = ref.watch(crossfadeSecondsProvider);
    final gamepadAsync = ref.watch(gamepadEnabledProvider);
    final animateFocusScrollingAsync = ref.watch(animateFocusScrollingProvider);
    final navSoundAsync = ref.watch(navSoundLevelProvider);
    final closeToTrayAsync = ref.watch(closeToTrayProvider);
    final startWithOsAsync = ref.watch(startWithOsProvider);
    final foldersAsync = ref.watch(scanFoldersProvider);

    return KeyboardListener(
      focusNode: _keyListenerFocusNode,
      onKeyEvent: _handleKey,
      child: Scaffold(
        backgroundColor: ext.bgDeep,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                sizes.screenEdgePadding,
                sizes.screenEdgePadding,
                sizes.screenEdgePadding,
                0,
              ),
              child: Text(
                l10n.navSettings,
                style: tt.headlineLarge?.copyWith(
                  color: ext.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Scrollable body ───────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(bottom: sizes.screenEdgePadding),
                children: [
                  // ── 1. Appearance ───────────────────────────────────────
                  _SectionHeader(title: l10n.settingsAppearance),
                  _ThemeModeRow(
                    ext: ext,
                    tt: tt,
                    current: theme.mode,
                    defaultFocus: _defaultFocus,
                    onChange: (m) => ref.read(themeProvider.notifier).setThemeMode(m),
                  ),
                  _ColorRow(
                    ext: ext,
                    tt: tt,
                    accent: theme.accentColor,
                    onTap: () async {
                      final picked = await showColorPickerDialog(
                        context,
                        initial: theme.accentColor,
                      );
                      if (picked != null) {
                        ref.read(themeProvider.notifier).setAccentColor(picked);
                      }
                    },
                  ),

                  // ── 2. Library ──────────────────────────────────────────
                  _SectionHeader(title: l10n.settingsLibrary),
                  _FolderListTile(
                    ext: ext,
                    tt: tt,
                    foldersAsync: foldersAsync,
                  ),
                  _BoolRow(
                    ext: ext,
                    tt: tt,
                    label: 'Auto Scan',
                    value: autoScanAsync.value ?? true,
                    onChanged: (v) => ref.read(autoScanProvider.notifier).set(v),
                  ),
                  _ActionRow(
                    ext: ext,
                    tt: tt,
                    label: l10n.settingsRescanLibrary,
                    icon: LucideIcons.refreshCw,
                    onTap: () => ref.read(scanProvider.notifier).startScan(),
                  ),

                  // ── 3. Playback ─────────────────────────────────────────
                  _SectionHeader(title: l10n.settingsPlayback),
                  _CrossfadeRow(
                    ext: ext,
                    tt: tt,
                    seconds: crossfadeAsync.value ?? 0,
                    onChange: (v) => ref.read(crossfadeSecondsProvider.notifier).set(v),
                  ),
                  _BoolRow(
                    ext: ext,
                    tt: tt,
                    label: 'Gapless Playback',
                    value: gaplessAsync.value ?? false,
                    onChanged: (v) => ref.read(gaplessPlaybackProvider.notifier).set(v),
                  ),
                  _BoolRow(
                    ext: ext,
                    tt: tt,
                    label: 'Resume on Launch',
                    value: resumeAsync.value ?? true,
                    onChanged: (v) => ref.read(resumeOnLaunchProvider.notifier).set(v),
                  ),

                  // ── 4. Equalizer link ───────────────────────────────────
                  _SectionHeader(title: l10n.equalizer),
                  _ActionRow(
                    ext: ext,
                    tt: tt,
                    label: l10n.equalizer,
                    icon: LucideIcons.chartBar,
                    onTap: () => context.push('/equalizer'),
                  ),

                  // ── 5. Controls ─────────────────────────────────────────
                  _SectionHeader(title: l10n.settingsControls),
                  _BoolRow(
                    ext: ext,
                    tt: tt,
                    label: 'Gamepad',
                    value: gamepadAsync.value ?? true,
                    onChanged: (v) => ref.read(gamepadEnabledProvider.notifier).set(v),
                  ),
                  _BoolRow(
                    ext: ext,
                    tt: tt,
                    label: l10n.settingsAnimateFocusScrolling,
                    value: animateFocusScrollingAsync.value ?? true,
                    onChanged: (v) => ref.read(animateFocusScrollingProvider.notifier).set(v),
                  ),
                  _SliderRow(
                    ext: ext,
                    tt: tt,
                    label: l10n.settingsNavigationSounds,
                    value: navSoundAsync.value ?? AppConstants.defaultNavSoundLevel,
                    onChanged: (v) => ref.read(navSoundLevelProvider.notifier).set(v),
                  ),
                  _ActionRow(
                    ext: ext,
                    tt: tt,
                    icon: LucideIcons.keyboard,
                    label: 'Keyboard Shortcuts',
                    onTap: () => context.go('/settings/shortcuts'),
                  ),

                  // ── 6. System ───────────────────────────────────────────
                  _SectionHeader(title: l10n.settingsSystem),
                  _BoolRow(
                    ext: ext,
                    tt: tt,
                    label: l10n.settingsCloseToTray,
                    value: closeToTrayAsync.value ?? true,
                    onChanged: (v) => ref.read(closeToTrayProvider.notifier).set(v),
                  ),
                  _BoolRow(
                    ext: ext,
                    tt: tt,
                    label: l10n.settingsStartWithSystem,
                    value: startWithOsAsync.value ?? false,
                    onChanged: (v) => ref.read(startWithOsProvider.notifier).set(v),
                  ),

                  // ── 7. About ────────────────────────────────────────────
                  _SectionHeader(title: l10n.settingsAbout),
                  _AboutCard(ext: ext, tt: tt),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final sizes = AppSizes.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        sizes.screenEdgePadding,
        20,
        sizes.screenEdgePadding,
        4,
      ),
      child: Text(
        title,
        style: tt.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Settings rows
// ---------------------------------------------------------------------------

class _SettingsRow extends StatefulWidget {
  const _SettingsRow({
    required this.ext,
    required this.tt,
    required this.label,
    this.trailing,
    this.onTap,
    this.subtitle,
    this.onKeyEvent,
  });
  final AppThemeExtension ext;
  final TextTheme tt;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;
  final String? subtitle;
  final FocusOnKeyEventCallback? onKeyEvent;

  @override
  State<_SettingsRow> createState() => _SettingsRowState();
}

class _SettingsRowState extends State<_SettingsRow> {
  final _focus = FocusNode();

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ext = widget.ext;
    final tt = widget.tt;

    return FocusHighlight(
      focusNode: _focus,
      borderRadius: 0,
      onPressed: widget.onTap,
      onKeyEvent: widget.onKeyEvent,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: AppConstants.listTileHeight),
          padding: EdgeInsets.symmetric(horizontal: AppSizes.of(context).screenEdgePadding, vertical: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: ext.borderSubtle, width: 0.5)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(widget.label, style: tt.bodyMedium?.copyWith(color: ext.textPrimary)),
                    if (widget.subtitle != null) Text(widget.subtitle!, style: tt.bodySmall?.copyWith(color: ext.textTertiary)),
                  ],
                ),
              ),
              if (widget.trailing != null) widget.trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

class _BoolRow extends StatelessWidget {
  const _BoolRow({
    required this.ext,
    required this.tt,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final AppThemeExtension ext;
  final TextTheme tt;
  final String label;
  final bool value;
  final void Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return _SettingsRow(
      ext: ext,
      tt: tt,
      label: label,
      onTap: () => onChanged(!value),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.ext,
    required this.tt,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final AppThemeExtension ext;
  final TextTheme tt;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _SettingsRow(
      ext: ext,
      tt: tt,
      label: label,
      onTap: onTap,
      trailing: Icon(icon, size: 16, color: ext.textTertiary),
    );
  }
}

class _ThemeModeRow extends StatefulWidget {
  const _ThemeModeRow({
    required this.ext,
    required this.tt,
    required this.current,
    required this.defaultFocus,
    required this.onChange,
  });

  final AppThemeExtension ext;
  final TextTheme tt;
  final ThemeModeSetting current;
  final FocusNode defaultFocus;
  final void Function(ThemeModeSetting) onChange;

  @override
  State<_ThemeModeRow> createState() => _ThemeModeRowState();
}

class _ThemeModeRowState extends State<_ThemeModeRow> {
  Future<void> _openMenu() async {
    settingsThemePopupDismiss.value = _dismissMenu;
    settingsThemePopupVisible.value = true;

    ThemeModeSetting? selected;
    try {
      selected = await showDialog<ThemeModeSetting>(
        context: context,
        barrierDismissible: true,
        traversalEdgeBehavior: TraversalEdgeBehavior.closedLoop,
        builder: (dialogContext) => _ThemeModeDialog(
          ext: widget.ext,
          tt: widget.tt,
          current: widget.current,
        ),
      );
    } finally {
      _closeMenuState();
    }

    if (selected != null) {
      widget.onChange(selected);
    }
  }

  void _dismissMenu() {
    Navigator.of(context, rootNavigator: true).maybePop();
  }

  void _closeMenuState() {
    settingsThemePopupVisible.value = false;
    if (identical(settingsThemePopupDismiss.value, _dismissMenu)) {
      settingsThemePopupDismiss.value = null;
    }
  }

  @override
  void dispose() {
    if (settingsThemePopupVisible.value) {
      _closeMenuState();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labels = {
      ThemeModeSetting.dark: 'Dark',
      ThemeModeSetting.light: 'Light',
      ThemeModeSetting.system: 'System',
    };
    return _SettingsRow(
      ext: widget.ext,
      tt: widget.tt,
      label: 'Theme',
      subtitle: labels[widget.current],
      onTap: _openMenu,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(labels[widget.current] ?? '', style: widget.tt.bodySmall?.copyWith(color: widget.ext.textSecondary)),
          const SizedBox(width: 4),
          Icon(LucideIcons.chevronsUpDown, size: 14, color: widget.ext.textTertiary),
        ],
      ),
    );
  }
}

class _ThemeModeDialog extends StatefulWidget {
  const _ThemeModeDialog({
    required this.ext,
    required this.tt,
    required this.current,
  });

  final AppThemeExtension ext;
  final TextTheme tt;
  final ThemeModeSetting current;

  @override
  State<_ThemeModeDialog> createState() => _ThemeModeDialogState();
}

class _ThemeModeDialogState extends State<_ThemeModeDialog> {
  final _darkFocus = FocusNode(debugLabel: 'Settings-theme-dark');
  final _lightFocus = FocusNode(debugLabel: 'Settings-theme-light');
  final _systemFocus = FocusNode(debugLabel: 'Settings-theme-system');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      switch (widget.current) {
        case ThemeModeSetting.dark:
          _darkFocus.requestFocus();
        case ThemeModeSetting.light:
          _lightFocus.requestFocus();
        case ThemeModeSetting.system:
          _systemFocus.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _darkFocus.dispose();
    _lightFocus.dispose();
    _systemFocus.dispose();
    super.dispose();
  }

  KeyEventResult _handleDialogKey(FocusNode _, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape ||
        event.logicalKey == LogicalKeyboardKey.gameButtonB ||
        event.logicalKey == LogicalKeyboardKey.keyB) {
      Navigator.of(context).pop();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final labels = {
      ThemeModeSetting.dark: 'Dark',
      ThemeModeSetting.light: 'Light',
      ThemeModeSetting.system: 'System',
    };

    Widget buildOption({
      required ThemeModeSetting mode,
      required FocusNode node,
    }) {
      final isSelected = widget.current == mode;
      return FocusHighlight(
        focusNode: node,
        borderRadius: 8,
        onPressed: () => Navigator.of(context).pop(mode),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(mode),
          child: Container(
            height: AppConstants.listTileHeight,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isSelected ? widget.ext.bgInput : Colors.transparent,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    labels[mode] ?? mode.name,
                    style: widget.tt.bodyMedium?.copyWith(color: widget.ext.textPrimary),
                  ),
                ),
                if (isSelected)
                  Icon(
                    LucideIcons.check,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Focus(
      autofocus: true,
      onKeyEvent: _handleDialogKey,
      child: AlertDialog(
        backgroundColor: widget.ext.bgSurface,
        title: Text(
          'Theme',
          style: widget.tt.titleMedium?.copyWith(color: widget.ext.textPrimary),
        ),
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        content: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildOption(mode: ThemeModeSetting.dark, node: _darkFocus),
              const SizedBox(height: 6),
              buildOption(mode: ThemeModeSetting.light, node: _lightFocus),
              const SizedBox(height: 6),
              buildOption(mode: ThemeModeSetting.system, node: _systemFocus),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliderRow extends StatefulWidget {
  const _SliderRow({
    required this.ext,
    required this.tt,
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final AppThemeExtension ext;
  final TextTheme tt;
  final String label;
  final double value;
  final void Function(double) onChanged;

  @override
  State<_SliderRow> createState() => _SliderRowState();
}

class _SliderRowState extends State<_SliderRow> {
  static const _step = 0.05;

  // Prevents Slider's internal focus from consuming Up/Down arrows.
  // Up/Down should scroll the settings list; Left/Right adjusts the value.
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
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      widget.onChanged((widget.value + _step).clamp(0.0, 1.0));
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      widget.onChanged((widget.value - _step).clamp(0.0, 1.0));
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsRow(
      ext: widget.ext,
      tt: widget.tt,
      label: widget.label,
      onKeyEvent: _handleKey,
      trailing: SizedBox(
        width: 140,
        child: Slider(
          value: widget.value,
          min: 0,
          max: 1,
          onChanged: widget.onChanged,
          focusNode: _sliderFocus,
        ),
      ),
    );
  }
}

class _CrossfadeRow extends StatefulWidget {
  const _CrossfadeRow({
    required this.ext,
    required this.tt,
    required this.seconds,
    required this.onChange,
  });
  final AppThemeExtension ext;
  final TextTheme tt;
  final int seconds;
  final void Function(int) onChange;

  @override
  State<_CrossfadeRow> createState() => _CrossfadeRowState();
}

class _CrossfadeRowState extends State<_CrossfadeRow> {
  // Prevents Slider's internal focus from consuming Up/Down arrows.
  // Up/Down should scroll the settings list; Left/Right adjusts the value.
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
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      widget.onChange((widget.seconds + 1).clamp(0, 12));
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      widget.onChange((widget.seconds - 1).clamp(0, 12));
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsRow(
      ext: widget.ext,
      tt: widget.tt,
      label: 'Crossfade',
      subtitle: widget.seconds == 0 ? 'Disabled' : '${widget.seconds}s',
      onKeyEvent: _handleKey,
      trailing: SizedBox(
        width: 140,
        child: Slider(
          value: widget.seconds.toDouble(),
          min: 0,
          max: 12,
          divisions: 12,
          label: widget.seconds == 0 ? 'Off' : '${widget.seconds}s',
          onChanged: (v) => widget.onChange(v.round()),
          focusNode: _sliderFocus,
        ),
      ),
    );
  }
}

class _ColorRow extends StatelessWidget {
  const _ColorRow({
    required this.ext,
    required this.tt,
    required this.accent,
    required this.onTap,
  });
  final AppThemeExtension ext;
  final TextTheme tt;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _SettingsRow(
      ext: ext,
      tt: tt,
      label: 'Accent Color',
      onTap: onTap,
      trailing: GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppConstants.colorChipSize,
              height: AppConstants.colorChipSize,
              decoration: BoxDecoration(
                color: accent,
                shape: BoxShape.circle,
                border: Border.all(color: ext.borderCard, width: 2),
              ),
            ),
            const SizedBox(width: 8),
            Icon(LucideIcons.chevronRight, size: 14, color: ext.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _FolderListTile extends ConsumerWidget {
  const _FolderListTile({
    required this.ext,
    required this.tt,
    required this.foldersAsync,
  });
  final AppThemeExtension ext;
  final TextTheme tt;
  final AsyncValue<List<dynamic>> foldersAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = foldersAsync.value?.length ?? 0;
    return _SettingsRow(
      ext: ext,
      tt: tt,
      label: 'Music Folders',
      subtitle: '$count folder${count == 1 ? '' : 's'} added',
      onTap: () async {
        final result = await FilePicker.getDirectoryPath(
          dialogTitle: 'Select Music Folder',
        );
        if (result != null) {
          await ref.read(scanFoldersProvider.notifier).addFolder(result);
        }
      },
      trailing: Icon(LucideIcons.folderOpen, size: 16, color: ext.textTertiary),
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard({required this.ext, required this.tt});
  final AppThemeExtension ext;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sizes = AppSizes.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        sizes.screenEdgePadding,
        8,
        sizes.screenEdgePadding,
        0,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ext.bgSurface,
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          border: Border.all(color: ext.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    LucideIcons.info,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppConstants.appTitle,
                    style: tt.titleMedium?.copyWith(color: ext.textPrimary),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: ext.bgInput,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'v${AppConstants.appVersion}',
                    style: tt.labelMedium?.copyWith(color: ext.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _AboutMetaRow(
              ext: ext,
              tt: tt,
              label: l10n.settingsVersion,
              value: AppConstants.appVersion,
            ),
            const SizedBox(height: 10),
            _AboutMetaRow(
              ext: ext,
              tt: tt,
              label: l10n.settingsCredits,
              value: AppConstants.appCreatorName,
            ),
            const SizedBox(height: 10),
            Text(
              l10n.settingsOpenSourceProject,
              style: tt.bodySmall?.copyWith(color: ext.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutMetaRow extends StatelessWidget {
  const _AboutMetaRow({
    required this.ext,
    required this.tt,
    required this.label,
    required this.value,
  });

  final AppThemeExtension ext;
  final TextTheme tt;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: tt.bodySmall?.copyWith(color: ext.textTertiary),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: tt.bodyMedium?.copyWith(color: ext.textPrimary),
        ),
      ],
    );
  }
}
