import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('widget test bootstrap is valid', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('Vaidya test bootstrap'))),
    );

    expect(find.text('Vaidya test bootstrap'), findsOneWidget);
  });
}
