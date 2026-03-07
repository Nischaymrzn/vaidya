import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/api/api_client.dart';
import 'package:vaidya/core/api/api_endpoints.dart';
import 'package:vaidya/features/vitals/data/datasources/vitals_datasource.dart';
import 'package:vaidya/features/vitals/data/models/vital_api_model.dart';

final vitalsRemoteDataSourceProvider = Provider<IVitalsRemoteDataSource>((ref) {
  return VitalsRemoteDataSource(apiClient: ref.read(apiClientProvider));
});

class VitalsRemoteDataSource implements IVitalsRemoteDataSource {
  final ApiClient _apiClient;

  const VitalsRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<VitalApiModel>> getVitals() async {
    final response = await _apiClient.get(ApiEndpoints.vitals);
    if (response.data['success'] == true) {
      final raw = response.data['data'] ?? response.data;
      return VitalApiModel.fromJsonList(raw);
    }
    throw Exception(response.data['message'] ?? 'Failed to fetch vitals');
  }

  @override
  Future<VitalApiModel> createVital(Map<String, dynamic> payload) async {
    final response = await _apiClient.post(ApiEndpoints.vitals, data: payload);
    if (response.data['success'] == true) {
      final raw =
          (response.data['data'] as Map<String, dynamic>? ??
          <String, dynamic>{});
      return VitalApiModel.fromJson(raw);
    }
    throw Exception(response.data['message'] ?? 'Failed to create vital');
  }

  @override
  Future<VitalApiModel> updateVital(
    String id,
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.patch(
      ApiEndpoints.vitalById(id),
      data: payload,
    );
    if (response.data['success'] == true) {
      final raw =
          (response.data['data'] as Map<String, dynamic>? ??
          <String, dynamic>{});
      return VitalApiModel.fromJson(raw);
    }
    throw Exception(response.data['message'] ?? 'Failed to update vital');
  }

  @override
  Future<void> deleteVital(String id) async {
    final response = await _apiClient.delete(ApiEndpoints.vitalById(id));
    if (response.data['success'] == true) return;
    throw Exception(response.data['message'] ?? 'Failed to delete vital');
  }

  @override
  Future<Map<String, dynamic>> getVitalsSummary() async {
    final endpoint = ApiEndpoints.vitalsSummary;
    final response = await _apiClient.get(endpoint);
    if (response.data['success'] == true) {
      final raw =
          (response.data['data'] as Map<String, dynamic>? ??
          <String, dynamic>{});
      return raw;
    }
    throw Exception(
      response.data['message'] ?? 'Failed to fetch vitals summary',
    );
  }
}
