import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/services/hive/feature_cache_service.dart';
import 'package:vaidya/features/intelligence/data/datasources/intelligence_datasource.dart';

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
  Future<void> cacheInsights(List<Map<String, dynamic>> items) {
    return _cacheService.writeList(_insightsKey, items);
  }

  @override
  Future<List<Map<String, dynamic>>> getCachedInsights() {
    return _cacheService.readList(_insightsKey);
  }
}
