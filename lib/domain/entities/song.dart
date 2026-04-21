import 'package:freezed_annotation/freezed_annotation.dart';

part 'song.freezed.dart';

/// Core song entity — immutable value object representing a single audio file.
///
/// Constructed from metadata extracted at scan time and persisted in the
/// database. Never instantiated directly in the UI — always sourced via a
/// repository or use case.
@freezed
abstract class Song with _$Song {
  const factory Song({
    required int id,
    required String filePath,
    required String title,
    required String artist,
    required String album,
    required String albumArtist,
    required String genre,
    int? year,
    int? trackNumber,
    int? discNumber,
    required int durationMs,
    required int fileSize,
    required DateTime fileModifiedAt,

    /// Absolute path to the cached 300×300 thumbnail, or null if none.
    String? artCachePath,
    required DateTime dateAdded,
    @Default(0) int playCount,
    DateTime? lastPlayedAt,
    @Default(false) bool isFavorite,

    /// True when the source file could not be found on disk.
    /// Set by the playback layer when file-not-found is encountered.
    @Default(false) bool isMissing,
  }) = _Song;
}
