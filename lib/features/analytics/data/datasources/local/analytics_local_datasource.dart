import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/services/hive/feature_cache_service.dart';
import 'package:vaidya/features/analytics/data/datasources/analytics_datasource.dart';
import 'package:vaidya/features/analytics/data/models/analytics_summary_api_model.dart';
import 'package:vaidya/features/analytics/data/models/analytics_summary_hive_model.dart';

final analyticsLocalDataSourceProvider = Provider<IAnalyticsLocalDataSource>((
  ref,
) {
  return AnalyticsLocalDataSource(
    saveService: ref.read(featureCacheServiceProvider),
  );
});

class AnalyticsLocalDataSource implements IAnalyticsLocalDataSource {
  final FeatureCacheService _cacheService;

  const AnalyticsLocalDataSource({required FeatureCacheService saveService})
    : _cacheService = saveService;

  static const String _cacheKey = 'analytics_summary';

  @override
  Future<void> saveSummary(AnalyticsSummaryApiModel summary) {
    final model = AnalyticsSummaryHiveModel.fromApiModel(summary);
    return _cacheService.writeMap(_cacheKey, model.toJson());
  }

  @override
  Future<AnalyticsSummaryApiModel?> getSummary() async {
    final cached = await _cacheService.readMap(_cacheKey);
    if (cached == null) return null;
    return AnalyticsSummaryHiveModel.fromJson(cached).toApiModel();
  }
}
