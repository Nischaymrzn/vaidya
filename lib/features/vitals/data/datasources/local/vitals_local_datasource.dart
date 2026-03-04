import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/services/hive/feature_cache_service.dart';
import 'package:vaidya/features/vitals/data/datasources/vitals_datasource.dart';

final vitalsLocalDataSourceProvider = Provider<IVitalsLocalDataSource>((ref) {
  return VitalsLocalDataSource(cacheService: ref.read(featureCacheServiceProvider));
});

class VitalsLocalDataSource implements IVitalsLocalDataSource {
  final FeatureCacheService _cacheService;

  const VitalsLocalDataSource({required FeatureCacheService cacheService})
      : _cacheService = cacheService;

  static const String _itemsKey = 'vitals_items';
  static const String _summaryKey = 'vitals_summary';

  @override
  Future<void> cacheVitals(List<Map<String, dynamic>> items) {
    return _cacheService.writeList(_itemsKey, items);
  }

  @override
  Future<List<Map<String, dynamic>>> getCachedVitals() {
    return _cacheService.readList(_itemsKey);
  }

  @override
  Future<void> cacheVitalsSummary(Map<String, dynamic> payload) {
    return _cacheService.writeMap(_summaryKey, payload);
  }

  @override
  Future<Map<String, dynamic>?> getCachedVitalsSummary() {
    return _cacheService.readMap(_summaryKey);
  }
}
