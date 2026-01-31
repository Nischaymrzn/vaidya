import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaidya/core/widgets/google_login_button.dart';

void main() {
  group('GoogleLoginButton', () {
    testWidgets('shows Login with Google text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoogleLoginButton(onPressed: () {}),
          ),
        ),
      );

      expect(find.text('Login with Google'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoogleLoginButton(
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GoogleLoginButton));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('is an OutlinedButton', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoogleLoginButton(onPressed: () {}),
          ),
        ),
      );

      expect(find.byType(OutlinedButton), findsOneWidget);
    });
  });
}
