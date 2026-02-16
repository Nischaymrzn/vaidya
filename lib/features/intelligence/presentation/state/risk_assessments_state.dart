import 'package:equatable/equatable.dart';
import 'package:vaidya/features/intelligence/domain/entities/risk_assessment_entity.dart';

enum RiskAssessmentsStatus { initial, loading, loaded, error }

class RiskAssessmentsState extends Equatable {
  final RiskAssessmentsStatus status;
  final List<RiskAssessmentEntity> items;
  final RiskAssessmentEntity? selected;
  final RiskAssessmentGenerateEntity generated;
  final bool isSubmitting;
  final String? errorMessage;
  final String? actionMessage;

  const RiskAssessmentsState({
    this.status = RiskAssessmentsStatus.initial,
    this.items = const [],
    this.selected,
    this.generated = const RiskAssessmentGenerateEntity(),
    this.isSubmitting = false,
    this.errorMessage,
    this.actionMessage,
  });

  RiskAssessmentsState copyWith({
    RiskAssessmentsStatus? status,
    List<RiskAssessmentEntity>? items,
    RiskAssessmentEntity? selected,
    RiskAssessmentGenerateEntity? generated,
    bool? isSubmitting,
    String? errorMessage,
    String? actionMessage,
    bool clearSelected = false,
    bool clearError = false,
    bool clearActionMessage = false,
  }) {
    return RiskAssessmentsState(
      status: status ?? this.status,
      items: items ?? this.items,
      selected: clearSelected ? null : selected ?? this.selected,
      generated: generated ?? this.generated,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      actionMessage:
          clearActionMessage ? null : actionMessage ?? this.actionMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        items,
        selected,
        generated,
        isSubmitting,
        errorMessage,
        actionMessage,
      ];
}
