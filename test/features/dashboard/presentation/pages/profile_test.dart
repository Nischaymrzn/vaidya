import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vaidya/core/services/storage/user_session_service.dart';
import 'package:vaidya/features/profile/presentation/state/profile_state.dart';
import 'package:vaidya/features/profile/presentation/pages/profile_screen.dart';
import 'package:vaidya/features/profile/presentation/view_model/profile_viewmodel.dart';

class MockUserSessionService extends Mock implements UserSessionService {}

class MockProfileViewModel extends Notifier<ProfileState>
    implements ProfileViewModel {
  @override
  ProfileState build() => const ProfileState(status: ProfileStatus.loaded);

  @override
  Future<void> load(String userId, {bool forceLoading = false}) async {}

  @override
  Future<void> loadPaymentStatus() async {}

  @override
  Future<String?> startPremiumCheckout() async => null;

  @override
  Future<bool> update(
    String userId,
    Map<String, dynamic> payload, {
    String? imagePath,
  }) async => true;

  @override
  Future<bool> updatePassword(String userId, String newPassword) async => true;

  @override
  Future<bool> delete(String userId) async => true;

  @override
  void clearMessages() {}

  @override
  void setPremiumStateForTests({
    required bool isPremium,
    required String plan,
  }) {}
}

void main() {
  late MockUserSessionService mockSession;
  late MockProfileViewModel mockProfileViewModel;

  setUp(() {
    mockSession = MockUserSessionService();
    mockProfileViewModel = MockProfileViewModel();

    when(() => mockSession.getCurrentUserFullName()).thenReturn('Test User');
    when(
      () => mockSession.getCurrentUserEmail(),
    ).thenReturn('test@example.com');
    when(() => mockSession.getCurrentUserProfilePicture()).thenReturn(null);
    when(() => mockSession.getCurrentUserId()).thenReturn('user-1');
    when(() => mockSession.getCurrentUserIsPremium()).thenReturn(false);
  });

  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [
        userSessionServiceProvider.overrideWithValue(mockSession),
        profileViewModelProvider.overrideWith(() => mockProfileViewModel),
      ],
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
