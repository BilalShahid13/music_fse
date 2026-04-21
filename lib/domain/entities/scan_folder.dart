import 'package:freezed_annotation/freezed_annotation.dart';

part 'scan_folder.freezed.dart';

/// A directory that the library scanner watches for audio files.
///
/// [enabled] lets the user temporarily exclude a folder from scanning without
/// removing it from the list. [lastScannedAt] is updated at the end of each
/// successful scan of this folder.
@freezed
abstract class ScanFolder with _$ScanFolder {
  const factory ScanFolder({
    required int id,
    required String path,
    @Default(true) bool enabled,
    DateTime? lastScannedAt,
  }) = _ScanFolder;
}
