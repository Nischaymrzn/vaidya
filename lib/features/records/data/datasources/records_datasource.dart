import 'package:vaidya/features/records/data/models/medical_record_api_model.dart';
import 'package:vaidya/features/records/domain/entities/medical_record_entity.dart';
import 'package:vaidya/features/records/data/models/record_support_api_model.dart';

abstract interface class IRecordsRemoteDataSource {
  Future<MedicalRecordsResultApiModel> getMedicalRecords({
    required int page,
    required int limit,
    String? userId,
  });
  Future<MedicalRecordApiModel> getMedicalRecordById(String id);

  Future<MedicalRecordApiModel> createMedicalRecord(
    MedicalRecordUpsertEntity payload,
  );

  Future<MedicalRecordApiModel> updateMedicalRecord(
    String id,
    MedicalRecordUpsertEntity payload,
  );

  Future<void> deleteMedicalRecord(String id);

  Future<AiScanResultApiModel> scanMedicalImage(String imagePath);

  Future<List<MedicationApiModel>> getMedications({String? userId});
  Future<MedicationApiModel> getMedicationById(String id);
  Future<MedicationApiModel> createMedication(Map<String, dynamic> payload);
  Future<MedicationApiModel> updateMedication(
    String id,
    Map<String, dynamic> payload,
  );
  Future<void> deleteMedication(String id);

  Future<List<AllergyApiModel>> getAllergies({String? userId});
  Future<AllergyApiModel> getAllergyById(String id);
  Future<AllergyApiModel> createAllergy(Map<String, dynamic> payload);
  Future<AllergyApiModel> updateAllergy(
    String id,
    Map<String, dynamic> payload,
  );
  Future<void> deleteAllergy(String id);

  Future<List<ImmunizationApiModel>> getImmunizations({String? userId});
  Future<ImmunizationApiModel> getImmunizationById(String id);
  Future<ImmunizationApiModel> createImmunization(Map<String, dynamic> payload);
  Future<ImmunizationApiModel> updateImmunization(
    String id,
    Map<String, dynamic> payload,
  );
  Future<void> deleteImmunization(String id);
}

abstract interface class IRecordsLocalDataSource {
  Future<void> cacheMedicalRecords(MedicalRecordsResultApiModel result);

  Future<MedicalRecordsResultApiModel?> getCachedMedicalRecords();
  Future<MedicalRecordApiModel?> getCachedMedicalRecordById(String id);
  Future<MedicalRecordApiModel> upsertMedicalRecord(MedicalRecordApiModel record);
  Future<bool> removeMedicalRecordById(String id);

  Future<void> cacheMedications(List<MedicationApiModel> medications);

  Future<List<MedicationApiModel>> getCachedMedications();
  Future<MedicationApiModel?> getCachedMedicationById(String id);
  Future<MedicationApiModel> upsertMedication(MedicationApiModel medication);
  Future<bool> removeMedicationById(String id);

  Future<void> cacheAllergies(List<AllergyApiModel> allergies);

  Future<List<AllergyApiModel>> getCachedAllergies();
  Future<AllergyApiModel?> getCachedAllergyById(String id);
  Future<AllergyApiModel> upsertAllergy(AllergyApiModel allergy);
  Future<bool> removeAllergyById(String id);

  Future<void> cacheImmunizations(List<ImmunizationApiModel> immunizations);

  Future<List<ImmunizationApiModel>> getCachedImmunizations();
  Future<ImmunizationApiModel?> getCachedImmunizationById(String id);
  Future<ImmunizationApiModel> upsertImmunization(ImmunizationApiModel immunization);
  Future<bool> removeImmunizationById(String id);

  Future<void> enqueuePendingMedicalRecordOperation(
    Map<String, dynamic> operation,
  );
  Future<List<Map<String, dynamic>>> getPendingMedicalRecordOperations();
  Future<void> savePendingMedicalRecordOperations(
    List<Map<String, dynamic>> operations,
  );
  Future<void> clearPendingMedicalRecordOperations();
}
