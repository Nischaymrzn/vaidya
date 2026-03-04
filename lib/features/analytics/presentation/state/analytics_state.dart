import 'package:equatable/equatable.dart';
import 'package:vaidya/features/analytics/domain/entities/analytics_summary_entity.dart';

enum AnalyticsStatus { initial, loading, loaded, error }

class AnalyticsState extends Equatable {
  final AnalyticsStatus status;
  final AnalyticsSummaryEntity summary;
  final String? errorMessage;

  const AnalyticsState({
    this.status = AnalyticsStatus.initial,
    this.summary = const AnalyticsSummaryEntity(),
    this.errorMessage,
  });

  AnalyticsState copyWith({
    AnalyticsStatus? status,
    AnalyticsSummaryEntity? summary,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AnalyticsState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, summary, errorMessage];
}
