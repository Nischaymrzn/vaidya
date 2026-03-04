import 'package:vaidya/features/records/data/models/medical_record_api_model.dart';
import 'package:vaidya/features/records/data/models/medical_record_upsert_api_model.dart';

abstract interface class IRecordsRemoteDataSource {
  Future<MedicalRecordsResultApiModel> getMedicalRecords({
    required int page,
    required int limit,
  });
  Future<MedicalRecordApiModel> getMedicalRecordById(String id);

  Future<MedicalRecordApiModel> createMedicalRecord(
    MedicalRecordUpsertApiModel payload,
  );

  Future<MedicalRecordApiModel> updateMedicalRecord(
    String id,
    MedicalRecordUpsertApiModel payload,
  );

  Future<void> deleteMedicalRecord(String id);

  Future<AiScanResultApiModel> scanMedicalImage(String imagePath);
}

