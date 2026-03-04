import 'package:vaidya/features/vitals/data/models/vital_api_model.dart';

abstract interface class IVitalsRemoteDataSource {
  Future<List<VitalApiModel>> getVitals();
  Future<VitalApiModel> createVital(Map<String, dynamic> payload);
  Future<VitalApiModel> updateVital(String id, Map<String, dynamic> payload);
  Future<void> deleteVital(String id);
  Future<Map<String, dynamic>> getVitalsSummary();
}

abstract interface class IVitalsLocalDataSource {
  Future<void> cacheVitals(List<Map<String, dynamic>> items);
  Future<List<Map<String, dynamic>>> getCachedVitals();
  Future<void> cacheVitalsSummary(Map<String, dynamic> payload);
  Future<Map<String, dynamic>?> getCachedVitalsSummary();
}
