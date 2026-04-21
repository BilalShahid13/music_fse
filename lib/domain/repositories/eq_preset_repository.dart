import '../entities/eq_preset.dart';
import '../../core/errors/result.dart';

/// Contract for managing equalizer presets.
///
/// Built-in presets (Flat, Bass Boost, etc.) are seeded at first launch and
/// cannot be deleted. User-created presets can be freely modified and removed.
abstract class EqPresetRepository {
  /// Returns all presets — built-ins first, then user presets alphabetically.
  Future<Result<List<EqPreset>>> getAll();

  Future<Result<EqPreset>> getById(int id);

  /// Creates a new user preset with the given name and [bands] values.
  /// Returns the new preset's ID.
  Future<Result<int>> createPreset(String name, List<double> bands);

  /// Updates the [bands] of preset [id]. Only permitted on non-builtin presets.
  Future<Result<void>> updatePreset(int id, List<double> bands);

  /// Deletes preset [id]. Only permitted on non-builtin presets.
  Future<Result<void>> deletePreset(int id);
}
