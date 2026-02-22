import 'package:vaidya/features/symptoms/data/models/symptom_api_model.dart';

abstract interface class ISymptomsRemoteDataSource {
  Future<List<SymptomApiModel>> getSymptoms();
  Future<SymptomApiModel> createSymptom(Map<String, dynamic> payload);
  Future<SymptomApiModel> updateSymptom(String id, Map<String, dynamic> payload);
  Future<void> deleteSymptom(String id);
  Future<Map<String, dynamic>> getSymptomsSummary();
}

abstract interface class ISymptomsLocalDataSource {
  Future<void> cacheSymptoms(List<SymptomApiModel> items);
  Future<List<SymptomApiModel>> getCachedSymptoms();
  Future<SymptomApiModel?> getCachedSymptomById(String id);
  Future<SymptomApiModel> upsertSymptom(SymptomApiModel payload);
  Future<bool> removeSymptomById(String id);
  Future<void> cacheSymptomsSummary(Map<String, dynamic> payload);
  Future<Map<String, dynamic>?> getCachedSymptomsSummary();
}
