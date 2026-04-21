import '../repositories/song_repository.dart';
import '../../core/errors/result.dart';

final class MarkSongMissing {
  const MarkSongMissing(this._repository);

  final SongRepository _repository;

  Future<Result<void>> call(int songId, {required bool isMissing}) => _repository.markMissing(songId, isMissing: isMissing);
}
