import 'package:dartz/dartz.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/features/records/domain/entities/medical_record_entity.dart';
import 'package:vaidya/features/records/domain/entities/record_support_entity.dart';

abstract interface class IRecordsRepository {
  Future<Either<Failure, MedicalRecordsResultEntity>> getMedicalRecords({
    required int page,
    required int limit,
    String? userId,
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

  Future<Either<Failure, List<MedicationEntity>>> getMedications({
    String? userId,
  });
  Future<Either<Failure, MedicationEntity>> getMedicationById(String id);
  Future<Either<Failure, MedicationEntity>> createMedication(
    MedicationUpsertEntity payload,
  );
  Future<Either<Failure, MedicationEntity>> updateMedication(
    String id,
    MedicationUpsertEntity payload,
  );
  Future<Either<Failure, bool>> deleteMedication(String id);

  Future<Either<Failure, List<AllergyEntity>>> getAllergies({String? userId});
  Future<Either<Failure, AllergyEntity>> getAllergyById(String id);
  Future<Either<Failure, AllergyEntity>> createAllergy(
    AllergyUpsertEntity payload,
  );
  Future<Either<Failure, AllergyEntity>> updateAllergy(
    String id,
    AllergyUpsertEntity payload,
  );
  Future<Either<Failure, bool>> deleteAllergy(String id);

  Future<Either<Failure, List<ImmunizationEntity>>> getImmunizations({
    String? userId,
  });
  Future<Either<Failure, ImmunizationEntity>> getImmunizationById(String id);
  Future<Either<Failure, ImmunizationEntity>> createImmunization(
    ImmunizationUpsertEntity payload,
  );
  Future<Either<Failure, ImmunizationEntity>> updateImmunization(
    String id,
    ImmunizationUpsertEntity payload,
  );
  Future<Either<Failure, bool>> deleteImmunization(String id);
}
