import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/features/dashboard/domain/usecases/get_user_data_usecase.dart';
import 'package:vaidya/features/dashboard/domain/usecases/update_user_data_usecase.dart';
import 'package:vaidya/features/dashboard/presentation/state/user_data_state.dart';

final userDataViewModelProvider = NotifierProvider<UserDataViewModel, UserDataState>(
  UserDataViewModel.new,
);

class UserDataViewModel extends Notifier<UserDataState> {
  late final GetUserDataUsecase _getUserDataUsecase;
  late final UpdateUserDataUsecase _updateUserDataUsecase;

  @override
  UserDataState build() {
    _getUserDataUsecase = ref.read(getUserDataUsecaseProvider);
    _updateUserDataUsecase = ref.read(updateUserDataUsecaseProvider);
    return const UserDataState();
  }

  Future<void> load({bool forceLoading = false}) async {
    state = state.copyWith(
      status: forceLoading || state.status == UserDataStatus.initial
          ? UserDataStatus.loading
          : UserDataStatus.loaded,
      clearError: true,
    );

    final result = await _getUserDataUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        status: UserDataStatus.error,
        errorMessage: failure.message,
      ),
      (data) => state = state.copyWith(
        status: UserDataStatus.loaded,
        data: data,
        clearError: true,
      ),
    );
  }

  Future<bool> update(Map<String, dynamic> payload) async {
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearActionMessage: true,
    );

    final result = await _updateUserDataUsecase(UpdateUserDataParams(payload: payload));

    bool ok = false;
    String? message;

    result.fold(
      (failure) => message = failure.message,
      (data) {
        ok = true;
        state = state.copyWith(data: data);
      },
    );

    if (!ok) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: message ?? 'Failed to update user data',
      );
      return false;
    }

    state = state.copyWith(
      isSubmitting: false,
      actionMessage: 'User data updated successfully',
      clearError: true,
    );
    return true;
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearActionMessage: true);
  }
}
