import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/features/profile/domain/usecases/delete_profile_user_usecase.dart';
import 'package:vaidya/features/profile/domain/usecases/get_profile_user_usecase.dart';
import 'package:vaidya/features/profile/domain/usecases/update_profile_user_usecase.dart';
import 'package:vaidya/features/profile/presentation/state/profile_state.dart';

final profileViewModelProvider = NotifierProvider<ProfileViewModel, ProfileState>(
  ProfileViewModel.new,
);

class ProfileViewModel extends Notifier<ProfileState> {
  late final GetProfileUserUsecase _getProfileUserUsecase;
  late final UpdateProfileUserUsecase _updateProfileUserUsecase;
  late final DeleteProfileUserUsecase _deleteProfileUserUsecase;

  @override
  ProfileState build() {
    _getProfileUserUsecase = ref.read(getProfileUserUsecaseProvider);
    _updateProfileUserUsecase = ref.read(updateProfileUserUsecaseProvider);
    _deleteProfileUserUsecase = ref.read(deleteProfileUserUsecaseProvider);
    return const ProfileState();
  }

  Future<void> load(String userId, {bool forceLoading = false}) async {
    state = state.copyWith(
      status: forceLoading || state.status == ProfileStatus.initial
          ? ProfileStatus.loading
          : ProfileStatus.loaded,
      clearError: true,
    );

    final result = await _getProfileUserUsecase(GetProfileUserParams(id: userId));

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
      UpdateProfileUserParams(id: userId, payload: payload, imagePath: imagePath),
    );

    bool ok = false;
    String? message;

    result.fold(
      (failure) => message = failure.message,
      (user) {
        ok = true;
        state = state.copyWith(user: user);
      },
    );

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

  Future<bool> delete(String userId) async {
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearActionMessage: true,
    );

    final result = await _deleteProfileUserUsecase(DeleteProfileUserParams(id: userId));

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
    state = state.copyWith(clearError: true, clearActionMessage: true);
  }
}
