import '../entities/eq_preset.dart';
import '../repositories/eq_preset_repository.dart';
import '../../core/errors/result.dart';

/// Returns all equalizer presets — built-ins first, then user presets.
final class GetEqPresets {
  const GetEqPresets(this._repository);

  final EqPresetRepository _repository;

  Future<Result<List<EqPreset>>> call() => _repository.getAll();
}
