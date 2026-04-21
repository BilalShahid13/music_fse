import 'package:freezed_annotation/freezed_annotation.dart';

part 'genre.freezed.dart';

/// A genre aggregated from songs in the library.
///
/// Derived at query time via GROUP BY on the genre column.
/// Genres with an empty string value are excluded.
@freezed
abstract class Genre with _$Genre {
  const factory Genre({
    required String name,
    required int songCount,
  }) = _Genre;
}
