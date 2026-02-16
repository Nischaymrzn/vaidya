import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/services/hive/feature_cache_service.dart';
import 'package:vaidya/features/profile/data/datasources/profile_datasource.dart';

final profileLocalDataSourceProvider = Provider<IProfileLocalDataSource>((ref) {
  return ProfileLocalDataSource(cacheService: ref.read(featureCacheServiceProvider));
});

class ProfileLocalDataSource implements IProfileLocalDataSource {
  final FeatureCacheService _cacheService;

  const ProfileLocalDataSource({required FeatureCacheService cacheService})
      : _cacheService = cacheService;

  static const String _cacheKey = 'profile_user';

  @override
  Future<void> cacheUser(Map<String, dynamic> payload) {
    return _cacheService.writeMap(_cacheKey, payload);
  }

  @override
  Future<Map<String, dynamic>?> getCachedUser() {
    return _cacheService.readMap(_cacheKey);
  }
}
