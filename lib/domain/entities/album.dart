import 'package:freezed_annotation/freezed_annotation.dart';

part 'album.freezed.dart';

/// An album aggregated from songs in the library.
///
/// Not persisted directly — derived at query time from the Songs table using
/// GROUP BY (album, album_artist). The [artCachePath] comes from the first song
/// in the album that has embedded artwork.
@freezed
abstract class Album with _$Album {
  const factory Album({
    required String name,
    required String artist,
    int? year,
    String? artCachePath,
    required int songCount,
    required int totalDurationMs,
  }) = _Album;
}
