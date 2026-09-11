import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:music_fse/data/metadata/metadata_extractor_impl.dart';

void main() {
  late Directory tempDir;
  late Directory cacheDir;
  late MetadataExtractorImpl extractor;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('music_fse_metadata_test');
    cacheDir = Directory('${tempDir.path}${Platform.pathSeparator}cache');
    extractor = const MetadataExtractorImpl();
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  Future<void> writeJpeg(String path) async {
    final image = img.Image(width: 12, height: 12);
    img.fill(image, color: img.ColorRgb8(255, 120, 0));
    await File(path).writeAsBytes(img.encodeJpg(image));
  }

  test('falls back to Folder.jpg when embedded art is unavailable', () async {
    final audioFile = File('${tempDir.path}${Platform.pathSeparator}track.m4a');
    await audioFile.writeAsString('not real audio');
    await writeJpeg('${tempDir.path}${Platform.pathSeparator}Folder.jpg');

    final result = await extractor.extractArt(audioFile.path, cacheDir.path);

    expect(result, isNotNull);
    expect(await File(result!).exists(), isTrue);
  });

  test('falls back to AlbumArtSmall.jpg when present', () async {
    final audioFile = File('${tempDir.path}${Platform.pathSeparator}track.m4a');
    await audioFile.writeAsString('not real audio');
    await writeJpeg('${tempDir.path}${Platform.pathSeparator}AlbumArtSmall.jpg');

    final result = await extractor.extractArt(audioFile.path, cacheDir.path);

    expect(result, isNotNull);
    expect(await File(result!).exists(), isTrue);
  });
}