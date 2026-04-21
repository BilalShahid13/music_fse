import 'package:freezed_annotation/freezed_annotation.dart';

part 'eq_preset.freezed.dart';

/// An equalizer preset with per-band gain values.
///
/// [isBuiltin] presets (Flat, Bass Boost, etc.) are seeded at first launch and
/// cannot be deleted by the user. [bands] contains exactly
/// [AppConstants.eqBandCount] (10) gain values in dB, one per frequency band,
/// matching [AppConstants.eqBandFrequencies].
@freezed
abstract class EqPreset with _$EqPreset {
  const factory EqPreset({
    required int id,
    required String name,
    @Default(false) bool isBuiltin,

    /// 10 gain values in dB, corresponding to [AppConstants.eqBandFrequencies].
    required List<double> bands,
    required DateTime createdAt,
  }) = _EqPreset;
}
