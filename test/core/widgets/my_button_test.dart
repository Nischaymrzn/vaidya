import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaidya/core/widgets/my_button.dart';

void main() {
  group('MyButton', () {
    testWidgets('shows the given text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MyButton(
              text: 'Login',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MyButton(
              text: 'Submit',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(MyButton));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('does not call onPressed when isLoading is true', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MyButton(
              text: 'Login',
              onPressed: () => pressed = true,
              isLoading: true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(MyButton));
      await tester.pump();

      expect(pressed, isFalse);
    });

    testWidgets('shows Loading... when isLoading is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MyButton(
              text: 'Login',
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('allows null onPressed (disabled button)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MyButton(
              text: 'Disabled',
              onPressed: null,
            ),
          ),
        ),
      );

      expect(find.text('Disabled'), findsOneWidget);
      await tester.tap(find.byType(MyButton));
      await tester.pump();
      // No crash means disabled tap was handled
    });
  });
}
