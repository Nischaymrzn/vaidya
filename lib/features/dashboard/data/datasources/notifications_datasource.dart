import 'package:vaidya/features/dashboard/data/models/notification_api_model.dart';

abstract interface class INotificationsRemoteDataSource {
  Future<NotificationsResultApiModel> getNotifications({
    required int page,
    required int limit,
    required bool unreadOnly,
  });

  Future<NotificationApiModel> markRead(String id);
  Future<Map<String, dynamic>> markAllRead();
}

abstract interface class INotificationsLocalDataSource {
  Future<void> cacheNotifications(List<Map<String, dynamic>> items);
  Future<List<Map<String, dynamic>>> getCachedNotifications();
  Future<void> cachePagination(Map<String, dynamic> pagination);
  Future<Map<String, dynamic>?> getCachedPagination();
}
