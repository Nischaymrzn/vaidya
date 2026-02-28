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
  Future<void> saveNotifications(List<NotificationApiModel> items);
  Future<List<NotificationApiModel>> getNotifications();
  Future<void> savePagination(NotificationsPaginationApiModel pagination);
  Future<NotificationsPaginationApiModel?> getPagination();
}
