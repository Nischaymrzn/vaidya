import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/services/hive/feature_cache_service.dart';
import 'package:vaidya/features/analytics/data/datasources/analytics_datasource.dart';

final analyticsLocalDataSourceProvider = Provider<IAnalyticsLocalDataSource>((
  ref,
) {
  return AnalyticsLocalDataSource(
    cacheService: ref.read(featureCacheServiceProvider),
  );
});

class AnalyticsLocalDataSource implements IAnalyticsLocalDataSource {
  final FeatureCacheService _cacheService;

  const AnalyticsLocalDataSource({required FeatureCacheService cacheService})
    : _cacheService = cacheService;

  static const String _cacheKey = 'analytics_summary';

  @override
  Future<void> cacheSummary(Map<String, dynamic> summary) {
    return _cacheService.writeMap(_cacheKey, summary);
  }

  @override
  Future<Map<String, dynamic>?> getCachedSummary() {
    return _cacheService.readMap(_cacheKey);
  }
}
