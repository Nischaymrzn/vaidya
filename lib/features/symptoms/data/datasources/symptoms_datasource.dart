import 'package:vaidya/features/symptoms/data/models/symptom_api_model.dart';

abstract interface class ISymptomsRemoteDataSource {
  Future<List<SymptomApiModel>> getSymptoms();
  Future<SymptomApiModel> createSymptom(Map<String, dynamic> payload);
  Future<SymptomApiModel> updateSymptom(
    String id,
    Map<String, dynamic> payload,
  );
  Future<void> deleteSymptom(String id);
  Future<Map<String, dynamic>> getSymptomsSummary();
}

abstract interface class ISymptomsLocalDataSource {
  Future<void> saveSymptoms(List<SymptomApiModel> items);
  Future<List<SymptomApiModel>> getSymptoms();
  Future<SymptomApiModel?> getSymptomById(String id);
  Future<SymptomApiModel> upsertSymptom(SymptomApiModel payload);
  Future<bool> removeSymptomById(String id);
  Future<void> saveSymptomsSummary(Map<String, dynamic> data);
  Future<Map<String, dynamic>?> getSymptomsSummary();
}
