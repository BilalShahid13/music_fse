import 'dart:convert';
import 'dart:io';
import 'package:metadata_god/metadata_god.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

import '../../core/utils/logger.dart';
import '../../domain/entities/song.dart';
import '../../domain/services/metadata_extractor.dart';

/// [MetadataExtractor] implementation using `audiotags` for tag reading and
/// `image` for album art processing.
///
/// This class is designed to be called from a background isolate — it does
/// blocking file I/O and CPU-intensive image decoding. Never call from the
/// UI thread.
///
/// NEVER throws. All errors are caught internally and fallback values are
/// returned so that a corrupt or unreadable file never stops a library scan.
final class MetadataExtractorImpl implements MetadataExtractor {
  const MetadataExtractorImpl();

  // -------------------------------------------------------------------------
  // MetadataExtractor interface
  // -------------------------------------------------------------------------

  @override
  Future<Song> extractMetadata(String filePath) async {
    try {
      final file = File(filePath);
      final stat = await file.stat();

      Metadata? meta;
      try {
        meta = await MetadataGod.readMetadata(file: filePath);
      } catch (e) {
        AppLogger.warn('Failed to read tags for $filePath: $e', tag: 'MetadataExtractor');
      }

      final filename = p.basenameWithoutExtension(filePath);

      return Song(
        id: 0,
        filePath: filePath,
        title: _nonEmpty(meta?.title) ?? filename,
        artist: _nonEmpty(meta?.artist) ?? 'Unknown Artist',
        album: _nonEmpty(meta?.album) ?? 'Unknown Album',
        albumArtist: _nonEmpty(meta?.albumArtist) ?? _nonEmpty(meta?.artist) ?? 'Unknown Artist',
        genre: _nonEmpty(meta?.genre) ?? '',
        year: meta?.year,
        trackNumber: meta?.trackNumber,
        discNumber: meta?.discNumber,
        durationMs: meta?.durationMs != null ? meta!.durationMs!.round() : 0,
        fileSize: stat.size,
        fileModifiedAt: stat.modified,
        artCachePath: null,
        dateAdded: DateTime.now(),
        playCount: 0,
        lastPlayedAt: null,
        isFavorite: false,
        isMissing: false,
      );
    } catch (e, st) {
      AppLogger.error('extractMetadata failed for $filePath', tag: 'MetadataExtractor', error: e, stackTrace: st);
      // Return a minimal fallback rather than letting the scan crash.
      return Song(
        id: 0,
        filePath: filePath,
        title: p.basenameWithoutExtension(filePath),
        artist: 'Unknown Artist',
        album: 'Unknown Album',
        albumArtist: 'Unknown Artist',
        genre: '',
        year: null,
        trackNumber: null,
        discNumber: null,
        durationMs: 0,
        fileSize: 0,
        fileModifiedAt: DateTime.now(),
        artCachePath: null,
        dateAdded: DateTime.now(),
        playCount: 0,
        lastPlayedAt: null,
        isFavorite: false,
        isMissing: false,
      );
    }
  }

  @override
  Future<String?> extractArt(String filePath, String cacheDir) async {
    try {
      final meta = await MetadataGod.readMetadata(file: filePath);
      final picture = meta.picture;
      if (picture == null) return null;

      final rawBytes = picture.data;
      if (rawBytes.isEmpty) return null;

      final bytes = rawBytes;

      final decoded = img.decodeImage(bytes);
      if (decoded == null) return null;

      // Resize to 300×300, preserving nothing larger — memory budget matters.
      final resized = img.copyResize(
        decoded,
        width: 300,
        height: 300,
        interpolation: img.Interpolation.linear,
      );

      final jpeg = img.encodeJpg(resized, quality: 85);

      // Cache key: stable hash of (albumArtist, album) so all songs in the
      // same album reuse one cached file.
      final albumArtist = _nonEmpty(meta.albumArtist) ?? _nonEmpty(meta.artist) ?? 'Unknown Artist';
      final album = _nonEmpty(meta.album) ?? 'Unknown Album';
      final cacheKey = _stableHash('$albumArtist\x00$album');
      final cachePath = p.join(cacheDir, 'art_$cacheKey.jpg');

      await File(cachePath).writeAsBytes(jpeg);
      return cachePath;
    } catch (e, st) {
      AppLogger.error('extractArt failed for $filePath', tag: 'MetadataExtractor', error: e, stackTrace: st);
      return null;
    }
  }

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  /// Returns [value] trimmed if it is non-null and non-empty, otherwise null.
  static String? _nonEmpty(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  /// Produces a stable 8-hex-character hash of [input] suitable for use in
  /// a filename. Uses a simple FNV-1a 32-bit hash — no crypto needed here.
  static String _stableHash(String input) {
    const fnvPrime = 0x01000193;
    const offsetBasis = 0x811c9dc5;

    var hash = offsetBasis;
    for (final byte in utf8.encode(input)) {
      // ignore: parameter_assignments
      hash ^= byte;
      hash = (hash * fnvPrime) & 0xFFFFFFFF;
    }

    return hash.toRadixString(16).padLeft(8, '0');
  }
}
