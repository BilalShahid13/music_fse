import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_enums.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/repositories/settings_repository.dart';
import '../../helpers/active_focus_request.dart';
import '../../providers/repository_providers.dart';
import '../../providers/scan_folder_provider.dart';
import '../../providers/scan_provider.dart';
import '../../providers/theme_provider.dart';
import '../dialogs/color_picker_dialog.dart';

/// Four-step first-run onboarding flow (REQUIREMENTS §7.1).
///
/// Step 0 — Welcome
/// Step 1 — Add music folders (file picker)
/// Step 2 — Choose theme & accent color
/// Step 3 — Scan + completion
///
/// On completion, writes [SettingsKeys.onboardingComplete] = true
/// and navigates to /home.
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  int _step = 0;
  static const int _totalSteps = 4;
  bool _hasStartedOnboardingScan = false;
  bool _isStartingOnboardingScan = false;

  /// Focus nodes for the primary action on each step.
  late final List<FocusNode> _stepFocusNodes;
  late final FocusNode _keyListenerFocusNode;

  @override
  void initState() {
    super.initState();
    _stepFocusNodes =
        List.generate(_totalSteps, (i) => FocusNode(debugLabel: 'Onboard-$i'));
    _keyListenerFocusNode = FocusNode(debugLabel: 'OnboardingPage-keyListener')
      ..skipTraversal = true;
    _requestStepFocus();
  }

  void _requestStepFocus() {
    scheduleActiveFocusRequest(state: this, focusNode: _stepFocusNodes[_step]);
  }

  @override
  void dispose() {
    for (final f in _stepFocusNodes) {
      f.dispose();
    }
    _keyListenerFocusNode.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_step < _totalSteps - 1) {
      final nextStep = _step + 1;
      setState(() => _step = nextStep);
      if (nextStep == 3) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _startOnboardingScanIfNeeded();
          }
        });
      }
      _requestStepFocus();
    }
  }

  void _prevStep() {
    if (_step > 0) {
      setState(() => _step--);
      _requestStepFocus();
    }
  }

  Future<void> _completeOnboarding() async {
    final repo = ref.read(settingsRepositoryProvider);
    await repo.setBool(SettingsKeys.onboardingComplete, value: true);
    if (mounted) context.go('/home');
  }

  Future<void> _startOnboardingScanIfNeeded() async {
    if (_hasStartedOnboardingScan || _isStartingOnboardingScan) {
      return;
    }

    _isStartingOnboardingScan = true;
    try {
      final folders = await ref.read(scanFoldersProvider.future);
      if (!mounted || folders.isEmpty) {
        return;
      }

      _hasStartedOnboardingScan = true;
      await ref.read(scanProvider.notifier).startScan();
    } finally {
      _isStartingOnboardingScan = false;
    }
  }

  KeyEventResult _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.escape ||
        event.logicalKey == LogicalKeyboardKey.gameButtonB ||
        event.logicalKey == LogicalKeyboardKey.keyB) {
      if (_step > 0) {
        _prevStep();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    return KeyboardListener(
      focusNode: _keyListenerFocusNode,
      onKeyEvent: _handleKey,
      child: Scaffold(
        backgroundColor: ext.bgDeep,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
                maxWidth: AppConstants.onboardingCardWidth),
            child: AnimatedSwitcher(
              duration:
                  const Duration(milliseconds: AppConstants.pageTransitionMs),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.05, 0),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: KeyedSubtree(
                key: ValueKey(_step),
                child: _buildStepCard(context, ext),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard(BuildContext context, AppThemeExtension ext) {
    final sizes = AppSizes.of(context);
    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ext.bgSurface,
        borderRadius: BorderRadius.circular(sizes.cardRadius),
        border: Border.all(color: ext.borderSubtle),
        boxShadow: const [
          BoxShadow(
            color: Color(0xAA000000),
            blurRadius: 48,
            offset: Offset(0, 16),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppConstants.dialogPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Step dot indicator
          _StepDots(current: _step, total: _totalSteps),
          const SizedBox(height: 28),
          // Step body
          switch (_step) {
            0 => _WelcomeStep(
                focusNode: _stepFocusNodes[0],
                onNext: _nextStep,
              ),
            1 => _AddFoldersStep(
                focusNode: _stepFocusNodes[1],
                onNext: _nextStep,
                onBack: _prevStep,
              ),
            2 => _ThemeStep(
                focusNode: _stepFocusNodes[2],
                onNext: _nextStep,
                onBack: _prevStep,
              ),
            3 => _DoneStep(
                focusNode: _stepFocusNodes[3],
                onFinish: _completeOnboarding,
                onBack: _prevStep,
              ),
            _ => const SizedBox.shrink(),
          },
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step dot indicator
// ---------------------------------------------------------------------------

class _StepDots extends StatelessWidget {
  const _StepDots({required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final ext = context.appTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? accent : ext.borderSubtle,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 0: Welcome
// ---------------------------------------------------------------------------

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({required this.focusNode, required this.onNext});
  final FocusNode focusNode;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(LucideIcons.music,
            size: 56, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 20),
        Text(
          l10n.appName,
          style: tt.displaySmall?.copyWith(
            color: ext.textPrimary,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'A full-screen music experience for your handheld gaming PC.',
          style: tt.bodyLarge?.copyWith(color: ext.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        FilledButton(
          focusNode: focusNode,
          onPressed: onNext,
          child: const Text('Get Started'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Step 1: Add Music Folders
// ---------------------------------------------------------------------------

class _AddFoldersStep extends ConsumerWidget {
  const _AddFoldersStep({
    required this.focusNode,
    required this.onNext,
    required this.onBack,
  });
  final FocusNode focusNode;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;
    final foldersAsync = ref.watch(scanFoldersProvider);
    final folders = foldersAsync.value ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Add Music Folders',
          style: tt.headlineMedium?.copyWith(
            color: ext.textPrimary,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Point Music FSE at where you store your music.',
          style: tt.bodyMedium?.copyWith(color: ext.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),

        // Folder list
        if (folders.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 180),
            decoration: BoxDecoration(
              color: context.appTheme.bgInput,
              borderRadius:
                  BorderRadius.circular(AppSizes.of(context).cardRadiusSm),
              border: Border.all(color: ext.borderSubtle),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: folders.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: ext.borderSubtle),
              itemBuilder: (ctx, i) => _FolderTile(
                path: folders[i].path,
                onRemove: () => ref
                    .read(scanFoldersProvider.notifier)
                    .removeFolder(folders[i].id),
              ),
            ),
          ),

        const SizedBox(height: 12),

        OutlinedButton.icon(
          focusNode: focusNode,
          onPressed: () async {
            final result = await FilePicker.getDirectoryPath(
              dialogTitle: 'Select Music Folder',
            );
            if (result != null) {
              await ref.read(scanFoldersProvider.notifier).addFolder(result);
            }
          },
          icon: const Icon(LucideIcons.folderOpen),
          label: const Text('Browse for Folder'),
        ),

        const SizedBox(height: 20),
        _NavButtons(
          onBack: onBack,
          onNext: onNext,
          nextLabel: folders.isEmpty ? 'Skip' : 'Continue',
        ),
      ],
    );
  }
}

class _FolderTile extends StatelessWidget {
  const _FolderTile({required this.path, required this.onRemove});
  final String path;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Icon(LucideIcons.folder, size: 16, color: ext.textTertiary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              path,
              style: tt.bodySmall?.copyWith(color: ext.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(LucideIcons.x, size: 14, color: ext.textTertiary),
            onPressed: onRemove,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 28,
              minHeight: 28,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 2: Theme & Accent
// ---------------------------------------------------------------------------

class _ThemeStep extends ConsumerWidget {
  const _ThemeStep({
    required this.focusNode,
    required this.onNext,
    required this.onBack,
  });
  final FocusNode focusNode;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;
    final themeState = ref.watch(themeProvider);
    final notifier = ref.read(themeProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.settingsAppearance,
          style: tt.headlineMedium?.copyWith(
            color: ext.textPrimary,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Choose your preferred look.',
          style: tt.bodyMedium?.copyWith(color: ext.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),

        // Theme mode chips
        Wrap(
          spacing: 8,
          alignment: WrapAlignment.center,
          children: [
            _ThemeChip(
              label: l10n.themeDark,
              icon: LucideIcons.moon,
              selected: themeState.mode == ThemeModeSetting.dark,
              onTap: () => notifier.setThemeMode(ThemeModeSetting.dark),
            ),
            _ThemeChip(
              label: l10n.themeLight,
              icon: LucideIcons.sun,
              selected: themeState.mode == ThemeModeSetting.light,
              onTap: () => notifier.setThemeMode(ThemeModeSetting.light),
            ),
            _ThemeChip(
              label: l10n.themeSystem,
              icon: LucideIcons.monitor,
              selected: themeState.mode == ThemeModeSetting.system,
              onTap: () => notifier.setThemeMode(ThemeModeSetting.system),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Accent color preview
        Center(
          child: GestureDetector(
            onTap: () async {
              final selection = await showColorPickerDialog(
                context,
                initial: themeState.accentColor,
                initialTextColor: themeState.accentTextColor,
              );
              if (selection != null) {
                await notifier.setAccentColor(selection.color);
                await notifier.setAccentTextColor(selection.textColor);
              }
            },
            child: Tooltip(
              message: 'Change accent color',
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: themeState.accentColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: ext.borderSubtle, width: 2),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),
        Text(
          'Tap the circle to choose an accent color',
          style: tt.bodySmall?.copyWith(color: ext.textTertiary),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 20),
        _NavButtons(
          onBack: onBack,
          onNext: onNext,
          nextFocusNode: focusNode,
          nextLabel: 'Continue',
        ),
      ],
    );
  }
}

class _ThemeChip extends StatelessWidget {
  const _ThemeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.15) : ext.bgInput,
          borderRadius: BorderRadius.circular(AppConstants.btnRadius),
          border: Border.all(
            color: selected ? accent : ext.borderSubtle,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: selected ? accent : ext.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: tt.bodyMedium?.copyWith(
                color: selected ? accent : ext.textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 3: Done / Scan
// ---------------------------------------------------------------------------

class _DoneStep extends ConsumerStatefulWidget {
  const _DoneStep({
    required this.focusNode,
    required this.onFinish,
    required this.onBack,
  });
  final FocusNode focusNode;
  final VoidCallback onFinish;
  final VoidCallback onBack;

  @override
  ConsumerState<_DoneStep> createState() => _DoneStepState();
}

class _DoneStepState extends ConsumerState<_DoneStep> {
  late final FocusNode _backFocus;
  bool? _lastWaitingForScan;

  @override
  void initState() {
    super.initState();
    _backFocus = FocusNode(debugLabel: 'Onboard-3-back');
  }

  @override
  void dispose() {
    _backFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;
    final accent = Theme.of(context).colorScheme.primary;
    final folders = ref.watch(scanFoldersProvider).value ?? const [];
    final scanState = ref.watch(scanProvider);
    final hasFolders = folders.isNotEmpty;
    final isWaitingForScan = hasFolders && !scanState.isComplete;
    final targetFocus = isWaitingForScan ? _backFocus : widget.focusNode;
    final progressValue =
        scanState.total > 0 ? scanState.progressFraction : null;
    final progressLabel = scanState.total > 0
        ? '${scanState.processed} of ${scanState.total} tracks imported'
        : (scanState.found > 0
            ? '${scanState.found} tracks found'
            : 'Preparing scan...');

    if (_lastWaitingForScan != isWaitingForScan) {
      _lastWaitingForScan = isWaitingForScan;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !targetFocus.canRequestFocus) {
          return;
        }
        targetFocus.requestFocus();
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(LucideIcons.circleCheck, size: 56, color: accent),
        const SizedBox(height: 20),
        Text(
          hasFolders && scanState.isComplete
              ? 'Scan complete'
              : "You're all set!",
          style: tt.headlineMedium?.copyWith(
            color: ext.textPrimary,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          !hasFolders
              ? 'No folders were selected during setup. You can finish onboarding now and add folders later in Settings.'
              : (scanState.isComplete
                  ? 'Your selected folders have been scanned and your library is ready.'
                  : 'Music FSE is scanning your selected folders and importing your library.'),
          style: tt.bodyMedium?.copyWith(color: ext.textSecondary),
          textAlign: TextAlign.center,
        ),
        if (hasFolders) ...[
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: progressValue,
              backgroundColor: ext.bgInput,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            progressLabel,
            style: tt.bodySmall?.copyWith(color: ext.textSecondary),
            textAlign: TextAlign.center,
          ),
          if (scanState.currentFile != null) ...[
            const SizedBox(height: 6),
            Text(
              scanState.currentFile!,
              style: tt.bodySmall?.copyWith(color: ext.textTertiary),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
        const SizedBox(height: 32),
        FilledButton(
          focusNode: widget.focusNode,
          onPressed: isWaitingForScan ? null : widget.onFinish,
          child: Text(
            hasFolders
                ? (scanState.isComplete
                    ? 'Start Using Music FSE'
                    : 'Scanning Library...')
                : 'Start Using Music FSE',
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          focusNode: _backFocus,
          onPressed: widget.onBack,
          child: const Text('Back'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shared nav buttons (Back + Next/Continue)
// ---------------------------------------------------------------------------

class _NavButtons extends StatelessWidget {
  const _NavButtons({
    required this.onBack,
    required this.onNext,
    this.nextLabel = 'Continue',
    this.nextFocusNode,
  });
  final VoidCallback onBack;
  final VoidCallback onNext;
  final String nextLabel;
  final FocusNode? nextFocusNode;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        OutlinedButton(
          onPressed: onBack,
          child: const Text('Back'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            focusNode: nextFocusNode,
            onPressed: onNext,
            child: Text(nextLabel),
          ),
        ),
      ],
    );
  }
}
