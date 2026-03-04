import 'package:dartz/dartz.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/features/intelligence/domain/entities/health_insight_entity.dart';

abstract interface class IHealthInsightsRepository {
  Future<Either<Failure, List<HealthInsightEntity>>> getInsights({String? riskId});
  Future<Either<Failure, HealthInsightEntity>> getInsightById(String id);
}
