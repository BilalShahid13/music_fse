import '../entities/song.dart';

/// Contract for extracting audio metadata and album artwork from file paths.
///
/// Both methods are designed to be called from a background isolate
/// (via [Isolate.run] or [compute]) — never on the UI thread.
///
/// Implementations MUST:
/// - Never throw. Return a best-effort [Song] with fallback values on failure.
/// - Fall back to the filename (without extension) for [Song.title] when the
///   tag is empty or absent.
/// - Fall back to 'Unknown Artist' / 'Unknown Album' for empty artist/album.
abstract class MetadataExtractor {
  /// Reads ID3/Vorbis/AAC/etc. tags from [filePath] and returns a [Song] with
  /// all available metadata populated. The [Song.id] will be 0 — the actual
  /// row ID is assigned on database insert.
  Future<Song> extractMetadata(String filePath);

  /// Extracts embedded album artwork from [filePath], resizes it to a
  /// 300×300 thumbnail, writes it to [cacheDir], and returns the absolute
  /// path to the written file.
  ///
  /// Returns null if the file has no embedded artwork or on any read/write
  /// error. The cache filename is derived from the file path hash so that
  /// multiple songs in the same album share a single cached image.
  Future<String?> extractArt(String filePath, String cacheDir);
}
