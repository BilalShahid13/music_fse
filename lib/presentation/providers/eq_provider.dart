import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart' show ProviderListenableSelect;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/eq_preset.dart';
import '../../domain/repositories/settings_repository.dart';
import 'repository_providers.dart';
import 'use_case_providers.dart';

part 'eq_provider.g.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

/// Snapshot of the equalizer subsystem.
@immutable
final class EqState {
  const EqState({
    this.isEnabled = false,
    this.presets = const [],
    this.selectedPresetId,
    this.bands = const [],
  });

  final bool isEnabled;
  final List<EqPreset> presets;

  /// ID of the currently selected preset, or null if none is loaded.
  final int? selectedPresetId;

  /// The 10 gain values (dB) currently applied, one per frequency band.
  ///
  /// These may differ from the stored preset when the user has adjusted
  /// individual bands without saving.
  final List<double> bands;

  EqPreset? get selectedPreset =>
      selectedPresetId == null ? null : presets.where((p) => p.id == selectedPresetId).firstOrNull;

  bool get hasBands => bands.length == AppConstants.eqBandCount;

  EqState copyWith({
    bool? isEnabled,
    List<EqPreset>? presets,
    Object? selectedPresetId = _sentinel,
    List<double>? bands,
  }) =>
      EqState(
        isEnabled: isEnabled ?? this.isEnabled,
        presets: presets ?? this.presets,
        selectedPresetId: selectedPresetId == _sentinel
            ? this.selectedPresetId
            : selectedPresetId as int?,
        bands: bands ?? this.bands,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EqState &&
          other.isEnabled == isEnabled &&
          other.selectedPresetId == selectedPresetId &&
          listEquals(other.bands, bands) &&
          listEquals(other.presets, presets);

  @override
  int get hashCode =>
      Object.hash(isEnabled, selectedPresetId, Object.hashAll(bands), Object.hashAll(presets));
}

// Sentinel for null-able copyWith field.
const Object _sentinel = Object();

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
class EqNotifier extends _$EqNotifier {
  @override
  Future<EqState> build() async {
    await _loadPresets();
    return state.requireValue;
  }

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  Future<void> _loadPresets() async {
    final presetsUseCase = ref.read(getEqPresetsProvider);
    final settingsRepo = ref.read(settingsRepositoryProvider);

    final [presetsResult, enabledResult, presetIdResult] = await Future.wait([
      presetsUseCase.call(),
      settingsRepo.getBool(SettingsKeys.eqEnabled),
      settingsRepo.getInt(SettingsKeys.activeEqPresetId),
    ]);

    // Silence type warnings — all three results are of different types but we
    // captured them as dynamic via Future.wait on a heterogeneous list.
    final presets = (presetsResult as dynamic).value as List<EqPreset>? ?? const <EqPreset>[];
    final isEnabled = (enabledResult as dynamic).value as bool? ?? false;
    final presetId = (presetIdResult as dynamic).value as int?;

    // Resolve bands from the selected preset, defaulting to flat (0 dB).
    final selectedPreset = presetId == null
        ? presets.where((p) => p.isBuiltin).firstOrNull
        : presets.where((p) => p.id == presetId).firstOrNull;

    final bands = selectedPreset?.bands ??
        List<double>.filled(AppConstants.eqBandCount, 0.0);

    state = AsyncData(EqState(
      isEnabled: isEnabled,
      presets: List.unmodifiable(presets),
      selectedPresetId: selectedPreset?.id,
      bands: List.unmodifiable(bands),
    ));
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Enables or disables the equalizer and persists the setting.
  Future<void> toggleEq({required bool enabled}) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(isEnabled: enabled));
    final repo = ref.read(settingsRepositoryProvider);
    await repo.setBool(SettingsKeys.eqEnabled, value: enabled);
  }

  /// Selects [presetId] and loads its bands.
  Future<void> selectPreset(int presetId) async {
    final current = state.value;
    if (current == null) return;
    final preset = current.presets.where((p) => p.id == presetId).firstOrNull;
    if (preset == null) return;
    state = AsyncData(current.copyWith(
      selectedPresetId: presetId,
      bands: List.unmodifiable(preset.bands),
    ));
    final repo = ref.read(settingsRepositoryProvider);
    await repo.setInt(SettingsKeys.activeEqPresetId, presetId);
  }

  /// Adjusts the gain for a single frequency band.
  ///
  /// [bandIndex] must be in [0, AppConstants.eqBandCount).
  /// [gainDb] is clamped to ±12 dB.
  void setBandValue(int bandIndex, double gainDb) {
    final current = state.value;
    if (current == null) return;
    if (bandIndex < 0 || bandIndex >= AppConstants.eqBandCount) return;

    final newBands = List<double>.from(current.bands.length == AppConstants.eqBandCount
        ? current.bands
        : List<double>.filled(AppConstants.eqBandCount, 0.0));
    newBands[bandIndex] = gainDb.clamp(-12.0, 12.0);

    state = AsyncData(current.copyWith(bands: List.unmodifiable(newBands)));
  }

  /// Saves the current [bands] as a new user preset named [name].
  ///
  /// Returns the new preset's ID, or -1 on failure.
  Future<int> saveCustomPreset(String name) async {
    final current = state.value;
    if (current == null || !current.hasBands) return -1;
    final useCase = ref.read(saveEqPresetProvider);
    final result = await useCase.call(name, List<double>.from(current.bands));
    return result.when(
      success: (id) async {
        // Reload presets so the new entry appears in the list.
        await _loadPresets();
        // Select the newly created preset.
        await selectPreset(id);
        return id;
      },
      failure: (e) {
        AppLogger.error(
          'EqNotifier: saveCustomPreset failed',
          tag: 'EqNotifier',
          error: e,
        );
        return -1;
      },
    );
  }

  /// Deletes user preset [id] and falls back to the flat preset.
  Future<void> deletePreset(int id) async {
    final useCase = ref.read(deleteEqPresetProvider);
    final result = await useCase.call(id);
    result.when(
      success: (_) async {
        await _loadPresets();
        // If the deleted preset was selected, fall back to the flat preset.
        final current = state.value;
        if (current != null && current.selectedPresetId == id) {
          final flat = current.presets.where((p) => p.isBuiltin).firstOrNull;
          if (flat != null) await selectPreset(flat.id);
        }
      },
      failure: (e) => AppLogger.error(
        'EqNotifier: deletePreset failed',
        tag: 'EqNotifier',
        error: e,
      ),
    );
  }

  /// Resets bands to the currently selected preset's stored values.
  void resetToPreset() {
    final current = state.value;
    if (current?.selectedPreset == null) return;
    state = AsyncData(current!.copyWith(
      bands: List.unmodifiable(current.selectedPreset!.bands),
    ));
  }
}

// ---------------------------------------------------------------------------
// Derived
// ---------------------------------------------------------------------------

/// Whether the equalizer is currently enabled.
@riverpod
bool isEqEnabled(Ref ref) =>
    ref.watch(eqProvider.select((s) => s.value?.isEnabled ?? false));

/// The current per-band gains as an unmodifiable list.
@riverpod
List<double> eqBands(Ref ref) =>
    ref.watch(eqProvider.select((s) => s.value?.bands ?? const []));
