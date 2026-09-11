import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:music_fse/core/utils/library_file_utils.dart';
import 'package:music_fse/data/file_system/file_scanner_impl.dart';

void main() {
  late Directory tempDir;
  late FileScannerImpl scanner;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('music_fse_scanner_test');
    scanner = const FileScannerImpl();
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('skips AppleDouble sidecar files that mimic audio extensions', () async {
    await File('${tempDir.path}${Platform.pathSeparator}._Closer.m4a').writeAsString('ignored');
    final valid = File('${tempDir.path}${Platform.pathSeparator}Closer.m4a');
    await valid.writeAsString('audio');

    final results = await scanner.scanDirectories([tempDir.path]).toList();

    expect(results, [normalizeLibraryFilePath(valid.path)]);
  });

  test('returns normalized absolute paths for unicode filenames', () async {
    final unicodeFile = File('${tempDir.path}${Platform.pathSeparator}葉問3.m4a');
    await unicodeFile.writeAsString('audio');

    final results = await scanner.scanDirectories([tempDir.path]).toList();

    expect(results, [normalizeLibraryFilePath(unicodeFile.path)]);
    expect(results.single, contains('葉問3.m4a'));
  });
}