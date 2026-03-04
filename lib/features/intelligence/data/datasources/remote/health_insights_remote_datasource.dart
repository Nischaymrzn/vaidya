import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/api/api_client.dart';
import 'package:vaidya/core/api/api_endpoints.dart';
import 'package:vaidya/features/intelligence/data/datasources/health_insights_datasource.dart';
import 'package:vaidya/features/intelligence/data/models/health_insight_api_model.dart';

final healthInsightsRemoteDataSourceProvider =
    Provider<IHealthInsightsRemoteDataSource>((ref) {
      return HealthInsightsRemoteDataSource(apiClient: ref.read(apiClientProvider));
    });

class HealthInsightsRemoteDataSource implements IHealthInsightsRemoteDataSource {
  final ApiClient _apiClient;

  const HealthInsightsRemoteDataSource({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<HealthInsightApiModel>> getInsights({String? riskId}) async {
    final response = await _apiClient.get(
      ApiEndpoints.healthInsights,
      queryParameters: riskId != null && riskId.trim().isNotEmpty
          ? {'riskId': riskId.trim()}
          : null,
    );

    if (response.data['success'] == true) {
      final raw = response.data['data'] ?? response.data;
      return HealthInsightApiModel.fromJsonList(raw);
    }

    throw Exception(response.data['message'] ?? 'Failed to fetch health insights');
  }

  @override
  Future<HealthInsightApiModel> getInsightById(String id) async {
    final response = await _apiClient.get(ApiEndpoints.healthInsightById(id));

    if (response.data['success'] == true) {
      final raw = response.data['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
      return HealthInsightApiModel.fromJson(raw);
    }

    throw Exception(response.data['message'] ?? 'Failed to fetch health insight');
  }
}
