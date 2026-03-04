import 'package:dartz/dartz.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/features/records/domain/entities/medical_record_entity.dart';

abstract interface class IRecordsRepository {
  Future<Either<Failure, MedicalRecordsResultEntity>> getMedicalRecords({
    required int page,
    required int limit,
  });
  Future<Either<Failure, MedicalRecordEntity>> getMedicalRecordById(String id);

  Future<Either<Failure, MedicalRecordEntity>> createMedicalRecord(
    MedicalRecordUpsertEntity payload,
  );

  Future<Either<Failure, MedicalRecordEntity>> updateMedicalRecord(
    String id,
    MedicalRecordUpsertEntity payload,
  );

  Future<Either<Failure, bool>> deleteMedicalRecord(String id);

  Future<Either<Failure, AiScanResultEntity>> scanMedicalImage(
    String imagePath,
  );
}

