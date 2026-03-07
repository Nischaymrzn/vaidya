import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/services/hive/feature_cache_service.dart';
import 'package:vaidya/features/intelligence/data/datasources/prediction_datasource.dart';
import 'package:vaidya/features/intelligence/data/models/prediction_api_model.dart';
import 'package:vaidya/features/intelligence/data/models/prediction_hive_model.dart';

final predictionLocalDataSourceProvider = Provider<IPredictionLocalDataSource>((ref) {
  return PredictionLocalDataSource(cacheService: ref.read(featureCacheServiceProvider));
});

class PredictionLocalDataSource implements IPredictionLocalDataSource {
  final FeatureCacheService _cacheService;

  const PredictionLocalDataSource({required FeatureCacheService cacheService})
      : _cacheService = cacheService;

  String _key(String key) => 'prediction_$key';

  @override
  Future<void> cacheResult(String key, PredictionApiModel result) {
    final model = PredictionHiveModel.fromApiModel(result);
    return _cacheService.writeMap(_key(key), model.toJson());
  }

  @override
  Future<PredictionApiModel?> getCachedResult(String key) async {
    final cached = await _cacheService.readMap(_key(key));
    if (cached == null) return null;
    return PredictionHiveModel.fromJson(cached).toApiModel();
  }
}
