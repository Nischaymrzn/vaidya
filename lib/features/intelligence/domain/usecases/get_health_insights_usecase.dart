import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/intelligence/data/repositories/health_insights_repository.dart';
import 'package:vaidya/features/intelligence/domain/entities/health_insight_entity.dart';
import 'package:vaidya/features/intelligence/domain/repositories/health_insights_repository.dart';

final getHealthInsightsUsecaseProvider = Provider<GetHealthInsightsUsecase>((ref) {
  return GetHealthInsightsUsecase(repository: ref.read(healthInsightsRepositoryProvider));
});

class GetHealthInsightsParams {
  final String? riskId;

  const GetHealthInsightsParams({this.riskId});
}

class GetHealthInsightsUsecase
    implements UsecaseWithParams<List<HealthInsightEntity>, GetHealthInsightsParams> {
  final IHealthInsightsRepository _repository;

  const GetHealthInsightsUsecase({required IHealthInsightsRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, List<HealthInsightEntity>>> call(GetHealthInsightsParams params) {
    return _repository.getInsights(riskId: params.riskId);
  }
}

final getHealthInsightByIdUsecaseProvider = Provider<GetHealthInsightByIdUsecase>((ref) {
  return GetHealthInsightByIdUsecase(repository: ref.read(healthInsightsRepositoryProvider));
});

class GetHealthInsightByIdParams {
  final String id;

  const GetHealthInsightByIdParams({required this.id});
}

class GetHealthInsightByIdUsecase
    implements UsecaseWithParams<HealthInsightEntity, GetHealthInsightByIdParams> {
  final IHealthInsightsRepository _repository;

  const GetHealthInsightByIdUsecase({required IHealthInsightsRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, HealthInsightEntity>> call(GetHealthInsightByIdParams params) {
    return _repository.getInsightById(params.id);
  }
}
