import 'package:drift/drift.dart';

import '../../domain/entities/song.dart' as domain;
import '../datasources/local/database.dart';

/// Extension on Drift's generated [Song] row type to produce a domain entity.
extension SongRowMapper on Song {
  domain.Song toEntity() => domain.Song(
        id: id,
        filePath: filePath,
        title: title,
        artist: artist,
        album: album,
        albumArtist: albumArtist,
        genre: genre,
        year: year,
        trackNumber: trackNumber,
        discNumber: discNumber,
        durationMs: durationMs,
        fileSize: fileSize,
        fileModifiedAt: fileModifiedAt,
        artCachePath: artCachePath,
        dateAdded: dateAdded,
        playCount: playCount,
        lastPlayedAt: lastPlayedAt,
        isFavorite: isFavorite,
        isMissing: isMissing,
      );
}

/// Converts a domain [domain.Song] into a Drift [SongsCompanion] for upsert.
/// The [id] field is absent — Drift assigns it on insert (autoIncrement).
extension SongEntityMapper on domain.Song {
  SongsCompanion toCompanion() => SongsCompanion(
        // id is omitted so autoIncrement works on insert; the unique
        // filePath constraint handles conflict resolution.
        filePath: Value(filePath),
        title: Value(title),
        artist: Value(artist),
        album: Value(album),
        albumArtist: Value(albumArtist),
        genre: Value(genre),
        year: Value(year),
        trackNumber: Value(trackNumber),
        discNumber: Value(discNumber),
        durationMs: Value(durationMs),
        fileSize: Value(fileSize),
        fileModifiedAt: Value(fileModifiedAt),
        artCachePath: Value(artCachePath),
        dateAdded: Value(dateAdded),
        playCount: Value(playCount),
        lastPlayedAt: Value(lastPlayedAt),
        isFavorite: Value(isFavorite),
        isMissing: Value(isMissing),
      );
}
