import 'package:vaidya/features/intelligence/data/models/health_insight_api_model.dart';

abstract interface class IHealthInsightsRemoteDataSource {
  Future<List<HealthInsightApiModel>> getInsights({String? riskId});
  Future<HealthInsightApiModel> getInsightById(String id);
}

abstract interface class IHealthInsightsLocalDataSource {
  Future<void> cacheInsights(List<Map<String, dynamic>> items);
  Future<List<Map<String, dynamic>>> getCachedInsights();
}
