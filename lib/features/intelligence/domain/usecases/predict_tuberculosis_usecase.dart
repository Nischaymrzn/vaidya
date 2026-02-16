import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/intelligence/data/repositories/prediction_repository.dart';
import 'package:vaidya/features/intelligence/domain/entities/prediction_entity.dart';
import 'package:vaidya/features/intelligence/domain/repositories/prediction_repository.dart';

final predictTuberculosisUsecaseProvider = Provider<PredictTuberculosisUsecase>((ref) {
  return PredictTuberculosisUsecase(repository: ref.read(predictionRepositoryProvider));
});

class PredictTuberculosisParams {
  final String imagePath;

  const PredictTuberculosisParams({required this.imagePath});
}

class PredictTuberculosisUsecase
    implements UsecaseWithParams<PredictionEntity, PredictTuberculosisParams> {
  final IPredictionRepository _repository;

  const PredictTuberculosisUsecase({required IPredictionRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, PredictionEntity>> call(PredictTuberculosisParams params) {
    return _repository.predictTuberculosis(params.imagePath);
  }
}
