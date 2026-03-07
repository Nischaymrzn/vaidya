import 'package:equatable/equatable.dart';
import 'package:vaidya/features/symptoms/domain/entities/symptom_entity.dart';

enum SymptomsStatus { initial, loading, loaded, error }

class SymptomsState extends Equatable {
  final SymptomsStatus status;
  final List<SymptomEntity> items;
  final SymptomsSummaryEntity summary;
  final bool isSubmitting;
  final String? errorMessage;
  final String? actionMessage;

  const SymptomsState({
    this.status = SymptomsStatus.initial,
    this.items = const [],
    this.summary = const SymptomsSummaryEntity(),
    this.isSubmitting = false,
    this.errorMessage,
    this.actionMessage,
  });

  SymptomsState copyWith({
    SymptomsStatus? status,
    List<SymptomEntity>? items,
    SymptomsSummaryEntity? summary,
    bool? isSubmitting,
    String? errorMessage,
    String? actionMessage,
    bool clearError = false,
    bool clearActionMessage = false,
  }) {
    return SymptomsState(
      status: status ?? this.status,
      items: items ?? this.items,
      summary: summary ?? this.summary,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      actionMessage: clearActionMessage
          ? null
          : actionMessage ?? this.actionMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    items,
    summary,
    isSubmitting,
    errorMessage,
    actionMessage,
  ];
}
