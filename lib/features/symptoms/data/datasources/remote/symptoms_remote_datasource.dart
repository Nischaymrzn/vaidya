import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/api/api_client.dart';
import 'package:vaidya/core/api/api_endpoints.dart';
import 'package:vaidya/features/symptoms/data/datasources/symptoms_datasource.dart';
import 'package:vaidya/features/symptoms/data/models/symptom_api_model.dart';

final symptomsRemoteDataSourceProvider = Provider<ISymptomsRemoteDataSource>((ref) {
  return SymptomsRemoteDataSource(apiClient: ref.read(apiClientProvider));
});

class SymptomsRemoteDataSource implements ISymptomsRemoteDataSource {
  final ApiClient _apiClient;

  const SymptomsRemoteDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<List<SymptomApiModel>> getSymptoms() async {
    final response = await _apiClient.get(ApiEndpoints.symptoms);
    if (response.data['success'] == true) {
      final raw = response.data['data'] ?? response.data;
      return SymptomApiModel.fromJsonList(raw);
    }
    throw Exception(response.data['message'] ?? 'Failed to fetch symptoms');
  }

  @override
  Future<SymptomApiModel> createSymptom(Map<String, dynamic> payload) async {
    final response = await _apiClient.post(ApiEndpoints.symptoms, data: payload);
    if (response.data['success'] == true) {
      final raw = (response.data['data'] as Map<String, dynamic>? ?? <String, dynamic>{});
      return SymptomApiModel.fromJson(raw);
    }
    throw Exception(response.data['message'] ?? 'Failed to create symptom');
  }

  @override
  Future<SymptomApiModel> updateSymptom(String id, Map<String, dynamic> payload) async {
    final response = await _apiClient.patch(ApiEndpoints.symptomById(id), data: payload);
    if (response.data['success'] == true) {
      final raw = (response.data['data'] as Map<String, dynamic>? ?? <String, dynamic>{});
      return SymptomApiModel.fromJson(raw);
    }
    throw Exception(response.data['message'] ?? 'Failed to update symptom');
  }

  @override
  Future<void> deleteSymptom(String id) async {
    final response = await _apiClient.delete(ApiEndpoints.symptomById(id));
    if (response.data['success'] == true) return;
    throw Exception(response.data['message'] ?? 'Failed to delete symptom');
  }

  @override
  Future<Map<String, dynamic>> getSymptomsSummary() async {
    final response = await _apiClient.get(ApiEndpoints.symptoms);
    if (response.data['success'] == true) {
      final raw = response.data['data'];
      final count = raw is List ? raw.length : 0;
      return {'total': count};
    }
    throw Exception(response.data['message'] ?? 'Failed to fetch symptoms summary');
  }
}
