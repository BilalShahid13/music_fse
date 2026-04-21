import '../repositories/eq_preset_repository.dart';
import '../../core/errors/result.dart';

/// Deletes a user EQ preset by ID.
///
/// Only permitted on non-builtin presets. The repository implementation
/// enforces this constraint.
final class DeleteEqPreset {
  const DeleteEqPreset(this._repository);

  final EqPresetRepository _repository;

  Future<Result<void>> call(int id) => _repository.deletePreset(id);
}
