import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/api/api_client.dart';
import 'package:vaidya/core/api/api_endpoints.dart';
import 'package:vaidya/features/analytics/data/datasources/analytics_datasource.dart';
import 'package:vaidya/features/analytics/data/models/analytics_summary_api_model.dart';

final analyticsRemoteDataSourceProvider = Provider<IAnalyticsRemoteDataSource>(
  (ref) {
    return AnalyticsRemoteDataSource(apiClient: ref.read(apiClientProvider));
  },
);

class AnalyticsRemoteDataSource implements IAnalyticsRemoteDataSource {
  final ApiClient _apiClient;

  const AnalyticsRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<AnalyticsSummaryApiModel> getSummary({int? months}) async {
    final response = await _apiClient.get(
      ApiEndpoints.analyticsSummary,
      queryParameters: months != null ? {'months': months} : null,
    );

    if (response.data['success'] == true) {
      final payload =
          (response.data['data'] as Map<String, dynamic>? ??
              <String, dynamic>{});
      return AnalyticsSummaryApiModel.fromJson(payload);
    }

    throw Exception(response.data['message'] ?? 'Failed to fetch analytics');
  }
}
