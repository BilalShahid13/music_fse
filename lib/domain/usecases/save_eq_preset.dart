import '../repositories/eq_preset_repository.dart';
import '../../core/errors/result.dart';

/// Saves a new user EQ preset and returns its ID.
///
/// [bands] must contain exactly [AppConstants.eqBandCount] (10) values.
final class SaveEqPreset {
  const SaveEqPreset(this._repository);

  final EqPresetRepository _repository;

  Future<Result<int>> call(String name, List<double> bands) => _repository.createPreset(name, bands);
}
