import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studymate/pages/intro_page.dart';
import 'package:studymate/pages/LoginPage.dart';

void main() {
  testWidgets('IntroPage navigates to LoginPage after delay', (WidgetTester tester) async {
    // Build the IntroPage widget.
    await tester.pumpWidget(MaterialApp(home: IntroPage()));

    // Verify that the image is being shown.
    expect(find.byType(Image), findsOneWidget);

    // Fast-forward until the delayed task is triggered (after 2 seconds).
    await tester.pumpAndSettle(Duration(seconds: 2));

    // Verify that the app navigates to the LoginPage.
    expect(find.byType(LoginPage), findsOneWidget);
  });
}