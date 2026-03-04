import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/intelligence/data/repositories/risk_assessments_repository.dart';
import 'package:vaidya/features/intelligence/domain/entities/risk_assessment_entity.dart';
import 'package:vaidya/features/intelligence/domain/repositories/risk_assessments_repository.dart';

final generateRiskAssessmentUsecaseProvider = Provider<GenerateRiskAssessmentUsecase>((ref) {
  return GenerateRiskAssessmentUsecase(repository: ref.read(riskAssessmentsRepositoryProvider));
});

class GenerateRiskAssessmentParams {
  final Map<String, dynamic> payload;

  const GenerateRiskAssessmentParams({this.payload = const {}});
}

class GenerateRiskAssessmentUsecase
    implements
        UsecaseWithParams<RiskAssessmentGenerateEntity, GenerateRiskAssessmentParams> {
  final IRiskAssessmentsRepository _repository;

  const GenerateRiskAssessmentUsecase({required IRiskAssessmentsRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, RiskAssessmentGenerateEntity>> call(
    GenerateRiskAssessmentParams params,
  ) {
    return _repository.generateAssessment(params.payload);
  }
}
