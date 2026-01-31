import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaidya/core/widgets/divider_with_text.dart';

void main() {
  group('DividerWithText', () {
    testWidgets('shows the given text between dividers', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DividerWithText(text: 'Or'),
          ),
        ),
      );

      expect(find.text('Or'), findsOneWidget);
    });

    testWidgets('contains two dividers', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DividerWithText(text: 'Or'),
          ),
        ),
      );

      expect(find.byType(Divider), findsNWidgets(2));
    });

    testWidgets('renders with custom text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DividerWithText(text: 'Or continue with'),
          ),
        ),
      );

      expect(find.text('Or continue with'), findsOneWidget);
    });
  });
}
