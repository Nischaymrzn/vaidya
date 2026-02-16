import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/features/intelligence/domain/usecases/generate_risk_assessment_usecase.dart';
import 'package:vaidya/features/intelligence/domain/usecases/get_risk_assessments_usecase.dart';
import 'package:vaidya/features/intelligence/presentation/state/risk_assessments_state.dart';

final riskAssessmentsViewModelProvider =
    NotifierProvider<RiskAssessmentsViewModel, RiskAssessmentsState>(
      RiskAssessmentsViewModel.new,
    );

class RiskAssessmentsViewModel extends Notifier<RiskAssessmentsState> {
  late final GetRiskAssessmentsUsecase _getRiskAssessmentsUsecase;
  late final GetRiskAssessmentByIdUsecase _getRiskAssessmentByIdUsecase;
  late final GenerateRiskAssessmentUsecase _generateRiskAssessmentUsecase;

  @override
  RiskAssessmentsState build() {
    _getRiskAssessmentsUsecase = ref.read(getRiskAssessmentsUsecaseProvider);
    _getRiskAssessmentByIdUsecase = ref.read(getRiskAssessmentByIdUsecaseProvider);
    _generateRiskAssessmentUsecase = ref.read(generateRiskAssessmentUsecaseProvider);
    return const RiskAssessmentsState();
  }

  Future<void> load({bool forceLoading = false}) async {
    state = state.copyWith(
      status: forceLoading || state.status == RiskAssessmentsStatus.initial
          ? RiskAssessmentsStatus.loading
          : RiskAssessmentsStatus.loaded,
      clearError: true,
    );

    final result = await _getRiskAssessmentsUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        status: RiskAssessmentsStatus.error,
        errorMessage: failure.message,
      ),
      (items) => state = state.copyWith(
        status: RiskAssessmentsStatus.loaded,
        items: items,
        clearError: true,
      ),
    );
  }

  Future<void> getById(String id) async {
    state = state.copyWith(isSubmitting: true, clearError: true);

    final result =
        await _getRiskAssessmentByIdUsecase(GetRiskAssessmentByIdParams(id: id));

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

  Future<bool> generate({Map<String, dynamic> payload = const {}}) async {
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearActionMessage: true,
    );

    final result = await _generateRiskAssessmentUsecase(
      GenerateRiskAssessmentParams(payload: payload),
    );

    bool ok = false;
    String? message;

    result.fold(
      (failure) => message = failure.message,
      (generated) {
        ok = true;
        state = state.copyWith(generated: generated);
      },
    );

    if (!ok) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: message ?? 'Failed to generate risk assessment',
      );
      return false;
    }

    await load(forceLoading: false);
    state = state.copyWith(
      isSubmitting: false,
      actionMessage: 'Risk assessment generated successfully',
      clearError: true,
    );
    return true;
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearActionMessage: true);
  }
}
