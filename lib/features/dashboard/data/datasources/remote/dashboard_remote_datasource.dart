import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/api/api_client.dart';
import 'package:vaidya/core/api/api_endpoints.dart';
import 'package:vaidya/features/dashboard/data/datasources/dashboard_datasource.dart';
import 'package:vaidya/features/dashboard/data/models/dashboard_summary_api_model.dart';

final dashboardRemoteDataSourceProvider = Provider<IDashboardRemoteDataSource>((
  ref,
) {
  return DashboardRemoteDataSource(apiClient: ref.read(apiClientProvider));
});

class DashboardRemoteDataSource implements IDashboardRemoteDataSource {
  final ApiClient _apiClient;

  DashboardRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<DashboardSummaryApiModel> getDashboardSummary() async {
    final response = await _apiClient.get(ApiEndpoints.dashboardSummary);

    if (response.data['success'] == true) {
      final payload =
          (response.data['data'] as Map<String, dynamic>? ??
          <String, dynamic>{});
      return DashboardSummaryApiModel.fromJson(payload);
    }

    throw Exception(response.data['message'] ?? 'Failed to fetch dashboard');
  }
}
