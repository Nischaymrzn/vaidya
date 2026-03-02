import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/services/hive/feature_cache_service.dart';
import 'package:vaidya/features/intelligence/data/datasources/health_insights_datasource.dart';
import 'package:vaidya/features/intelligence/data/models/health_insight_api_model.dart';
import 'package:vaidya/features/intelligence/data/models/health_insight_hive_model.dart';

final healthInsightsLocalDataSourceProvider =
    Provider<IHealthInsightsLocalDataSource>((ref) {
      return HealthInsightsLocalDataSource(
        saveService: ref.read(featureCacheServiceProvider),
      );
    });

class HealthInsightsLocalDataSource implements IHealthInsightsLocalDataSource {
  final FeatureCacheService _cacheService;

  const HealthInsightsLocalDataSource({
    required FeatureCacheService saveService,
  }) : _cacheService = saveService;

  static const String _itemsKey = 'health_insights_items';

  @override
  Future<void> saveInsights(List<HealthInsightApiModel> items) {
    final normalized = items
        .map((item) => HealthInsightHiveModel.fromApiModel(item).toJson())
        .toList(growable: false);
    return _cacheService.writeList(_itemsKey, normalized);
  }

  @override
  Future<List<HealthInsightApiModel>> getInsights() async {
    final cached = await _cacheService.readList(_itemsKey);
    return cached
        .map((item) => HealthInsightHiveModel.fromJson(item).toApiModel())
        .toList(growable: false);
  }
}
