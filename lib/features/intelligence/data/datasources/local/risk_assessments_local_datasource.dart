import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/services/hive/feature_cache_service.dart';
import 'package:vaidya/features/intelligence/data/datasources/risk_assessments_datasource.dart';
import 'package:vaidya/features/intelligence/data/models/risk_assessment_api_model.dart';
import 'package:vaidya/features/intelligence/data/models/risk_assessment_hive_model.dart';

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
  Future<void> cacheAssessments(List<RiskAssessmentApiModel> items) {
    final normalized = items
        .map((item) => RiskAssessmentHiveModel.fromApiModel(item).toJson())
        .toList(growable: false);
    return _cacheService.writeList(_itemsKey, normalized);
  }

  @override
  Future<List<RiskAssessmentApiModel>> getCachedAssessments() async {
    final cached = await _cacheService.readList(_itemsKey);
    return cached
        .map((item) => RiskAssessmentHiveModel.fromJson(item).toApiModel())
        .toList(growable: false);
  }
}
