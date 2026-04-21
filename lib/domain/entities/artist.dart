import 'package:freezed_annotation/freezed_annotation.dart';

part 'artist.freezed.dart';

/// An artist aggregated from songs in the library.
///
/// Derived at query time via GROUP BY on the artist column.
/// The [artCachePath] is the art from the most-played or most-recently-added
/// album belonging to this artist.
@freezed
abstract class Artist with _$Artist {
  const factory Artist({
    required String name,
    required int songCount,
    required int albumCount,
    String? artCachePath,
  }) = _Artist;
}
