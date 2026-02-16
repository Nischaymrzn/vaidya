import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/services/hive/feature_cache_service.dart';
import 'package:vaidya/features/symptoms/data/datasources/symptoms_datasource.dart';

final symptomsLocalDataSourceProvider = Provider<ISymptomsLocalDataSource>((ref) {
  return SymptomsLocalDataSource(cacheService: ref.read(featureCacheServiceProvider));
});

class SymptomsLocalDataSource implements ISymptomsLocalDataSource {
  final FeatureCacheService _cacheService;

  const SymptomsLocalDataSource({required FeatureCacheService cacheService})
      : _cacheService = cacheService;

  static const String _itemsKey = 'symptoms_items';
  static const String _summaryKey = 'symptoms_summary';

  @override
  Future<void> cacheSymptoms(List<Map<String, dynamic>> items) {
    return _cacheService.writeList(_itemsKey, items);
  }

  @override
  Future<List<Map<String, dynamic>>> getCachedSymptoms() {
    return _cacheService.readList(_itemsKey);
  }

  @override
  Future<void> cacheSymptomsSummary(Map<String, dynamic> payload) {
    return _cacheService.writeMap(_summaryKey, payload);
  }

  @override
  Future<Map<String, dynamic>?> getCachedSymptomsSummary() {
    return _cacheService.readMap(_summaryKey);
  }
}
