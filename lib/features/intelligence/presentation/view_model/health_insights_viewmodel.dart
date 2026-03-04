import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/features/intelligence/domain/usecases/get_health_insights_usecase.dart';
import 'package:vaidya/features/intelligence/presentation/state/health_insights_state.dart';

final healthInsightsViewModelProvider =
    NotifierProvider<HealthInsightsViewModel, HealthInsightsState>(
      HealthInsightsViewModel.new,
    );

class HealthInsightsViewModel extends Notifier<HealthInsightsState> {
  late final GetHealthInsightsUsecase _getHealthInsightsUsecase;
  late final GetHealthInsightByIdUsecase _getHealthInsightByIdUsecase;

  @override
  HealthInsightsState build() {
    _getHealthInsightsUsecase = ref.read(getHealthInsightsUsecaseProvider);
    _getHealthInsightByIdUsecase = ref.read(getHealthInsightByIdUsecaseProvider);
    return const HealthInsightsState();
  }

  Future<void> load({String? riskId, bool forceLoading = false}) async {
    state = state.copyWith(
      status: forceLoading || state.status == HealthInsightsStatus.initial
          ? HealthInsightsStatus.loading
          : HealthInsightsStatus.loaded,
      riskId: riskId ?? state.riskId,
      clearError: true,
    );

    final result = await _getHealthInsightsUsecase(
      GetHealthInsightsParams(riskId: riskId ?? state.riskId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: HealthInsightsStatus.error,
        errorMessage: failure.message,
      ),
      (items) => state = state.copyWith(
        status: HealthInsightsStatus.loaded,
        items: items,
        clearError: true,
      ),
    );
  }

  Future<void> getById(String id) async {
    state = state.copyWith(isSubmitting: true, clearError: true);

    final result = await _getHealthInsightByIdUsecase(
      GetHealthInsightByIdParams(id: id),
    );

    result.fold(
      (failure) => state = state.copyWith(
        isSubmitting: false,
        errorMessage: failure.message,
      ),
      (item) => state = state.copyWith(
        isSubmitting: false,
        selected: item,
        clearError: true,
      ),
    );
  }

  void clearMessages() {
    state = state.copyWith(clearError: true);
  }
}
