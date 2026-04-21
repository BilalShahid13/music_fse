import '../repositories/playlist_repository.dart';
import '../../core/errors/result.dart';

/// Exports a playlist to an M3U file.
///
/// Returns the absolute path to the created file so it can be shown in a
/// toast notification or opened in the file manager.
final class ExportM3u {
  const ExportM3u(this._repository);

  final PlaylistRepository _repository;

  Future<Result<String>> call(int playlistId) => _repository.exportM3u(playlistId);
}
