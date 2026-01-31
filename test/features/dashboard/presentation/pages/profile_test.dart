import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vaidya/core/services/storage/user_session_service.dart';
import 'package:vaidya/features/dashboard/presentation/pages/profile.dart';

class MockUserSessionService extends Mock implements UserSessionService {}

void main() {
  late MockUserSessionService mockSession;

  setUp(() {
    mockSession = MockUserSessionService();

    when(() => mockSession.getCurrentUserFullName()).thenReturn('Test User');
    when(
      () => mockSession.getCurrentUserEmail(),
    ).thenReturn('test@example.com');
    when(() => mockSession.getCurrentUserProfilePicture()).thenReturn(null);
    when(() => mockSession.getCurrentUserId()).thenReturn('user-1');
  });

  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [userSessionServiceProvider.overrideWithValue(mockSession)],
      child: const MaterialApp(home: ProfileScreen()),
    );
  }

  testWidgets('shows profile title, name and email', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('Test User'), findsOneWidget);
    expect(find.text('test@example.com'), findsOneWidget);
  });

  testWidgets('shows account, general and support sections', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Account'), findsOneWidget);
    expect(find.text('General'), findsOneWidget);
    expect(find.text('Support'), findsOneWidget);
  });
}
