import 'package:flutter_riverpod/flutter_riverpod.dart';
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

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  AuthViewModel.new,
);

class AuthViewModel extends Notifier<AuthState> {
  late final RegisterUsecase _registerUsecase;
  late final LoginUsecase _loginUsecase;
  late final GetCurrentUserUsecase _getCurrentUserUsecase;
  late final LogoutUsecase _logoutUsecase;
  late final UpdateProfileUsecase _updateProfileUsecase;
  late final RequestPasswordResetUsecase _requestPasswordResetUsecase;
  late final IsGoogleLoginConfiguredUsecase _isGoogleLoginConfiguredUsecase;
  late final LoginWithGoogleUsecase _loginWithGoogleUsecase;
  late final LoginWithGoogleTokenUsecase _loginWithGoogleTokenUsecase;

  @override
  AuthState build() {
    _registerUsecase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
    _getCurrentUserUsecase = ref.read(getCurrentUserUsecaseProvider);
    _logoutUsecase = ref.read(logoutUsecaseProvider);
    _updateProfileUsecase = ref.read(updateProfileUsecaseProvider);
    _requestPasswordResetUsecase = ref.read(
      requestPasswordResetUsecaseProvider,
    );
    _isGoogleLoginConfiguredUsecase = ref.read(
      isGoogleLoginConfiguredUsecaseProvider,
    );
    _loginWithGoogleUsecase = ref.read(loginWithGoogleUsecaseProvider);
    _loginWithGoogleTokenUsecase = ref.read(
      loginWithGoogleTokenUsecaseProvider,
    );
    return const AuthState();
  }

  Future<void> register({
    required String fullName,
    required String email,
    String? role,
    required String password,
    String? number,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    await Future.delayed(const Duration(milliseconds: 100));

    final result = await _registerUsecase(
      RegisterUsecaseParams(
        fullName: fullName,
        email: email,
        role: role,
        password: password,
        number: number,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (success) => state = state.copyWith(status: AuthStatus.registered),
    );
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _loginUsecase(
      LoginUsecaseParams(email: email, password: password),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (user) =>
          state = state.copyWith(status: AuthStatus.authenticated, user: user),
    );
  }

  Future<void> loginWithGoogleToken({required String token}) async {
    if (state.status == AuthStatus.loading) return;
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _loginWithGoogleTokenUsecase(
      LoginWithGoogleTokenUsecaseParams(token: token),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (user) =>
          state = state.copyWith(status: AuthStatus.authenticated, user: user),
    );
  }

  Future<void> loginWithGoogle() async {
    if (state.status == AuthStatus.loading) return;
    state = state.copyWith(status: AuthStatus.loading);

    final configuredResult = await _isGoogleLoginConfiguredUsecase();
    bool? isConfigured;
    configuredResult.fold((failure) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      );
    }, (configured) => isConfigured = configured);

    if (isConfigured == null) {
      return;
    }

    if (!isConfigured!) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage:
            'Google login is not configured on server. Please contact admin.',
      );
      return;
    }

    final result = await _loginWithGoogleUsecase();
    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (user) =>
          state = state.copyWith(status: AuthStatus.authenticated, user: user),
    );
  }

  Future<bool> isGoogleLoginConfigured() async {
    final result = await _isGoogleLoginConfiguredUsecase();
    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (configured) {
        if (!configured) {
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage:
                'Google login is not configured on server. Please contact admin.',
          );
        }
        return configured;
      },
    );
  }

  Future<void> requestPasswordReset({required String email}) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _requestPasswordResetUsecase(
      RequestPasswordResetUsecaseParams(email: email),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(
        status: AuthStatus.passwordResetEmailSent,
        successMessage: 'Reset link sent. Please check your email.',
      ),
    );
  }

  Future<void> getCurrentUser() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _getCurrentUserUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: failure.message,
      ),
      (user) =>
          state = state.copyWith(status: AuthStatus.authenticated, user: user),
    );
  }

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _logoutUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (success) => state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
      ),
    );
  }

  Future<void> updateProfile({
    required String userId,
    String? name,
    String? email,
    int? number,
    String? imagePath,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final result = await _updateProfileUsecase(
      UpdateProfileUsecaseParams(
        userId: userId,
        name: name,
        email: email,
        number: number,
        imagePath: imagePath,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (updatedUser) => state = state.copyWith(
        status: AuthStatus.authenticated,
        user: updatedUser,
        successMessage: 'Profile updated',
      ),
    );
  }

  void clearSuccessMessage() {
    state = state.copyWith(successMessage: null);
  }

  void resetState() {
    state = const AuthState(
      status: AuthStatus.initial,
      errorMessage: null,
      successMessage: null,
    );
  }
}
