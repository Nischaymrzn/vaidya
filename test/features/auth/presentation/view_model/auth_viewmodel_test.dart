import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/features/auth/domain/entities/auth_entity.dart';
import 'package:vaidya/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:vaidya/features/auth/domain/usecases/is_google_login_configured_usecase.dart';
import 'package:vaidya/features/auth/domain/usecases/login_with_google_usecase.dart';
import 'package:vaidya/features/auth/domain/usecases/login_usecase.dart';
import 'package:vaidya/features/auth/domain/usecases/login_with_google_token_usecase.dart';
import 'package:vaidya/features/auth/domain/usecases/logout_usecase.dart';
import 'package:vaidya/features/auth/domain/usecases/register_usecase.dart';
import 'package:vaidya/features/auth/domain/usecases/request_password_reset_usecase.dart';
import 'package:vaidya/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:vaidya/features/auth/presentation/state/auth_state.dart';
import 'package:vaidya/features/auth/presentation/view_model/auth_viewmodel.dart';

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
  late ProviderContainer container;

  const tAuthEntity = AuthEntity(
    userId: 'user-1',
    name: 'Test User',
    email: 'test@example.com',
    number: '1234567890',
    role: 'user',
  );

  setUpAll(() {
    registerFallbackValue(const LoginUsecaseParams(email: '', password: ''));
    registerFallbackValue(const UpdateProfileUsecaseParams(userId: ''));
    registerFallbackValue(
      const RegisterUsecaseParams(fullName: '', email: '', password: ''),
    );
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

    container = ProviderContainer(
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
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AuthViewModel', () {
    group('initial state', () {
      test('build returns initial AuthState', () {
        final state = container.read(authViewModelProvider);

        expect(state.status, AuthStatus.initial);
        expect(state.user, isNull);
        expect(state.errorMessage, isNull);
        expect(state.successMessage, isNull);
      });
    });

    group('register', () {
      test('sets loading then registered when register succeeds', () async {
        when(
          () => mockRegisterUsecase(any()),
        ).thenAnswer((_) async => const Right(true));

        final notifier = container.read(authViewModelProvider.notifier);

        final registerFuture = notifier.register(
          fullName: 'New User',
          email: 'new@example.com',
          password: 'password123',
        );

        expect(
          container.read(authViewModelProvider).status,
          AuthStatus.loading,
        );

        await registerFuture;

        final state = container.read(authViewModelProvider);
        expect(state.status, AuthStatus.registered);
        expect(state.errorMessage, isNull);
      });

      test(
        'sets loading then error with message when register fails',
        () async {
          const failure = ApiFailure(
            message: 'Email already in use',
            statusCode: 409,
          );
          when(
            () => mockRegisterUsecase(any()),
          ).thenAnswer((_) async => const Left(failure));

          final notifier = container.read(authViewModelProvider.notifier);

          await notifier.register(
            fullName: 'New User',
            email: 'taken@example.com',
            password: 'password123',
          );

          final state = container.read(authViewModelProvider);
          expect(state.status, AuthStatus.error);
          expect(state.errorMessage, 'Email already in use');
          expect(state.user, isNull);
        },
      );

      test(
        'forwards optional role and number to usecase when provided',
        () async {
          when(
            () => mockRegisterUsecase(any()),
          ).thenAnswer((_) async => const Right(true));

          final notifier = container.read(authViewModelProvider.notifier);

          await notifier.register(
            fullName: 'Admin User',
            email: 'admin@example.com',
            role: 'admin',
            password: 'admin123',
            number: '9998887777',
          );

          final state = container.read(authViewModelProvider);
          expect(state.status, AuthStatus.registered);
          verify(
            () => mockRegisterUsecase(
              const RegisterUsecaseParams(
                fullName: 'Admin User',
                email: 'admin@example.com',
                role: 'admin',
                password: 'admin123',
                number: '9998887777',
              ),
            ),
          ).called(1);
        },
      );
    });

    group('login', () {
      test(
        'sets loading then authenticated with user when login succeeds',
        () async {
          when(
            () => mockLoginUsecase(any()),
          ).thenAnswer((_) async => const Right(tAuthEntity));

          final notifier = container.read(authViewModelProvider.notifier);

          notifier.login(email: 'test@example.com', password: 'password123');

          expect(
            container.read(authViewModelProvider).status,
            AuthStatus.loading,
          );

          await Future.delayed(const Duration(milliseconds: 100));

          final state = container.read(authViewModelProvider);
          expect(state.status, AuthStatus.authenticated);
          expect(state.user, tAuthEntity);
          expect(state.errorMessage, isNull);
        },
      );

      test('sets loading then error with message when login fails', () async {
        const failure = ApiFailure(
          message: 'Invalid credentials',
          statusCode: 401,
        );
        when(
          () => mockLoginUsecase(any()),
        ).thenAnswer((_) async => const Left(failure));

        final notifier = container.read(authViewModelProvider.notifier);

        notifier.login(email: 'wrong@example.com', password: 'wrong');

        await Future.delayed(const Duration(milliseconds: 100));

        final state = container.read(authViewModelProvider);
        expect(state.status, AuthStatus.error);
        expect(state.errorMessage, 'Invalid credentials');
        expect(state.user, isNull);
      });
    });

    group('getCurrentUser', () {
      test(
        'sets loading then authenticated with user when getCurrentUser succeeds',
        () async {
          when(
            () => mockGetCurrentUserUsecase(),
          ).thenAnswer((_) async => const Right(tAuthEntity));

          final notifier = container.read(authViewModelProvider.notifier);

          notifier.getCurrentUser();

          expect(
            container.read(authViewModelProvider).status,
            AuthStatus.loading,
          );

          await Future.delayed(const Duration(milliseconds: 100));

          final state = container.read(authViewModelProvider);
          expect(state.status, AuthStatus.authenticated);
          expect(state.user, tAuthEntity);
        },
      );

      test(
        'sets loading then unauthenticated when getCurrentUser fails',
        () async {
          const failure = LocalDatabaseFailure(message: 'No user found');
          when(
            () => mockGetCurrentUserUsecase(),
          ).thenAnswer((_) async => const Left(failure));

          final notifier = container.read(authViewModelProvider.notifier);

          notifier.getCurrentUser();

          await Future.delayed(const Duration(milliseconds: 100));

          final state = container.read(authViewModelProvider);
          expect(state.status, AuthStatus.unauthenticated);
          expect(state.errorMessage, 'No user found');
          expect(state.user, isNull);
        },
      );
    });

    group('logout', () {
      test('sets loading then unauthenticated when logout succeeds', () async {
        when(
          () => mockLogoutUsecase(),
        ).thenAnswer((_) async => const Right(true));

        final notifier = container.read(authViewModelProvider.notifier);

        notifier.logout();

        await Future.delayed(const Duration(milliseconds: 100));

        final state = container.read(authViewModelProvider);
        expect(state.status, AuthStatus.unauthenticated);
        expect(state.user, isNull);
      });

      test('sets loading then error when logout fails', () async {
        const failure = LocalDatabaseFailure(message: 'Logout failed');
        when(
          () => mockLogoutUsecase(),
        ).thenAnswer((_) async => const Left(failure));

        final notifier = container.read(authViewModelProvider.notifier);

        notifier.logout();

        await Future.delayed(const Duration(milliseconds: 100));

        final state = container.read(authViewModelProvider);
        expect(state.status, AuthStatus.error);
        expect(state.errorMessage, 'Logout failed');
      });
    });

    group('updateProfile', () {
      test(
        'sets loading then authenticated with successMessage when updateProfile succeeds',
        () async {
          when(
            () => mockUpdateProfileUsecase(any()),
          ).thenAnswer((_) async => const Right(tAuthEntity));

          final notifier = container.read(authViewModelProvider.notifier);

          notifier.updateProfile(userId: 'user-1', name: 'Updated Name');

          expect(
            container.read(authViewModelProvider).status,
            AuthStatus.loading,
          );

          await Future.delayed(const Duration(milliseconds: 100));

          final state = container.read(authViewModelProvider);
          expect(state.status, AuthStatus.authenticated);
          expect(state.user, tAuthEntity);
          expect(state.successMessage, 'Profile updated');
        },
      );

      test('sets loading then error when updateProfile fails', () async {
        const failure = ApiFailure(message: 'Update failed', statusCode: 500);
        when(
          () => mockUpdateProfileUsecase(any()),
        ).thenAnswer((_) async => const Left(failure));

        final notifier = container.read(authViewModelProvider.notifier);

        notifier.updateProfile(userId: 'user-1');

        await Future.delayed(const Duration(milliseconds: 100));

        final state = container.read(authViewModelProvider);
        expect(state.status, AuthStatus.error);
        expect(state.errorMessage, 'Update failed');
      });
    });

    group('resetState', () {
      test('resets state to initial', () async {
        when(
          () => mockLoginUsecase(any()),
        ).thenAnswer((_) async => const Right(tAuthEntity));

        final notifier = container.read(authViewModelProvider.notifier);
        notifier.login(email: 'test@example.com', password: 'pass');
        await Future.delayed(const Duration(milliseconds: 100));

        expect(
          container.read(authViewModelProvider).status,
          AuthStatus.authenticated,
        );

        notifier.resetState();

        final state = container.read(authViewModelProvider);
        expect(state.status, AuthStatus.initial);
        expect(state.user, isNull);
        expect(state.errorMessage, isNull);
        expect(state.successMessage, isNull);
      });
    });
  });
}
