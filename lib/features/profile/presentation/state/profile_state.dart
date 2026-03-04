import 'package:equatable/equatable.dart';
import 'package:vaidya/features/profile/domain/entities/profile_user_entity.dart';

enum ProfileStatus { initial, loading, loaded, error }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final ProfileUserEntity? user;
  final bool isSubmitting;
  final String? errorMessage;
  final String? actionMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.user,
    this.isSubmitting = false,
    this.errorMessage,
    this.actionMessage,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    ProfileUserEntity? user,
    bool? isSubmitting,
    String? errorMessage,
    String? actionMessage,
    bool clearError = false,
    bool clearActionMessage = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      actionMessage:
          clearActionMessage ? null : actionMessage ?? this.actionMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, isSubmitting, errorMessage, actionMessage];
}
