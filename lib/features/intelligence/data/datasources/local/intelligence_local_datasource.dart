import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/services/hive/feature_cache_service.dart';
import 'package:vaidya/features/intelligence/data/datasources/intelligence_datasource.dart';
import 'package:vaidya/features/intelligence/data/models/ai_insight_hive_model.dart';
import 'package:vaidya/features/intelligence/data/models/intelligence_api_model.dart';

final intelligenceLocalDataSourceProvider =
    Provider<IIntelligenceLocalDataSource>((ref) {
      return IntelligenceLocalDataSource(cacheService: ref.read(featureCacheServiceProvider));
    });

class IntelligenceLocalDataSource implements IIntelligenceLocalDataSource {
  final FeatureCacheService _cacheService;

  const IntelligenceLocalDataSource({required FeatureCacheService cacheService})
      : _cacheService = cacheService;

  static const String _insightsKey = 'intelligence_ai_insights';

  @override
  Future<void> cacheInsights(List<AiInsightApiModel> items) {
    final normalized = items
        .map((item) => AiInsightHiveModel.fromApiModel(item).toJson())
        .toList(growable: false);
    return _cacheService.writeList(_insightsKey, normalized);
  }

  @override
  Future<List<AiInsightApiModel>> getCachedInsights() async {
    final cached = await _cacheService.readList(_insightsKey);
    return cached
        .map((item) => AiInsightHiveModel.fromJson(item).toApiModel())
        .toList(growable: false);
  }
}
