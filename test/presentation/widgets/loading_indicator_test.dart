import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_fse/presentation/widgets/loading_indicator.dart';

import '../../helpers/test_app.dart';

void main() {
  testWidgets('shows spinner', (tester) async {
    await tester.pumpWidget(testApp(
      child: const LoadingIndicator(),
    ));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows message when provided', (tester) async {
    await tester.pumpWidget(testApp(
      child: const LoadingIndicator(message: 'Loading...'),
    ));

    expect(find.text('Loading...'), findsOneWidget);
  });

  testWidgets('hides message when null', (tester) async {
    await tester.pumpWidget(testApp(
      child: const LoadingIndicator(),
    ));

    // Only spinner, no text
    expect(find.byType(Text), findsNothing);
  });
}
