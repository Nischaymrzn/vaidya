import 'package:vaidya/features/vitals/data/models/vital_api_model.dart';

abstract interface class IVitalsRemoteDataSource {
  Future<List<VitalApiModel>> getVitals();
  Future<VitalApiModel> createVital(Map<String, dynamic> payload);
  Future<VitalApiModel> updateVital(String id, Map<String, dynamic> payload);
  Future<void> deleteVital(String id);
  Future<Map<String, dynamic>> getVitalsSummary();
}

abstract interface class IVitalsLocalDataSource {
  Future<void> saveVitals(List<VitalApiModel> items);
  Future<List<VitalApiModel>> getVitals();
  Future<VitalApiModel?> getVitalById(String id);
  Future<VitalApiModel> upsertVital(VitalApiModel payload);
  Future<bool> removeVitalById(String id);
  Future<void> saveVitalsSummary(Map<String, dynamic> data);
  Future<Map<String, dynamic>?> getVitalsSummary();
}
