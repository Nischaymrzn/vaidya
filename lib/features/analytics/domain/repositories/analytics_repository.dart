import 'package:dartz/dartz.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/features/analytics/domain/entities/analytics_summary_entity.dart';

abstract interface class IAnalyticsRepository {
  Future<Either<Failure, AnalyticsSummaryEntity>> getSummary({int? months});
}
