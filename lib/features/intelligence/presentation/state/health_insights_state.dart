import 'package:equatable/equatable.dart';
import 'package:vaidya/features/intelligence/domain/entities/health_insight_entity.dart';

enum HealthInsightsStatus { initial, loading, loaded, error }

class HealthInsightsState extends Equatable {
  final HealthInsightsStatus status;
  final List<HealthInsightEntity> items;
  final HealthInsightEntity? selected;
  final String? riskId;
  final bool isSubmitting;
  final String? errorMessage;

  const HealthInsightsState({
    this.status = HealthInsightsStatus.initial,
    this.items = const [],
    this.selected,
    this.riskId,
    this.isSubmitting = false,
    this.errorMessage,
  });

  HealthInsightsState copyWith({
    HealthInsightsStatus? status,
    List<HealthInsightEntity>? items,
    HealthInsightEntity? selected,
    String? riskId,
    bool? isSubmitting,
    String? errorMessage,
    bool clearSelected = false,
    bool clearError = false,
  }) {
    return HealthInsightsState(
      status: status ?? this.status,
      items: items ?? this.items,
      selected: clearSelected ? null : selected ?? this.selected,
      riskId: riskId ?? this.riskId,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, selected, riskId, isSubmitting, errorMessage];
}
