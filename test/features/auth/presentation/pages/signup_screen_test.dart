import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vaidya/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:vaidya/features/auth/domain/usecases/is_google_login_configured_usecase.dart';
import 'package:vaidya/features/auth/domain/usecases/login_with_google_usecase.dart';
import 'package:vaidya/features/auth/domain/usecases/login_usecase.dart';
import 'package:vaidya/features/auth/domain/usecases/login_with_google_token_usecase.dart';
import 'package:vaidya/features/auth/domain/usecases/logout_usecase.dart';
import 'package:vaidya/features/auth/domain/usecases/register_usecase.dart';
import 'package:vaidya/features/auth/domain/usecases/request_password_reset_usecase.dart';
import 'package:vaidya/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:vaidya/features/auth/presentation/pages/signup_screen.dart';

class MockRegisterUsecase extends Mock implements RegisterUsecase {}

class MockLoginUsecase extends Mock implements LoginUsecase {}

class MockGetCurrentUserUsecase extends Mock implements GetCurrentUserUsecase {}

class MockLogoutUsecase extends Mock implements LogoutUsecase {}

class MockUpdateProfileUsecase extends Mock implements UpdateProfileUsecase {}

class MockRequestPasswordResetUsecase extends Mock
    implements RequestPasswordResetUsecase {}

class MockIsGoogleLoginConfiguredUsecase extends Mock
    implements IsGoogleLoginConfiguredUsecase {}

class MockLoginWithGoogleTokenUsecase extends Mock
    implements LoginWithGoogleTokenUsecase {}

class MockLoginWithGoogleUsecase extends Mock
    implements LoginWithGoogleUsecase {}

void main() {
  late MockRegisterUsecase mockRegisterUsecase;
  late MockLoginUsecase mockLoginUsecase;
  late MockGetCurrentUserUsecase mockGetCurrentUserUsecase;
  late MockLogoutUsecase mockLogoutUsecase;
  late MockUpdateProfileUsecase mockUpdateProfileUsecase;
  late MockRequestPasswordResetUsecase mockRequestPasswordResetUsecase;
  late MockIsGoogleLoginConfiguredUsecase mockIsGoogleLoginConfiguredUsecase;
  late MockLoginWithGoogleTokenUsecase mockLoginWithGoogleTokenUsecase;
  late MockLoginWithGoogleUsecase mockLoginWithGoogleUsecase;

  setUpAll(() {
    registerFallbackValue(const LoginUsecaseParams(email: '', password: ''));
    registerFallbackValue(
      const RegisterUsecaseParams(fullName: '', email: '', password: ''),
    );
    registerFallbackValue(const UpdateProfileUsecaseParams(userId: ''));
    registerFallbackValue(const RequestPasswordResetUsecaseParams(email: ''));
    registerFallbackValue(const LoginWithGoogleTokenUsecaseParams(token: ''));
  });

  setUp(() {
    mockRegisterUsecase = MockRegisterUsecase();
    mockLoginUsecase = MockLoginUsecase();
    mockGetCurrentUserUsecase = MockGetCurrentUserUsecase();
    mockLogoutUsecase = MockLogoutUsecase();
    mockUpdateProfileUsecase = MockUpdateProfileUsecase();
    mockRequestPasswordResetUsecase = MockRequestPasswordResetUsecase();
    mockIsGoogleLoginConfiguredUsecase = MockIsGoogleLoginConfiguredUsecase();
    mockLoginWithGoogleTokenUsecase = MockLoginWithGoogleTokenUsecase();
    mockLoginWithGoogleUsecase = MockLoginWithGoogleUsecase();
  });

  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [
        registerUsecaseProvider.overrideWith((ref) => mockRegisterUsecase),
        loginUsecaseProvider.overrideWith((ref) => mockLoginUsecase),
        getCurrentUserUsecaseProvider.overrideWith(
          (ref) => mockGetCurrentUserUsecase,
        ),
        logoutUsecaseProvider.overrideWith((ref) => mockLogoutUsecase),
        updateProfileUsecaseProvider.overrideWith(
          (ref) => mockUpdateProfileUsecase,
        ),
        requestPasswordResetUsecaseProvider.overrideWith(
          (ref) => mockRequestPasswordResetUsecase,
        ),
        isGoogleLoginConfiguredUsecaseProvider.overrideWith(
          (ref) => mockIsGoogleLoginConfiguredUsecase,
        ),
        loginWithGoogleTokenUsecaseProvider.overrideWith(
          (ref) => mockLoginWithGoogleTokenUsecase,
        ),
        loginWithGoogleUsecaseProvider.overrideWith(
          (ref) => mockLoginWithGoogleUsecase,
        ),
      ],
      child: MaterialApp(home: const SignupScreen()),
    );
  }

  group('SignupScreen', () {
    testWidgets('shows Sign up title', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Sign up'), findsWidgets);
      expect(find.text('Set up your Vaidya account now'), findsOneWidget);
    });

    testWidgets('shows all form labels', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
    });

    testWidgets('shows Create Account button and Sign in link', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Already have an account?'), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);
    });

    testWidgets('shows Or and Google login', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Or'), findsOneWidget);
      expect(find.text('Login with Google'), findsOneWidget);
    });

    testWidgets('has five text form fields', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNWidgets(5));
    });

    testWidgets('calls register when Create Account tapped with valid data', (
      tester,
    ) async {
      when(
        () => mockRegisterUsecase(any()),
      ).thenAnswer((_) async => const Right(true));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);

      await tester.enterText(textFields.at(0), 'Full Name');
      await tester.enterText(textFields.at(1), 'user@example.com');
      await tester.enterText(textFields.at(2), '9876543210');
      await tester.enterText(textFields.at(3), 'password123');
      await tester.enterText(textFields.at(4), 'password123');

      final createAccountButton = find.text('Create Account');

      await tester.ensureVisible(createAccountButton);
      await tester.tap(createAccountButton);
      await tester.pumpAndSettle();

      verify(
        () => mockRegisterUsecase(
          const RegisterUsecaseParams(
            fullName: 'Full Name',
            email: 'user@example.com',
            role: 'user',
            password: 'password123',
            number: '9876543210',
          ),
        ),
      ).called(1);
    });

    testWidgets(
      'shows validation when Create Account tapped with empty fields',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        final createAccountButton = find.text('Create Account');

        await tester.ensureVisible(createAccountButton);
        await tester.tap(createAccountButton);
        await tester.pumpAndSettle();

        expect(find.text('Full name is required'), findsOneWidget);
        expect(find.text('Email is required'), findsOneWidget);
      },
    );
  });
}
