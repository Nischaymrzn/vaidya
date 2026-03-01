import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/services/hive/feature_cache_service.dart';
import 'package:vaidya/features/family_health/data/datasources/family_health_datasource.dart';
import 'package:vaidya/features/family_health/data/models/family_group_api_model.dart';
import 'package:vaidya/features/family_health/data/models/family_group_hive_model.dart';

final familyHealthLocalDataSourceProvider =
    Provider<IFamilyHealthLocalDataSource>((ref) {
      return FamilyHealthLocalDataSource(
        saveService: ref.read(featureCacheServiceProvider),
      );
    });

class FamilyHealthLocalDataSource implements IFamilyHealthLocalDataSource {
  final FeatureCacheService _cacheService;

  const FamilyHealthLocalDataSource({required FeatureCacheService saveService})
    : _cacheService = saveService;

  static const String _groupKey = 'family_group';
  static const String _summaryKey = 'family_group_summary';

  @override
  Future<void> saveGroup(FamilyGroupApiModel data) {
    final hiveModel = FamilyGroupHiveModel.fromApiModel(data);
    return _cacheService.writeMap(_groupKey, hiveModel.toJson());
  }

  @override
  Future<FamilyGroupApiModel?> getGroup() async {
    final cached = await _cacheService.readMap(_groupKey);
    if (cached == null) return null;
    final hiveModel = FamilyGroupHiveModel.fromJson(cached);
    return hiveModel.toApiModel();
  }

  @override
  Future<void> saveSummary(FamilyGroupSummaryApiModel data) {
    final hiveModel = FamilyGroupSummaryHiveModel.fromApiModel(data);
    return _cacheService.writeMap(_summaryKey, hiveModel.toJson());
  }

  @override
  Future<FamilyGroupSummaryApiModel?> getSummary() async {
    final cached = await _cacheService.readMap(_summaryKey);
    if (cached == null) return null;
    final hiveModel = FamilyGroupSummaryHiveModel.fromJson(cached);
    return hiveModel.toApiModel();
  }
}
