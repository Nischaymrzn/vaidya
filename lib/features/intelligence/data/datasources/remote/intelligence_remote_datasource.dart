import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/api/api_client.dart';
import 'package:vaidya/core/api/api_endpoints.dart';
import 'package:vaidya/features/intelligence/data/datasources/intelligence_datasource.dart';
import 'package:vaidya/features/intelligence/data/models/intelligence_api_model.dart';

final intelligenceRemoteDataSourceProvider =
    Provider<IIntelligenceRemoteDataSource>((ref) {
      return IntelligenceRemoteDataSource(apiClient: ref.read(apiClientProvider));
    });

class IntelligenceRemoteDataSource implements IIntelligenceRemoteDataSource {
  final ApiClient _apiClient;

  const IntelligenceRemoteDataSource({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<AiInsightApiModel>> generateInsights({
    required String input,
    required int maxItems,
    required bool force,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.aiInsights,
      data: {'input': input, 'maxItems': maxItems, 'force': force},
    );

    if (response.data['success'] == true) {
      final raw = response.data['data'] ?? response.data;
      return AiInsightApiModel.fromJsonList(raw);
    }

    throw Exception(response.data['message'] ?? 'Failed to generate AI insights');
  }

  @override
  Future<AiChatReplyApiModel> chat({
    required List<Map<String, String>> messages,
    String? doctor,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.aiChat,
      data: {
        'messages': messages,
        if (doctor != null && doctor.trim().isNotEmpty) 'doctor': doctor,
      },
    );

    if (response.data['success'] == true) {
      final payload = response.data as Map<String, dynamic>;
      return AiChatReplyApiModel.fromJson(payload);
    }

    throw Exception(response.data['message'] ?? 'Failed to get AI reply');
  }
}
