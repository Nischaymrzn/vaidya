import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/intelligence/data/repositories/prediction_repository.dart';
import 'package:vaidya/features/intelligence/domain/entities/prediction_entity.dart';
import 'package:vaidya/features/intelligence/domain/repositories/prediction_repository.dart';

final predictDiabetesUsecaseProvider = Provider<PredictDiabetesUsecase>((ref) {
  return PredictDiabetesUsecase(repository: ref.read(predictionRepositoryProvider));
});

class PredictDiabetesParams {
  final Map<String, dynamic> payload;

  const PredictDiabetesParams({required this.payload});
}

class PredictDiabetesUsecase
    implements UsecaseWithParams<PredictionEntity, PredictDiabetesParams> {
  final IPredictionRepository _repository;

  const PredictDiabetesUsecase({required IPredictionRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, PredictionEntity>> call(PredictDiabetesParams params) {
    return _repository.predictDiabetes(params.payload);
  }
}
