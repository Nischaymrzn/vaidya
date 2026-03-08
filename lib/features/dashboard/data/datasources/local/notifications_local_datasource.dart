import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/services/hive/feature_cache_service.dart';
import 'package:vaidya/features/dashboard/data/datasources/notifications_datasource.dart';
import 'package:vaidya/features/dashboard/data/models/notification_api_model.dart';
import 'package:vaidya/features/dashboard/data/models/notification_hive_model.dart';

final notificationsLocalDataSourceProvider =
    Provider<INotificationsLocalDataSource>((ref) {
      return NotificationsLocalDataSource(
        saveService: ref.read(featureCacheServiceProvider),
      );
    });

class NotificationsLocalDataSource implements INotificationsLocalDataSource {
  final FeatureCacheService _cacheService;

  const NotificationsLocalDataSource({required FeatureCacheService saveService})
    : _cacheService = saveService;

  static const String _itemsKey = 'notifications_items';
  static const String _paginationKey = 'notifications_pagination';

  @override
  Future<void> saveNotifications(List<NotificationApiModel> items) {
    final normalized = items
        .map((item) => NotificationHiveModel.fromApiModel(item).toJson())
        .toList(growable: false);
    return _cacheService.writeList(_itemsKey, normalized);
  }

  @override
  Future<List<NotificationApiModel>> getNotifications() async {
    final cached = await _cacheService.readList(_itemsKey);
    return cached
        .map((item) => NotificationHiveModel.fromJson(item).toApiModel())
        .toList(growable: false);
  }

  @override
  Future<void> savePagination(NotificationsPaginationApiModel pagination) {
    final model = NotificationsPaginationHiveModel.fromApiModel(pagination);
    return _cacheService.writeMap(_paginationKey, model.toJson());
  }

  @override
  Future<NotificationsPaginationApiModel?> getPagination() async {
    final cached = await _cacheService.readMap(_paginationKey);
    if (cached == null) return null;
    return NotificationsPaginationHiveModel.fromJson(cached).toApiModel();
  }
}
