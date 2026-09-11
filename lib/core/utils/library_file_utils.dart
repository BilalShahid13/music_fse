import 'dart:io';

import 'package:path/path.dart' as p;

/// Returns a normalized absolute file path suitable for storing in the library.
String normalizeLibraryFilePath(String filePath) {
  return p.normalize(File(filePath).absolute.path);
}

/// Returns whether a file path should be ignored during library import.
bool shouldIgnoreLibraryFilePath(String filePath) {
  final name = p.basename(filePath).trim();
  if (name.isEmpty) return true;

  final lowerName = name.toLowerCase();
  return name.startsWith('._') ||
      lowerName == '.ds_store' ||
      lowerName == 'desktop.ini' ||
      lowerName == 'thumbs.db';
}