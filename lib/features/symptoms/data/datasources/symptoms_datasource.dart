import 'package:vaidya/features/symptoms/data/models/symptom_api_model.dart';

abstract interface class ISymptomsRemoteDataSource {
  Future<List<SymptomApiModel>> getSymptoms();
  Future<SymptomApiModel> createSymptom(Map<String, dynamic> payload);
  Future<SymptomApiModel> updateSymptom(String id, Map<String, dynamic> payload);
  Future<void> deleteSymptom(String id);
  Future<Map<String, dynamic>> getSymptomsSummary();
}

abstract interface class ISymptomsLocalDataSource {
  Future<void> cacheSymptoms(List<Map<String, dynamic>> items);
  Future<List<Map<String, dynamic>>> getCachedSymptoms();
  Future<void> cacheSymptomsSummary(Map<String, dynamic> payload);
  Future<Map<String, dynamic>?> getCachedSymptomsSummary();
}
