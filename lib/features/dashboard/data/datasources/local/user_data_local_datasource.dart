import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/services/hive/feature_cache_service.dart';
import 'package:vaidya/features/dashboard/data/datasources/user_data_datasource.dart';
import 'package:vaidya/features/dashboard/data/models/user_data_api_model.dart';
import 'package:vaidya/features/dashboard/data/models/user_data_hive_model.dart';

final userDataLocalDataSourceProvider = Provider<IUserDataLocalDataSource>((
  ref,
) {
  return UserDataLocalDataSource(
    saveService: ref.read(featureCacheServiceProvider),
  );
});

class UserDataLocalDataSource implements IUserDataLocalDataSource {
  final FeatureCacheService _cacheService;

  const UserDataLocalDataSource({required FeatureCacheService saveService})
    : _cacheService = saveService;

  static const String _cacheKey = 'user_data_payload';

  @override
  Future<void> saveUserData(UserDataApiModel data) {
    final model = UserDataHiveModel.fromApiModel(data);
    return _cacheService.writeMap(_cacheKey, model.toJson());
  }

  @override
  Future<UserDataApiModel?> getUserData() async {
    final cached = await _cacheService.readMap(_cacheKey);
    if (cached == null) return null;
    return UserDataHiveModel.fromJson(cached).toApiModel();
  }
}
