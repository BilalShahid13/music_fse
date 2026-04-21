import '../../domain/entities/scan_folder.dart' as domain;
import '../datasources/local/database.dart';

/// Converts a Drift [ScanFolder] row into a domain [domain.ScanFolder].
extension ScanFolderRowMapper on ScanFolder {
  domain.ScanFolder toEntity() => domain.ScanFolder(
        id: id,
        path: path,
        enabled: enabled,
        lastScannedAt: lastScannedAt,
      );
}
