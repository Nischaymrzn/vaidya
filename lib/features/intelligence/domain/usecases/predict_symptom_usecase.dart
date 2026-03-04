import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/intelligence/data/repositories/prediction_repository.dart';
import 'package:vaidya/features/intelligence/domain/entities/prediction_entity.dart';
import 'package:vaidya/features/intelligence/domain/repositories/prediction_repository.dart';

final predictSymptomUsecaseProvider = Provider<PredictSymptomUsecase>((ref) {
  return PredictSymptomUsecase(repository: ref.read(predictionRepositoryProvider));
});

class PredictSymptomParams {
  final List<String> symptoms;

  const PredictSymptomParams({required this.symptoms});
}

class PredictSymptomUsecase
    implements UsecaseWithParams<PredictionEntity, PredictSymptomParams> {
  final IPredictionRepository _repository;

  const PredictSymptomUsecase({required IPredictionRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, PredictionEntity>> call(PredictSymptomParams params) {
    return _repository.predictSymptom(params.symptoms);
  }
}
