import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:music_fse/presentation/widgets/drop_overlay.dart';

import '../../helpers/test_app.dart';

void main() {
  testWidgets('shows icon and instruction text', (tester) async {
    await tester.pumpWidget(testApp(
      child: const Stack(
        children: [
          SizedBox(width: 400, height: 400),
          DropOverlay(),
        ],
      ),
    ));

    expect(find.byIcon(LucideIcons.folderInput), findsOneWidget);
    expect(find.text('Drop files here to add to library'), findsOneWidget);
  });
}
