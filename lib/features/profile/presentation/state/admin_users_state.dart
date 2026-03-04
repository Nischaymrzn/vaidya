import 'package:equatable/equatable.dart';
import 'package:vaidya/features/profile/domain/entities/admin_user_entity.dart';

enum AdminUsersStatus { initial, loading, loaded, error }

class AdminUsersState extends Equatable {
  final AdminUsersStatus status;
  final List<AdminUserEntity> users;
  final AdminUserEntity? selected;
  final AdminUsersPaginationEntity pagination;
  final int page;
  final int limit;
  final bool isSubmitting;
  final String? errorMessage;
  final String? actionMessage;

  const AdminUsersState({
    this.status = AdminUsersStatus.initial,
    this.users = const [],
    this.selected,
    this.pagination = const AdminUsersPaginationEntity.empty(),
    this.page = 1,
    this.limit = 10,
    this.isSubmitting = false,
    this.errorMessage,
    this.actionMessage,
  });

  AdminUsersState copyWith({
    AdminUsersStatus? status,
    List<AdminUserEntity>? users,
    AdminUserEntity? selected,
    AdminUsersPaginationEntity? pagination,
    int? page,
    int? limit,
    bool? isSubmitting,
    String? errorMessage,
    String? actionMessage,
    bool clearSelected = false,
    bool clearError = false,
    bool clearActionMessage = false,
  }) {
    return AdminUsersState(
      status: status ?? this.status,
      users: users ?? this.users,
      selected: clearSelected ? null : selected ?? this.selected,
      pagination: pagination ?? this.pagination,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      actionMessage:
          clearActionMessage ? null : actionMessage ?? this.actionMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        users,
        selected,
        pagination,
        page,
        limit,
        isSubmitting,
        errorMessage,
        actionMessage,
      ];
}
