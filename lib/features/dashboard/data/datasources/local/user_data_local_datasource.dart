import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/services/hive/feature_cache_service.dart';
import 'package:vaidya/features/dashboard/data/datasources/user_data_datasource.dart';

final userDataLocalDataSourceProvider = Provider<IUserDataLocalDataSource>((ref) {
  return UserDataLocalDataSource(cacheService: ref.read(featureCacheServiceProvider));
});

class UserDataLocalDataSource implements IUserDataLocalDataSource {
  final FeatureCacheService _cacheService;

  const UserDataLocalDataSource({required FeatureCacheService cacheService})
      : _cacheService = cacheService;

  static const String _cacheKey = 'user_data_payload';

  @override
  Future<void> cacheUserData(Map<String, dynamic> payload) {
    return _cacheService.writeMap(_cacheKey, payload);
  }

  @override
  Future<Map<String, dynamic>?> getCachedUserData() {
    return _cacheService.readMap(_cacheKey);
  }
}
