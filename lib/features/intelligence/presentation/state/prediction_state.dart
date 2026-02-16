import 'package:equatable/equatable.dart';
import 'package:vaidya/features/intelligence/domain/entities/prediction_entity.dart';

enum PredictionStatus { initial, loading, loaded, error }

class PredictionState extends Equatable {
  final PredictionStatus status;
  final PredictionEntity? symptom;
  final PredictionEntity? heartDisease;
  final PredictionEntity? diabetes;
  final PredictionEntity? brainTumor;
  final PredictionEntity? tuberculosis;
  final bool isSubmitting;
  final String? errorMessage;
  final String? actionMessage;

  const PredictionState({
    this.status = PredictionStatus.initial,
    this.symptom,
    this.heartDisease,
    this.diabetes,
    this.brainTumor,
    this.tuberculosis,
    this.isSubmitting = false,
    this.errorMessage,
    this.actionMessage,
  });

  PredictionState copyWith({
    PredictionStatus? status,
    PredictionEntity? symptom,
    PredictionEntity? heartDisease,
    PredictionEntity? diabetes,
    PredictionEntity? brainTumor,
    PredictionEntity? tuberculosis,
    bool? isSubmitting,
    String? errorMessage,
    String? actionMessage,
    bool clearError = false,
    bool clearActionMessage = false,
  }) {
    return PredictionState(
      status: status ?? this.status,
      symptom: symptom ?? this.symptom,
      heartDisease: heartDisease ?? this.heartDisease,
      diabetes: diabetes ?? this.diabetes,
      brainTumor: brainTumor ?? this.brainTumor,
      tuberculosis: tuberculosis ?? this.tuberculosis,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      actionMessage:
          clearActionMessage ? null : actionMessage ?? this.actionMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        symptom,
        heartDisease,
        diabetes,
        brainTumor,
        tuberculosis,
        isSubmitting,
        errorMessage,
        actionMessage,
      ];
}
