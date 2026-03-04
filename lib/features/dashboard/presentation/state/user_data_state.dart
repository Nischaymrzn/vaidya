import 'package:equatable/equatable.dart';
import 'package:vaidya/features/dashboard/domain/entities/user_data_entity.dart';

enum UserDataStatus { initial, loading, loaded, error }

class UserDataState extends Equatable {
  final UserDataStatus status;
  final UserDataEntity data;
  final bool isSubmitting;
  final String? errorMessage;
  final String? actionMessage;

  const UserDataState({
    this.status = UserDataStatus.initial,
    this.data = const UserDataEntity(id: '', data: {}),
    this.isSubmitting = false,
    this.errorMessage,
    this.actionMessage,
  });

  UserDataState copyWith({
    UserDataStatus? status,
    UserDataEntity? data,
    bool? isSubmitting,
    String? errorMessage,
    String? actionMessage,
    bool clearError = false,
    bool clearActionMessage = false,
  }) {
    return UserDataState(
      status: status ?? this.status,
      data: data ?? this.data,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      actionMessage:
          clearActionMessage ? null : actionMessage ?? this.actionMessage,
    );
  }

  @override
  List<Object?> get props => [status, data, isSubmitting, errorMessage, actionMessage];
}
