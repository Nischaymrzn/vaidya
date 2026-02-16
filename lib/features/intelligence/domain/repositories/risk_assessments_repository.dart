import 'package:dartz/dartz.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/features/intelligence/domain/entities/risk_assessment_entity.dart';

abstract interface class IRiskAssessmentsRepository {
  Future<Either<Failure, List<RiskAssessmentEntity>>> getAssessments();
  Future<Either<Failure, RiskAssessmentEntity>> getAssessmentById(String id);
  Future<Either<Failure, RiskAssessmentGenerateEntity>> generateAssessment(
    Map<String, dynamic> payload,
  );
}
