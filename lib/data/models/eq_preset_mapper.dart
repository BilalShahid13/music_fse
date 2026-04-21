import 'dart:convert';

import '../../domain/entities/eq_preset.dart' as domain;
import '../datasources/local/database.dart';

/// Converts a Drift [EqPreset] row into a domain [domain.EqPreset].
///
/// [EqPreset.bandsJson] is a JSON-encoded [List<double>] (10 values, one per
/// band). Malformed JSON falls back to an all-zero flat preset.
extension EqPresetRowMapper on EqPreset {
  domain.EqPreset toEntity() => domain.EqPreset(
        id: id,
        name: name,
        isBuiltin: isBuiltin,
        bands: _parseBands(bandsJson),
        createdAt: createdAt,
      );
}

/// Encodes a [List<double>] band list into a JSON string for storage.
String eqBandsToJson(List<double> bands) => jsonEncode(bands);

List<double> _parseBands(String json) {
  try {
    final decoded = jsonDecode(json) as List<dynamic>;
    return decoded.map((e) => (e as num).toDouble()).toList();
  } catch (_) {
    // Return a flat (all-zero) preset on parse failure.
    return List.filled(10, 0.0);
  }
}
