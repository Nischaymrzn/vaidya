import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/services/hive/feature_cache_service.dart';
import 'package:vaidya/features/intelligence/data/datasources/health_insights_datasource.dart';

final healthInsightsLocalDataSourceProvider =
    Provider<IHealthInsightsLocalDataSource>((ref) {
      return HealthInsightsLocalDataSource(cacheService: ref.read(featureCacheServiceProvider));
    });

class HealthInsightsLocalDataSource implements IHealthInsightsLocalDataSource {
  final FeatureCacheService _cacheService;

  const HealthInsightsLocalDataSource({required FeatureCacheService cacheService})
      : _cacheService = cacheService;

  static const String _itemsKey = 'health_insights_items';

  @override
  Future<void> cacheInsights(List<Map<String, dynamic>> items) {
    return _cacheService.writeList(_itemsKey, items);
  }

  @override
  Future<List<Map<String, dynamic>>> getCachedInsights() {
    return _cacheService.readList(_itemsKey);
  }
}
