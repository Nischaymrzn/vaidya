import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/features/intelligence/domain/entities/prediction_entity.dart';
import 'package:vaidya/features/intelligence/domain/usecases/predict_brain_tumor_usecase.dart';
import 'package:vaidya/features/intelligence/domain/usecases/predict_diabetes_usecase.dart';
import 'package:vaidya/features/intelligence/domain/usecases/predict_heart_disease_usecase.dart';
import 'package:vaidya/features/intelligence/domain/usecases/predict_symptom_usecase.dart';
import 'package:vaidya/features/intelligence/domain/usecases/predict_tuberculosis_usecase.dart';
import 'package:vaidya/features/intelligence/presentation/state/prediction_state.dart';

final predictionViewModelProvider =
    NotifierProvider<PredictionViewModel, PredictionState>(
      PredictionViewModel.new,
    );

class PredictionViewModel extends Notifier<PredictionState> {
  late final PredictSymptomUsecase _predictSymptomUsecase;
  late final PredictHeartDiseaseUsecase _predictHeartDiseaseUsecase;
  late final PredictDiabetesUsecase _predictDiabetesUsecase;
  late final PredictBrainTumorUsecase _predictBrainTumorUsecase;
  late final PredictTuberculosisUsecase _predictTuberculosisUsecase;

  @override
  PredictionState build() {
    _predictSymptomUsecase = ref.read(predictSymptomUsecaseProvider);
    _predictHeartDiseaseUsecase = ref.read(predictHeartDiseaseUsecaseProvider);
    _predictDiabetesUsecase = ref.read(predictDiabetesUsecaseProvider);
    _predictBrainTumorUsecase = ref.read(predictBrainTumorUsecaseProvider);
    _predictTuberculosisUsecase = ref.read(predictTuberculosisUsecaseProvider);
    return const PredictionState();
  }

  Future<bool> predictSymptom(List<String> symptoms) {
    return _runPrediction(
      () => _predictSymptomUsecase(PredictSymptomParams(symptoms: symptoms)),
      onSuccess: (value) => state = state.copyWith(symptom: value, status: PredictionStatus.loaded),
      successMessage: 'Symptom prediction generated',
    );
  }

  Future<bool> predictHeartDisease(Map<String, dynamic> payload) {
    return _runPrediction(
      () => _predictHeartDiseaseUsecase(PredictHeartDiseaseParams(payload: payload)),
      onSuccess: (value) =>
          state = state.copyWith(heartDisease: value, status: PredictionStatus.loaded),
      successMessage: 'Heart disease prediction generated',
    );
  }

  Future<bool> predictDiabetes(Map<String, dynamic> payload) {
    return _runPrediction(
      () => _predictDiabetesUsecase(PredictDiabetesParams(payload: payload)),
      onSuccess: (value) => state = state.copyWith(diabetes: value, status: PredictionStatus.loaded),
      successMessage: 'Diabetes prediction generated',
    );
  }

  Future<bool> predictBrainTumor(String imagePath) {
    return _runPrediction(
      () => _predictBrainTumorUsecase(PredictBrainTumorParams(imagePath: imagePath)),
      onSuccess: (value) => state = state.copyWith(brainTumor: value, status: PredictionStatus.loaded),
      successMessage: 'Brain tumor prediction generated',
    );
  }

  Future<bool> predictTuberculosis(String imagePath) {
    return _runPrediction(
      () => _predictTuberculosisUsecase(PredictTuberculosisParams(imagePath: imagePath)),
      onSuccess: (value) =>
          state = state.copyWith(tuberculosis: value, status: PredictionStatus.loaded),
      successMessage: 'Tuberculosis prediction generated',
    );
  }

  Future<bool> _runPrediction(
    Future<Either<Failure, PredictionEntity>> Function() run,
    {
    required void Function(PredictionEntity value) onSuccess,
    required String successMessage,
  }) async {
    state = state.copyWith(
      status: PredictionStatus.loading,
      isSubmitting: true,
      clearError: true,
      clearActionMessage: true,
    );

    final result = await run();

    bool ok = false;
    String? message;

    result.fold(
      (failure) => message = failure.message,
      (value) {
        ok = true;
        onSuccess(value);
      },
    );

    if (!ok) {
      state = state.copyWith(
        status: PredictionStatus.error,
        isSubmitting: false,
        errorMessage: message ?? 'Prediction failed',
      );
      return false;
    }

    state = state.copyWith(
      isSubmitting: false,
      actionMessage: successMessage,
      clearError: true,
    );
    return true;
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearActionMessage: true);
  }
}
