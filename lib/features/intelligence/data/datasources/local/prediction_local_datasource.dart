import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/services/hive/feature_cache_service.dart';
import 'package:vaidya/features/intelligence/data/datasources/prediction_datasource.dart';

final predictionLocalDataSourceProvider = Provider<IPredictionLocalDataSource>((ref) {
  return PredictionLocalDataSource(cacheService: ref.read(featureCacheServiceProvider));
});

class PredictionLocalDataSource implements IPredictionLocalDataSource {
  final FeatureCacheService _cacheService;

  const PredictionLocalDataSource({required FeatureCacheService cacheService})
      : _cacheService = cacheService;

  String _key(String key) => 'prediction_$key';

  @override
  Future<void> cacheResult(String key, Map<String, dynamic> result) {
    return _cacheService.writeMap(_key(key), result);
  }

  @override
  Future<Map<String, dynamic>?> getCachedResult(String key) {
    return _cacheService.readMap(_key(key));
  }
}
