import 'package:equatable/equatable.dart';
import 'package:vaidya/features/vitals/domain/entities/vital_entity.dart';

enum VitalsStatus { initial, loading, loaded, error }

class VitalsState extends Equatable {
  final VitalsStatus status;
  final List<VitalEntity> items;
  final VitalsSummaryEntity summary;
  final bool isSubmitting;
  final String? errorMessage;
  final String? actionMessage;

  const VitalsState({
    this.status = VitalsStatus.initial,
    this.items = const [],
    this.summary = const VitalsSummaryEntity(),
    this.isSubmitting = false,
    this.errorMessage,
    this.actionMessage,
  });

  VitalsState copyWith({
    VitalsStatus? status,
    List<VitalEntity>? items,
    VitalsSummaryEntity? summary,
    bool? isSubmitting,
    String? errorMessage,
    String? actionMessage,
    bool clearError = false,
    bool clearActionMessage = false,
  }) {
    return VitalsState(
      status: status ?? this.status,
      items: items ?? this.items,
      summary: summary ?? this.summary,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      actionMessage: clearActionMessage ? null : actionMessage ?? this.actionMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, summary, isSubmitting, errorMessage, actionMessage];
}
