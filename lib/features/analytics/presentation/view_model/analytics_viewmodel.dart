import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/features/analytics/domain/usecases/get_analytics_summary_usecase.dart';
import 'package:vaidya/features/analytics/presentation/state/analytics_state.dart';

final analyticsViewModelProvider =
    NotifierProvider<AnalyticsViewModel, AnalyticsState>(
      AnalyticsViewModel.new,
    );

class AnalyticsViewModel extends Notifier<AnalyticsState> {
  late final GetAnalyticsSummaryUsecase _getAnalyticsSummaryUsecase;

  @override
  AnalyticsState build() {
    _getAnalyticsSummaryUsecase = ref.read(getAnalyticsSummaryUsecaseProvider);
    return const AnalyticsState();
  }

  Future<void> loadSummary({int? months, bool forceLoading = false}) async {
    state = state.copyWith(
      status: forceLoading || state.status == AnalyticsStatus.initial
          ? AnalyticsStatus.loading
          : AnalyticsStatus.loaded,
      clearError: true,
    );

    final result = await _getAnalyticsSummaryUsecase(
      GetAnalyticsSummaryParams(months: months),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AnalyticsStatus.error,
        errorMessage: failure.message,
      ),
      (summary) => state = state.copyWith(
        status: AnalyticsStatus.loaded,
        summary: summary,
        clearError: true,
      ),
    );
  }
}
