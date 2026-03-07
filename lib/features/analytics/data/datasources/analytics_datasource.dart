import 'package:vaidya/features/analytics/data/models/analytics_summary_api_model.dart';

abstract interface class IAnalyticsRemoteDataSource {
  Future<AnalyticsSummaryApiModel> getSummary({int? months});
}

abstract interface class IAnalyticsLocalDataSource {
  Future<void> cacheSummary(AnalyticsSummaryApiModel summary);
  Future<AnalyticsSummaryApiModel?> getCachedSummary();
}
