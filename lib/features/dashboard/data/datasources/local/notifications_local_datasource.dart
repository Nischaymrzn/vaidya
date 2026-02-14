import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/services/hive/feature_cache_service.dart';
import 'package:vaidya/features/dashboard/data/datasources/notifications_datasource.dart';

final notificationsLocalDataSourceProvider = Provider<INotificationsLocalDataSource>((ref) {
  return NotificationsLocalDataSource(cacheService: ref.read(featureCacheServiceProvider));
});

class NotificationsLocalDataSource implements INotificationsLocalDataSource {
  final FeatureCacheService _cacheService;

  const NotificationsLocalDataSource({required FeatureCacheService cacheService})
      : _cacheService = cacheService;

  static const String _itemsKey = 'notifications_items';
  static const String _paginationKey = 'notifications_pagination';

  @override
  Future<void> cacheNotifications(List<Map<String, dynamic>> items) {
    return _cacheService.writeList(_itemsKey, items);
  }

  @override
  Future<List<Map<String, dynamic>>> getCachedNotifications() {
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
