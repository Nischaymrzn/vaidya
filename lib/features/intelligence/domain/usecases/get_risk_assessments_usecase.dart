import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/intelligence/data/repositories/risk_assessments_repository.dart';
import 'package:vaidya/features/intelligence/domain/entities/risk_assessment_entity.dart';
import 'package:vaidya/features/intelligence/domain/repositories/risk_assessments_repository.dart';

final getRiskAssessmentsUsecaseProvider = Provider<GetRiskAssessmentsUsecase>((ref) {
  return GetRiskAssessmentsUsecase(repository: ref.read(riskAssessmentsRepositoryProvider));
});

class GetRiskAssessmentsUsecase
    implements UsecaseWithoutParams<List<RiskAssessmentEntity>> {
  final IRiskAssessmentsRepository _repository;

  const GetRiskAssessmentsUsecase({required IRiskAssessmentsRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, List<RiskAssessmentEntity>>> call() => _repository.getAssessments();
}

final getRiskAssessmentByIdUsecaseProvider = Provider<GetRiskAssessmentByIdUsecase>((ref) {
  return GetRiskAssessmentByIdUsecase(repository: ref.read(riskAssessmentsRepositoryProvider));
});

class GetRiskAssessmentByIdParams {
  final String id;

  const GetRiskAssessmentByIdParams({required this.id});
}

class GetRiskAssessmentByIdUsecase
    implements UsecaseWithParams<RiskAssessmentEntity, GetRiskAssessmentByIdParams> {
  final IRiskAssessmentsRepository _repository;

  const GetRiskAssessmentByIdUsecase({required IRiskAssessmentsRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, RiskAssessmentEntity>> call(GetRiskAssessmentByIdParams params) {
    return _repository.getAssessmentById(params.id);
  }
}
