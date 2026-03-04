import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/features/dashboard/domain/usecases/get_dashboard_summary_usecase.dart';
import 'package:vaidya/features/dashboard/presentation/state/dashboard_state.dart';

final dashboardViewModelProvider =
    NotifierProvider<DashboardViewModel, DashboardState>(
      DashboardViewModel.new,
    );

class DashboardViewModel extends Notifier<DashboardState> {
  late final GetDashboardSummaryUsecase _getDashboardSummaryUsecase;

  @override
  DashboardState build() {
    _getDashboardSummaryUsecase = ref.read(getDashboardSummaryUsecaseProvider);
    return const DashboardState();
  }

  Future<void> getDashboardSummary({bool forceLoading = false}) async {
    final shouldShowLoading =
        forceLoading || state.status == DashboardStatus.initial;

    state = state.copyWith(
      status: shouldShowLoading
          ? DashboardStatus.loading
          : DashboardStatus.loaded,
      clearError: true,
    );

    final result = await _getDashboardSummaryUsecase();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: DashboardStatus.error,
          errorMessage: failure.message,
        );
      },
      (summary) {
        state = state.copyWith(
          status: DashboardStatus.loaded,
          summary: summary,
          clearError: true,
        );
      },
    );
  }
}
