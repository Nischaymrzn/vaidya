import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vaidya/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:vaidya/features/auth/domain/usecases/login_usecase.dart';
import 'package:vaidya/features/auth/domain/usecases/logout_usecase.dart';
import 'package:vaidya/features/auth/domain/usecases/register_usecase.dart';
import 'package:vaidya/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:vaidya/features/auth/presentation/pages/login_screen.dart';

class MockLoginUsecase extends Mock implements LoginUsecase {}

class MockRegisterUsecase extends Mock implements RegisterUsecase {}

class MockGetCurrentUserUsecase extends Mock implements GetCurrentUserUsecase {}

class MockLogoutUsecase extends Mock implements LogoutUsecase {}

class MockUpdateProfileUsecase extends Mock implements UpdateProfileUsecase {}

void main() {
  late MockLoginUsecase mockLoginUsecase;
  late MockRegisterUsecase mockRegisterUsecase;
  late MockGetCurrentUserUsecase mockGetCurrentUserUsecase;
  late MockLogoutUsecase mockLogoutUsecase;
  late MockUpdateProfileUsecase mockUpdateProfileUsecase;

  setUpAll(() {
    registerFallbackValue(const LoginUsecaseParams(email: '', password: ''));
    registerFallbackValue(
      const RegisterUsecaseParams(fullName: '', email: '', password: ''),
    );
    registerFallbackValue(const UpdateProfileUsecaseParams(userId: ''));
  });

  setUp(() {
    mockLoginUsecase = MockLoginUsecase();
    mockRegisterUsecase = MockRegisterUsecase();
    mockGetCurrentUserUsecase = MockGetCurrentUserUsecase();
    mockLogoutUsecase = MockLogoutUsecase();
    mockUpdateProfileUsecase = MockUpdateProfileUsecase();
  });

  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [
        loginUsecaseProvider.overrideWith((ref) => mockLoginUsecase),
        registerUsecaseProvider.overrideWith((ref) => mockRegisterUsecase),
        getCurrentUserUsecaseProvider.overrideWith(
          (ref) => mockGetCurrentUserUsecase,
        ),
        logoutUsecaseProvider.overrideWith((ref) => mockLogoutUsecase),
        updateProfileUsecaseProvider.overrideWith(
          (ref) => mockUpdateProfileUsecase,
        ),
      ],
      child: MaterialApp(home: const LoginScreen()),
    );
  }

  group('LoginScreen', () {
    testWidgets('shows Sign In title', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('shows subtitle and email, password labels', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Enter your credentials to continue'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('shows Login button and Sign up link', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Login'), findsOneWidget);
      expect(find.text("Don't have an account?"), findsOneWidget);
      expect(find.text('Sign up'), findsOneWidget);
    });

    testWidgets('shows Forgot Password link', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Forgot Password?'), findsOneWidget);
    });

    testWidgets('shows Or divider and Google login', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Or'), findsOneWidget);
      expect(find.text('Login with Google'), findsOneWidget);
    });

    testWidgets('navigates to SignupScreen when Sign up is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign up'));
      await tester.pumpAndSettle();

      expect(find.text('Sign up'), findsWidgets);
      expect(find.text('Set up your Vaidya account now'), findsOneWidget);
    });

    testWidgets('has two text form fields for email and password', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('shows validation when Login tapped with empty fields', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Login'));
      await tester.pump();

      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });
  });
}
