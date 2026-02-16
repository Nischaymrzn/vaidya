import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/intelligence/data/repositories/prediction_repository.dart';
import 'package:vaidya/features/intelligence/domain/entities/prediction_entity.dart';
import 'package:vaidya/features/intelligence/domain/repositories/prediction_repository.dart';

final predictBrainTumorUsecaseProvider = Provider<PredictBrainTumorUsecase>((ref) {
  return PredictBrainTumorUsecase(repository: ref.read(predictionRepositoryProvider));
});

class PredictBrainTumorParams {
  final String imagePath;

  const PredictBrainTumorParams({required this.imagePath});
}

class PredictBrainTumorUsecase
    implements UsecaseWithParams<PredictionEntity, PredictBrainTumorParams> {
  final IPredictionRepository _repository;

  const PredictBrainTumorUsecase({required IPredictionRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, PredictionEntity>> call(PredictBrainTumorParams params) {
    return _repository.predictBrainTumor(params.imagePath);
  }
}
