import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/services/storage/user_session_service.dart';
import 'package:vaidya/features/profile/domain/usecases/create_profile_checkout_session_usecase.dart';
import 'package:vaidya/features/profile/domain/usecases/delete_profile_user_usecase.dart';
import 'package:vaidya/features/profile/domain/usecases/get_profile_user_usecase.dart';
import 'package:vaidya/features/profile/domain/usecases/get_profile_payment_status_usecase.dart';
import 'package:vaidya/features/profile/domain/usecases/update_profile_user_usecase.dart';
import 'package:vaidya/features/profile/presentation/state/profile_state.dart';

final profileViewModelProvider =
    NotifierProvider<ProfileViewModel, ProfileState>(ProfileViewModel.new);

class ProfileViewModel extends Notifier<ProfileState> {
  late final GetProfileUserUsecase _getProfileUserUsecase;
  late final UpdateProfileUserUsecase _updateProfileUserUsecase;
  late final DeleteProfileUserUsecase _deleteProfileUserUsecase;
  late final GetProfilePaymentStatusUsecase _getProfilePaymentStatusUsecase;
  late final CreateProfileCheckoutSessionUsecase
  _createProfileCheckoutSessionUsecase;
  late final UserSessionService _userSessionService;

  @override
  ProfileState build() {
    _getProfileUserUsecase = ref.read(getProfileUserUsecaseProvider);
    _updateProfileUserUsecase = ref.read(updateProfileUserUsecaseProvider);
    _deleteProfileUserUsecase = ref.read(deleteProfileUserUsecaseProvider);
    _getProfilePaymentStatusUsecase = ref.read(
      getProfilePaymentStatusUsecaseProvider,
    );
    _createProfileCheckoutSessionUsecase = ref.read(
      createProfileCheckoutSessionUsecaseProvider,
    );
    _userSessionService = ref.read(userSessionServiceProvider);
    return ProfileState(
      isPremium: _userSessionService.getCurrentUserIsPremium(),
      plan: _userSessionService.getCurrentUserIsPremium() ? 'premium' : 'free',
    );
  }

  Future<void> load(String userId, {bool forceLoading = false}) async {
    state = state.copyWith(
      status: forceLoading || state.status == ProfileStatus.initial
          ? ProfileStatus.loading
          : ProfileStatus.loaded,
      clearError: true,
    );

    final result = await _getProfileUserUsecase(
      GetProfileUserParams(id: userId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: ProfileStatus.error,
        errorMessage: failure.message,
      ),
      (user) => state = state.copyWith(
        status: ProfileStatus.loaded,
        user: user,
        clearError: true,
      ),
    );
  }

  Future<void> loadPaymentStatus() async {
    state = state.copyWith(
      isCheckingPremium: true,
      clearError: true,
      clearPaymentMessage: true,
    );

    final result = await _getProfilePaymentStatusUsecase();
    result.fold(
      (failure) => state = state.copyWith(
        isCheckingPremium: false,
        paymentMessage: failure.message,
      ),
      (status) => state = state.copyWith(
        isCheckingPremium: false,
        isPremium: status.isPremium,
        plan: status.plan,
        clearPaymentMessage: true,
      ),
    );
  }

  Future<String?> startPremiumCheckout() async {
    state = state.copyWith(
      isUpgradingPremium: true,
      clearError: true,
      clearPaymentMessage: true,
    );

    final result = await _createProfileCheckoutSessionUsecase();
    return result.fold(
      (failure) {
        state = state.copyWith(
          isUpgradingPremium: false,
          paymentMessage: failure.message,
        );
        return null;
      },
      (checkoutUrl) {
        state = state.copyWith(
          isUpgradingPremium: false,
          clearPaymentMessage: true,
        );
        return checkoutUrl;
      },
    );
  }

  Future<bool> update(
    String userId,
    Map<String, dynamic> payload, {
    String? imagePath,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearActionMessage: true,
    );

    final result = await _updateProfileUserUsecase(
      UpdateProfileUserParams(
        id: userId,
        payload: payload,
        imagePath: imagePath,
      ),
    );

    bool ok = false;
    String? message;

    result.fold((failure) => message = failure.message, (user) {
      ok = true;
      state = state.copyWith(user: user);
    });

    if (!ok) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: message ?? 'Failed to update profile',
      );
      return false;
    }

    state = state.copyWith(
      isSubmitting: false,
      actionMessage: 'Profile updated successfully',
      clearError: true,
    );
    return true;
  }

  Future<bool> updatePassword(String userId, String newPassword) async {
    final trimmed = newPassword.trim();
    if (trimmed.isEmpty) {
      state = state.copyWith(errorMessage: 'Password cannot be empty.');
      return false;
    }
    return update(userId, <String, dynamic>{'password': trimmed});
  }

  Future<bool> delete(String userId) async {
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearActionMessage: true,
    );

    final result = await _deleteProfileUserUsecase(
      DeleteProfileUserParams(id: userId),
    );

    bool ok = false;
    String? message;
    result.fold((failure) => message = failure.message, (_) => ok = true);

    if (!ok) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: message ?? 'Failed to delete profile',
      );
      return false;
    }

    state = state.copyWith(
      isSubmitting: false,
      actionMessage: 'Profile deleted successfully',
      clearError: true,
    );
    return true;
  }

  void clearMessages() {
    state = state.copyWith(
      clearError: true,
      clearActionMessage: true,
      clearPaymentMessage: true,
    );
  }

  @visibleForTesting
  void setPremiumStateForTests({
    required bool isPremium,
    required String plan,
  }) {
    state = state.copyWith(isPremium: isPremium, plan: plan);
  }
}
