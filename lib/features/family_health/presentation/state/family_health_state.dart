import 'package:equatable/equatable.dart';
import 'package:vaidya/features/family_health/domain/entities/family_group_entity.dart';

enum FamilyHealthStatus { initial, loading, loaded, error }

class FamilyHealthState extends Equatable {
  final FamilyHealthStatus status;
  final FamilyGroupEntity? group;
  final FamilyGroupSummaryEntity summary;
  final FamilyInviteEntity? latestInvite;
  final bool isSubmitting;
  final String? errorMessage;
  final String? actionMessage;

  const FamilyHealthState({
    this.status = FamilyHealthStatus.initial,
    this.group,
    this.summary = const FamilyGroupSummaryEntity(),
    this.latestInvite,
    this.isSubmitting = false,
    this.errorMessage,
    this.actionMessage,
  });

  FamilyHealthState copyWith({
    FamilyHealthStatus? status,
    FamilyGroupEntity? group,
    FamilyGroupSummaryEntity? summary,
    FamilyInviteEntity? latestInvite,
    bool? isSubmitting,
    String? errorMessage,
    String? actionMessage,
    bool clearError = false,
    bool clearActionMessage = false,
    bool clearInvite = false,
  }) {
    return FamilyHealthState(
      status: status ?? this.status,
      group: group ?? this.group,
      summary: summary ?? this.summary,
      latestInvite: clearInvite ? null : latestInvite ?? this.latestInvite,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      actionMessage:
          clearActionMessage ? null : actionMessage ?? this.actionMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        group,
        summary,
        latestInvite,
        isSubmitting,
        errorMessage,
        actionMessage,
      ];
}
