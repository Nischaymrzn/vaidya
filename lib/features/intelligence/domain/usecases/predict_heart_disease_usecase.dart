import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/intelligence/data/repositories/prediction_repository.dart';
import 'package:vaidya/features/intelligence/domain/entities/prediction_entity.dart';
import 'package:vaidya/features/intelligence/domain/repositories/prediction_repository.dart';

final predictHeartDiseaseUsecaseProvider = Provider<PredictHeartDiseaseUsecase>((ref) {
  return PredictHeartDiseaseUsecase(repository: ref.read(predictionRepositoryProvider));
});

class PredictHeartDiseaseParams {
  final Map<String, dynamic> payload;

  const PredictHeartDiseaseParams({required this.payload});
}

class PredictHeartDiseaseUsecase
    implements UsecaseWithParams<PredictionEntity, PredictHeartDiseaseParams> {
  final IPredictionRepository _repository;

  const PredictHeartDiseaseUsecase({required IPredictionRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, PredictionEntity>> call(
    PredictHeartDiseaseParams params,
  ) {
    return _repository.predictHeartDisease(params.payload);
  }
}
