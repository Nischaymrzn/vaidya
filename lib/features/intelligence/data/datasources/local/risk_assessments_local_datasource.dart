import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/services/hive/feature_cache_service.dart';
import 'package:vaidya/features/intelligence/data/datasources/risk_assessments_datasource.dart';

final riskAssessmentsLocalDataSourceProvider =
    Provider<IRiskAssessmentsLocalDataSource>((ref) {
      return RiskAssessmentsLocalDataSource(cacheService: ref.read(featureCacheServiceProvider));
    });

class RiskAssessmentsLocalDataSource implements IRiskAssessmentsLocalDataSource {
  final FeatureCacheService _cacheService;

  const RiskAssessmentsLocalDataSource({required FeatureCacheService cacheService})
      : _cacheService = cacheService;

  static const String _itemsKey = 'risk_assessments_items';

  @override
  Future<void> cacheAssessments(List<Map<String, dynamic>> items) {
    return _cacheService.writeList(_itemsKey, items);
  }

  @override
  Future<List<Map<String, dynamic>>> getCachedAssessments() {
    return _cacheService.readList(_itemsKey);
  }
}
