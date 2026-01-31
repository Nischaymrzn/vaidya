import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaidya/core/widgets/my_text_form_field.dart';

void main() {
  group('MyTextFormField', () {
    testWidgets('shows hint text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MyTextFormField(
              text: 'Enter your email',
              validationMessage: 'Email is required',
            ),
          ),
        ),
      );

      expect(find.text('Enter your email'), findsOneWidget);
    });

    testWidgets('accepts and displays user input', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MyTextFormField(
              controller: controller,
              text: 'Enter name',
              validationMessage: 'Required',
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'John');
      await tester.pump();

      expect(controller.text, 'John');
    });

    testWidgets('shows validation error when empty and validated', (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: MyTextFormField(
                text: 'Email',
                validationMessage: 'Email is required',
              ),
            ),
          ),
        ),
      );

      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('when obscureText is true, has visibility toggle button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MyTextFormField(
              text: 'Password',
              validationMessage: 'Required',
              obscureText: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('tapping visibility toggle switches icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MyTextFormField(
              text: 'Password',
              validationMessage: 'Required',
              obscureText: true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });
  });
}
