import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/services/hive/feature_cache_service.dart';
import 'package:vaidya/features/dashboard/data/datasources/user_data_datasource.dart';
import 'package:vaidya/features/dashboard/data/models/user_data_api_model.dart';
import 'package:vaidya/features/dashboard/data/models/user_data_hive_model.dart';

final userDataLocalDataSourceProvider = Provider<IUserDataLocalDataSource>((ref) {
  return UserDataLocalDataSource(cacheService: ref.read(featureCacheServiceProvider));
});

class UserDataLocalDataSource implements IUserDataLocalDataSource {
  final FeatureCacheService _cacheService;

  const UserDataLocalDataSource({required FeatureCacheService cacheService})
      : _cacheService = cacheService;

  static const String _cacheKey = 'user_data_payload';

  @override
  Future<void> cacheUserData(UserDataApiModel payload) {
    final model = UserDataHiveModel.fromApiModel(payload);
    return _cacheService.writeMap(_cacheKey, model.toJson());
  }

  @override
  Future<UserDataApiModel?> getCachedUserData() async {
    final cached = await _cacheService.readMap(_cacheKey);
    if (cached == null) return null;
    return UserDataHiveModel.fromJson(cached).toApiModel();
  }
}
