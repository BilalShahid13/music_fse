import '../entities/song.dart';
import '../repositories/song_repository.dart';
import '../../core/errors/result.dart';

/// Returns the direct sub-folders and songs for a folder path.
///
/// Pass [parentPath] = null for the top-level view (root folders registered as
/// scan directories). The returned [subFolders] are immediate children only,
/// not recursive descendants.
final class GetFolderContents {
  const GetFolderContents(this._repository);

  final SongRepository _repository;

  Future<Result<({List<String> subFolders, List<Song> songs})>> call(
    String? parentPath,
  ) async {
    if (parentPath == null) {
      // Top-level: just return root folders, no songs at this level.
      final foldersResult = await _repository.getTopLevelFolders();
      return foldersResult.map(
        (folders) => (subFolders: folders, songs: <Song>[]),
      );
    }

    // Fetch sub-folders and songs in parallel.
    final results = await Future.wait([
      _repository.getSubFolders(parentPath),
      _repository.getSongsByFolder(parentPath),
    ]);

    final foldersResult = results[0] as Result<List<String>>;
    final songsResult = results[1] as Result<List<Song>>;

    // If the folder lookup itself failed, propagate the error.
    if (foldersResult.isFailure) return Result.failure(foldersResult.errorOrNull!);

    return Result.success((
      subFolders: foldersResult.valueOrNull!,
      songs: songsResult.valueOrNull ?? [],
    ));
  }
}
