import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/api/api_client.dart';
import 'package:vaidya/core/api/api_endpoints.dart';
import 'package:vaidya/features/intelligence/data/datasources/risk_assessments_datasource.dart';
import 'package:vaidya/features/intelligence/data/models/risk_assessment_api_model.dart';

final riskAssessmentsRemoteDataSourceProvider =
    Provider<IRiskAssessmentsRemoteDataSource>((ref) {
      return RiskAssessmentsRemoteDataSource(apiClient: ref.read(apiClientProvider));
    });

class RiskAssessmentsRemoteDataSource implements IRiskAssessmentsRemoteDataSource {
  final ApiClient _apiClient;

  const RiskAssessmentsRemoteDataSource({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<RiskAssessmentApiModel>> getAssessments() async {
    final response = await _apiClient.get(ApiEndpoints.riskAssessments);

    if (response.data['success'] == true) {
      final raw = response.data['data'] ?? response.data;
      return RiskAssessmentApiModel.fromJsonList(raw);
    }

    throw Exception(response.data['message'] ?? 'Failed to fetch risk assessments');
  }

  @override
  Future<RiskAssessmentApiModel> getAssessmentById(String id) async {
    final response = await _apiClient.get(ApiEndpoints.riskAssessmentById(id));

    if (response.data['success'] == true) {
      final raw = response.data['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
      return RiskAssessmentApiModel.fromJson(raw);
    }

    throw Exception(response.data['message'] ?? 'Failed to fetch risk assessment');
  }

  @override
  Future<RiskAssessmentGenerateApiModel> generateAssessment(Map<String, dynamic> payload) async {
    final response = await _apiClient.post(ApiEndpoints.riskGenerate, data: payload);

    if (response.data['success'] == true) {
      final raw = response.data['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
      return RiskAssessmentGenerateApiModel.fromJson(raw);
    }

    throw Exception(response.data['message'] ?? 'Failed to generate risk assessment');
  }
}
