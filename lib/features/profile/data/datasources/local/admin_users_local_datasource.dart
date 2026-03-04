import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/services/hive/feature_cache_service.dart';
import 'package:vaidya/features/profile/data/datasources/admin_users_datasource.dart';

final adminUsersLocalDataSourceProvider = Provider<IAdminUsersLocalDataSource>((ref) {
  return AdminUsersLocalDataSource(cacheService: ref.read(featureCacheServiceProvider));
});

class AdminUsersLocalDataSource implements IAdminUsersLocalDataSource {
  final FeatureCacheService _cacheService;

  const AdminUsersLocalDataSource({required FeatureCacheService cacheService})
      : _cacheService = cacheService;

  static const String _itemsKey = 'admin_users_items';
  static const String _paginationKey = 'admin_users_pagination';

  @override
  Future<void> cacheUsers(List<Map<String, dynamic>> users) {
    return _cacheService.writeList(_itemsKey, users);
  }

  @override
  Future<List<Map<String, dynamic>>> getCachedUsers() {
    return _cacheService.readList(_itemsKey);
  }

  @override
  Future<void> cachePagination(Map<String, dynamic> pagination) {
    return _cacheService.writeMap(_paginationKey, pagination);
  }

  @override
  Future<Map<String, dynamic>?> getCachedPagination() {
    return _cacheService.readMap(_paginationKey);
  }
}
