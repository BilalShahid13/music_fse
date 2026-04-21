import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:music_fse/presentation/widgets/empty_state.dart';

import '../../helpers/test_app.dart';

void main() {
  testWidgets('displays icon and title', (tester) async {
    await tester.pumpWidget(testApp(
      child: const EmptyState(
        icon: LucideIcons.music,
        title: 'No songs',
      ),
    ));

    expect(find.text('No songs'), findsOneWidget);
    expect(find.byIcon(LucideIcons.music), findsOneWidget);
  });

  testWidgets('displays subtitle when provided', (tester) async {
    await tester.pumpWidget(testApp(
      child: const EmptyState(
        icon: LucideIcons.music,
        title: 'Empty',
        subtitle: 'Add some music',
      ),
    ));

    expect(find.text('Add some music'), findsOneWidget);
  });

  testWidgets('hides subtitle when null', (tester) async {
    await tester.pumpWidget(testApp(
      child: const EmptyState(
        icon: LucideIcons.music,
        title: 'Empty',
      ),
    ));

    expect(find.text('Empty'), findsOneWidget);
  });

  testWidgets('shows action button and handles tap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(testApp(
      child: EmptyState(
        icon: LucideIcons.music,
        title: 'Empty',
        actionLabel: 'Add Songs',
        onAction: () => tapped = true,
      ),
    ));

    expect(find.text('Add Songs'), findsOneWidget);
    await tester.tap(find.text('Add Songs'));
    expect(tapped, true);
  });

  testWidgets('hides button when actionLabel is null', (tester) async {
    await tester.pumpWidget(testApp(
      child: const EmptyState(
        icon: LucideIcons.music,
        title: 'Empty',
      ),
    ));

    expect(find.byType(FilledButton), findsNothing);
  });
}
