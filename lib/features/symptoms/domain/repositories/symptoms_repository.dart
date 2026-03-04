import 'package:dartz/dartz.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/features/symptoms/domain/entities/symptom_entity.dart';

abstract interface class ISymptomsRepository {
  Future<Either<Failure, List<SymptomEntity>>> getSymptoms();
  Future<Either<Failure, SymptomEntity>> createSymptom(Map<String, dynamic> payload);
  Future<Either<Failure, SymptomEntity>> updateSymptom(String id, Map<String, dynamic> payload);
  Future<Either<Failure, bool>> deleteSymptom(String id);
  Future<Either<Failure, SymptomsSummaryEntity>> getSymptomsSummary();
}
