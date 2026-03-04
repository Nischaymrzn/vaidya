import 'package:dartz/dartz.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/features/vitals/domain/entities/vital_entity.dart';

abstract interface class IVitalsRepository {
  Future<Either<Failure, List<VitalEntity>>> getVitals();
  Future<Either<Failure, VitalEntity>> createVital(Map<String, dynamic> payload);
  Future<Either<Failure, VitalEntity>> updateVital(String id, Map<String, dynamic> payload);
  Future<Either<Failure, bool>> deleteVital(String id);
  Future<Either<Failure, VitalsSummaryEntity>> getVitalsSummary();
}
