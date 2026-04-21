import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:music_fse/presentation/widgets/art_placeholder.dart';

import '../../helpers/test_app.dart';

void main() {
  testWidgets('renders with default music icon', (tester) async {
    await tester.pumpWidget(testApp(
      child: const ArtPlaceholder(size: 100),
    ));

    expect(find.byIcon(LucideIcons.music), findsOneWidget);
  });

  testWidgets('renders with custom icon', (tester) async {
    await tester.pumpWidget(testApp(
      child: const ArtPlaceholder(size: 100, icon: LucideIcons.user),
    ));

    expect(find.byIcon(LucideIcons.user), findsOneWidget);
  });

  testWidgets('respects size parameter', (tester) async {
    await tester.pumpWidget(testApp(
      child: const ArtPlaceholder(size: 48),
    ));

    final container = tester.widget<Container>(find.byType(Container).first);
    final constraints = container.constraints;
    expect(constraints?.maxWidth ?? container.constraints?.minWidth, 48);
  });
}
