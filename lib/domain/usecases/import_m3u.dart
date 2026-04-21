import '../repositories/playlist_repository.dart';
import '../../core/errors/result.dart';

/// Imports a playlist from an M3U or M3U8 file.
///
/// Returns the new playlist's ID.
final class ImportM3u {
  const ImportM3u(this._repository);

  final PlaylistRepository _repository;

  Future<Result<int>> call(String filePath) => _repository.importM3u(filePath);
}
