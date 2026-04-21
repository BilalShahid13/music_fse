import 'package:freezed_annotation/freezed_annotation.dart';

part 'playlist.freezed.dart';

/// A user-created or smart playlist.
///
/// [isSmart] playlists are read-only from the UI's perspective — their song
/// lists are generated dynamically by [smartRule] criteria. The database stores
/// the rule as a JSON string; the data layer interprets it.
///
/// [songCount] and [totalDurationMs] are eagerly-computed aggregates joined in
/// from PlaylistSongs — not stored as columns. They are always populated when
/// fetched via PlaylistRepository.
@freezed
abstract class Playlist with _$Playlist {
  const factory Playlist({
    required int id,
    required String name,
    String? coverArtPath,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(false) bool isSmart,

    /// JSON-encoded smart playlist rule. Only set when [isSmart] is true.
    String? smartRule,
    @Default(0) int songCount,
    @Default(0) int totalDurationMs,
  }) = _Playlist;
}
