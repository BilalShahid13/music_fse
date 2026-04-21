import '../repositories/playlist_repository.dart';
import '../../core/errors/result.dart';

/// Creates a new empty playlist and returns its ID.
final class CreatePlaylist {
  const CreatePlaylist(this._repository);

  final PlaylistRepository _repository;

  Future<Result<int>> call(String name) => _repository.createPlaylist(name);
}
