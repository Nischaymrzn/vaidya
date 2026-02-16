import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/features/profile/domain/usecases/create_admin_user_usecase.dart';
import 'package:vaidya/features/profile/domain/usecases/delete_admin_user_usecase.dart';
import 'package:vaidya/features/profile/domain/usecases/get_admin_users_usecase.dart';
import 'package:vaidya/features/profile/domain/usecases/update_admin_user_usecase.dart';
import 'package:vaidya/features/profile/presentation/state/admin_users_state.dart';

final adminUsersViewModelProvider =
    NotifierProvider<AdminUsersViewModel, AdminUsersState>(
      AdminUsersViewModel.new,
    );

class AdminUsersViewModel extends Notifier<AdminUsersState> {
  late final GetAdminUsersUsecase _getAdminUsersUsecase;
  late final GetAdminUserByIdUsecase _getAdminUserByIdUsecase;
  late final CreateAdminUserUsecase _createAdminUserUsecase;
  late final UpdateAdminUserUsecase _updateAdminUserUsecase;
  late final DeleteAdminUserUsecase _deleteAdminUserUsecase;

  @override
  AdminUsersState build() {
    _getAdminUsersUsecase = ref.read(getAdminUsersUsecaseProvider);
    _getAdminUserByIdUsecase = ref.read(getAdminUserByIdUsecaseProvider);
    _createAdminUserUsecase = ref.read(createAdminUserUsecaseProvider);
    _updateAdminUserUsecase = ref.read(updateAdminUserUsecaseProvider);
    _deleteAdminUserUsecase = ref.read(deleteAdminUserUsecaseProvider);
    return const AdminUsersState();
  }

  Future<void> load({int? page, bool forceLoading = false}) async {
    final targetPage = page ?? state.page;

    state = state.copyWith(
      status: forceLoading || state.status == AdminUsersStatus.initial
          ? AdminUsersStatus.loading
          : AdminUsersStatus.loaded,
      page: targetPage,
      clearError: true,
    );

    final result = await _getAdminUsersUsecase(
      GetAdminUsersParams(page: targetPage, limit: state.limit),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AdminUsersStatus.error,
        errorMessage: failure.message,
      ),
      (data) => state = state.copyWith(
        status: AdminUsersStatus.loaded,
        users: data.users,
        pagination: data.pagination,
        page: data.pagination.page,
        clearError: true,
      ),
    );
  }

  Future<void> getById(String id) async {
    state = state.copyWith(isSubmitting: true, clearError: true);

    final result = await _getAdminUserByIdUsecase(GetAdminUserByIdParams(id: id));

    result.fold(
      (failure) => state = state.copyWith(
        isSubmitting: false,
        errorMessage: failure.message,
      ),
      (user) => state = state.copyWith(
        isSubmitting: false,
        selected: user,
        clearError: true,
      ),
    );
  }

  Future<bool> create(Map<String, dynamic> payload, {String? imagePath}) {
    return _runMutation(
      () => _createAdminUserUsecase(
        CreateAdminUserParams(payload: payload, imagePath: imagePath),
      ),
      'Admin user created successfully',
    );
  }

  Future<bool> update(String id, Map<String, dynamic> payload, {String? imagePath}) {
    return _runMutation(
      () => _updateAdminUserUsecase(
        UpdateAdminUserParams(id: id, payload: payload, imagePath: imagePath),
      ),
      'Admin user updated successfully',
    );
  }

  Future<bool> delete(String id) async {
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearActionMessage: true,
    );

    final result = await _deleteAdminUserUsecase(DeleteAdminUserParams(id: id));

    bool ok = false;
    String? message;
    result.fold((failure) => message = failure.message, (_) => ok = true);

    if (!ok) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: message ?? 'Failed to delete admin user',
      );
      return false;
    }

    await load(page: state.page, forceLoading: false);
    state = state.copyWith(
      isSubmitting: false,
      actionMessage: 'Admin user deleted successfully',
      clearError: true,
    );
    return true;
  }

  Future<bool> _runMutation(
    Future<Either<Failure, Object?>> Function() run,
    String successMessage,
  ) async {
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearActionMessage: true,
    );

    final result = await run();

    bool ok = false;
    String? message;
    result.fold((failure) => message = failure.message, (_) => ok = true);

    if (!ok) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: message ?? 'Operation failed',
      );
      return false;
    }

    await load(page: 1, forceLoading: true);
    state = state.copyWith(
      isSubmitting: false,
      actionMessage: successMessage,
      clearError: true,
    );
    return true;
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearActionMessage: true);
  }
}
