import 'package:dartz/dartz.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/features/dashboard/domain/entities/dashboard_summary_entity.dart';

abstract interface class IDashboardRepository {
  Future<Either<Failure, DashboardSummaryEntity>> getDashboardSummary();
}
