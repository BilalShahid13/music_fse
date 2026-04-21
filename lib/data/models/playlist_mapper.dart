import '../../domain/entities/playlist.dart' as domain;
import '../datasources/local/playlist_dao.dart';

/// Converts a [PlaylistRow] (DAO aggregate result) into the domain [domain.Playlist].
extension PlaylistRowMapper on PlaylistRow {
  domain.Playlist toEntity() => domain.Playlist(
        id: playlist.id,
        name: playlist.name,
        coverArtPath: playlist.coverArtPath,
        createdAt: playlist.createdAt,
        updatedAt: playlist.updatedAt,
        isSmart: playlist.isSmart,
        smartRule: playlist.smartRule,
        songCount: songCount,
        totalDurationMs: totalDurationMs,
      );
}
