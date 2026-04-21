import 'package:flutter/foundation.dart';

class LibraryTabCommand {
  const LibraryTabCommand({required this.id, required this.delta});

  final int id;
  final int delta;
}

final ValueNotifier<LibraryTabCommand?> libraryTabCommand = ValueNotifier<LibraryTabCommand?>(null);
