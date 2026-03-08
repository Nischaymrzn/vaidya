import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/services/hive/feature_cache_service.dart';
import 'package:vaidya/features/dashboard/data/datasources/dashboard_datasource.dart';
import 'package:vaidya/features/dashboard/data/models/dashboard_summary_api_model.dart';
import 'package:vaidya/features/dashboard/data/models/dashboard_summary_hive_model.dart';

final dashboardLocalDataSourceProvider = Provider<IDashboardLocalDataSource>((
  ref,
) {
  return DashboardLocalDataSource(
    saveService: ref.read(featureCacheServiceProvider),
  );
});

class DashboardLocalDataSource implements IDashboardLocalDataSource {
  final FeatureCacheService _cacheService;

  static const String _cacheKey = 'dashboard_summary';

  const DashboardLocalDataSource({required FeatureCacheService saveService})
    : _cacheService = saveService;

  @override
  Future<void> saveDashboardSummary(DashboardSummaryApiModel data) {
    final model = DashboardSummaryHiveModel.fromApiModel(data);
    return _cacheService.writeMap(_cacheKey, model.toJson());
  }

  @override
  Future<DashboardSummaryApiModel?> getDashboardSummary() async {
    final cached = await _cacheService.readMap(_cacheKey);
    if (cached == null) return null;
    return DashboardSummaryHiveModel.fromJson(cached).toApiModel();
  }
}
