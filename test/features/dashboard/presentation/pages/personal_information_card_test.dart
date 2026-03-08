import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vaidya/core/services/storage/user_session_service.dart';
import 'package:vaidya/features/profile/presentation/pages/personal_information_screen.dart';
import 'package:vaidya/features/profile/presentation/state/profile_state.dart';
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
  late MockUserSessionService mockUserSessionService;
  late MockProfileViewModel mockProfileViewModel;

  setUp(() {
    mockUserSessionService = MockUserSessionService();
    mockProfileViewModel = MockProfileViewModel();
    SharedPreferences.setMockInitialValues({});

    when(() => mockUserSessionService.getCurrentUserId()).thenReturn('user-1');
    when(
      () => mockUserSessionService.getCurrentUserPhoneNumber(),
    ).thenReturn('');
    when(() => mockUserSessionService.getCurrentUserEmail()).thenReturn('');
    when(
      () => mockUserSessionService.getCurrentUserProfilePicture(),
    ).thenReturn(null);
    when(() => mockUserSessionService.getCurrentUserFullName()).thenReturn('');
    when(
      () => mockUserSessionService.getCurrentUserIsPremium(),
    ).thenReturn(false);
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        userSessionServiceProvider.overrideWithValue(mockUserSessionService),
        profileViewModelProvider.overrideWith(() => mockProfileViewModel),
      ],
      child: const MaterialApp(home: PersonalInformationScreen()),
    );
  }

  group('PersonalInformationScreen', () {
    testWidgets('renders AppBar with correct title', (tester) async {
      when(
        () => mockUserSessionService.getCurrentUserFullName(),
      ).thenReturn('John Doe');
      when(
        () => mockUserSessionService.getCurrentUserEmail(),
      ).thenReturn('john@example.com');
      when(
        () => mockUserSessionService.getCurrentUserProfilePicture(),
      ).thenReturn(null);

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Personal Information'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('displays editable fields for name and phone', (tester) async {
      when(
        () => mockUserSessionService.getCurrentUserFullName(),
      ).thenReturn('Nischay Maharjan');
      when(
        () => mockUserSessionService.getCurrentUserEmail(),
      ).thenReturn('nischaymaharjan@gmail.com');
      when(
        () => mockUserSessionService.getCurrentUserProfilePicture(),
      ).thenReturn(null);

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Full name'), findsOneWidget);
      expect(find.text('Phone'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets('displays CircleAvatar for profile picture', (tester) async {
      when(
        () => mockUserSessionService.getCurrentUserFullName(),
      ).thenReturn('Nischay Maharjan');
      when(
        () => mockUserSessionService.getCurrentUserEmail(),
      ).thenReturn('nischaymaharjan@gmail.com');
      when(
        () => mockUserSessionService.getCurrentUserProfilePicture(),
      ).thenReturn(null);

      await tester.pumpWidget(createTestWidget());

      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('displays Save changes button', (tester) async {
      when(
        () => mockUserSessionService.getCurrentUserFullName(),
      ).thenReturn('Nischay Maharjan');
      when(
        () => mockUserSessionService.getCurrentUserEmail(),
      ).thenReturn('nischaymaharjan@gmail.com');
      when(
        () => mockUserSessionService.getCurrentUserProfilePicture(),
      ).thenReturn(null);

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Save changes'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('Save button is disabled when no changes made', (tester) async {
      when(
        () => mockUserSessionService.getCurrentUserFullName(),
      ).thenReturn('Nischay Maharjan');
      when(
        () => mockUserSessionService.getCurrentUserEmail(),
      ).thenReturn('nischaymaharjan@gmail.com');
      when(
        () => mockUserSessionService.getCurrentUserProfilePicture(),
      ).thenReturn(null);

      await tester.pumpWidget(createTestWidget());

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('Save button is enabled when name is changed', (tester) async {
      when(
        () => mockUserSessionService.getCurrentUserFullName(),
      ).thenReturn('Nischay Maharjan');
      when(
        () => mockUserSessionService.getCurrentUserEmail(),
      ).thenReturn('nischaymaharjann@gmail.com');
      when(
        () => mockUserSessionService.getCurrentUserProfilePicture(),
      ).thenReturn(null);

      await tester.pumpWidget(createTestWidget());

      // Find the first TextField (name field) and change its value
      final nameField = find.byType(TextField).first;
      await tester.enterText(nameField, 'Jane Doe');
      await tester.pump();

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('Save button is enabled when phone is changed', (tester) async {
      when(
        () => mockUserSessionService.getCurrentUserFullName(),
      ).thenReturn('Nischay Maharjan');
      when(
        () => mockUserSessionService.getCurrentUserEmail(),
      ).thenReturn('nischaymaharjan@gmail.com');
      when(
        () => mockUserSessionService.getCurrentUserProfilePicture(),
      ).thenReturn(null);

      await tester.pumpWidget(createTestWidget());

      // Find the second TextField (phone field) and change its value
      final phoneField = find.byType(TextField).last;
      await tester.enterText(phoneField, '1234567890');
      await tester.pump();

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('displays "Your Name" when name is empty', (tester) async {
      when(
        () => mockUserSessionService.getCurrentUserFullName(),
      ).thenReturn(null);
      when(
        () => mockUserSessionService.getCurrentUserEmail(),
      ).thenReturn('nischaymaharjan@gmail.com');
      when(
        () => mockUserSessionService.getCurrentUserProfilePicture(),
      ).thenReturn(null);

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Your Name'), findsOneWidget);
    });

    testWidgets('displays edit icon on profile picture', (tester) async {
      when(
        () => mockUserSessionService.getCurrentUserFullName(),
      ).thenReturn('Nischay Maharjan');
      when(
        () => mockUserSessionService.getCurrentUserEmail(),
      ).thenReturn('nischaymaharjan@gmail.com');
      when(
        () => mockUserSessionService.getCurrentUserProfilePicture(),
      ).thenReturn(null);

      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('tapping avatar shows image picker bottom sheet', (
      tester,
    ) async {
      when(
        () => mockUserSessionService.getCurrentUserFullName(),
      ).thenReturn('Nischay Maharjan');
      when(
        () => mockUserSessionService.getCurrentUserEmail(),
      ).thenReturn('nischaymaharjan@gmail.com');
      when(
        () => mockUserSessionService.getCurrentUserProfilePicture(),
      ).thenReturn(null);

      await tester.pumpWidget(createTestWidget());

      // Tap on the GestureDetector wrapping the avatar
      await tester.tap(find.byType(CircleAvatar));
      await tester.pumpAndSettle();

      // Verify bottom sheet options appear
      expect(find.text('Open Camera'), findsOneWidget);
      expect(find.text('Open Gallery'), findsOneWidget);
    });

    testWidgets('closing bottom sheet by tapping outside', (tester) async {
      when(
        () => mockUserSessionService.getCurrentUserFullName(),
      ).thenReturn('Nischay Maharjan');
      when(
        () => mockUserSessionService.getCurrentUserEmail(),
      ).thenReturn('nischaymaharjan@gmail.com');
      when(
        () => mockUserSessionService.getCurrentUserProfilePicture(),
      ).thenReturn(null);

      await tester.pumpWidget(createTestWidget());

      // Open bottom sheet
      await tester.tap(find.byType(CircleAvatar));
      await tester.pumpAndSettle();

      expect(find.text('Open Camera'), findsOneWidget);

      // Close by tapping the barrier
      await tester.tapAt(const Offset(100, 100));
      await tester.pumpAndSettle();

      expect(find.text('Open Camera'), findsNothing);
    });
  });
}
