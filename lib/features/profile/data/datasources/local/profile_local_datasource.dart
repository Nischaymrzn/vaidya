import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/services/hive/feature_cache_service.dart';
import 'package:vaidya/features/profile/data/datasources/profile_datasource.dart';
import 'package:vaidya/features/profile/data/models/profile_user_api_model.dart';
import 'package:vaidya/features/profile/data/models/profile_user_hive_model.dart';

final profileLocalDataSourceProvider = Provider<IProfileLocalDataSource>((ref) {
  return ProfileLocalDataSource(cacheService: ref.read(featureCacheServiceProvider));
});

class ProfileLocalDataSource implements IProfileLocalDataSource {
  final FeatureCacheService _cacheService;

  const ProfileLocalDataSource({required FeatureCacheService cacheService})
      : _cacheService = cacheService;

  static const String _cacheKey = 'profile_user';

  @override
  Future<void> cacheUser(ProfileUserApiModel user) {
    final model = ProfileUserHiveModel.fromApiModel(user);
    return _cacheService.writeMap(_cacheKey, model.toJson());
  }

  @override
  Future<ProfileUserApiModel?> getCachedUser() async {
    final cached = await _cacheService.readMap(_cacheKey);
    if (cached == null) return null;
    return ProfileUserHiveModel.fromJson(cached).toApiModel();
  }
}
