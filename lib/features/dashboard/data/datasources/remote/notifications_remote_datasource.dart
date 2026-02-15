import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/api/api_client.dart';
import 'package:vaidya/core/api/api_endpoints.dart';
import 'package:vaidya/features/dashboard/data/datasources/notifications_datasource.dart';
import 'package:vaidya/features/dashboard/data/models/notification_api_model.dart';

final notificationsRemoteDataSourceProvider = Provider<INotificationsRemoteDataSource>((ref) {
  return NotificationsRemoteDataSource(apiClient: ref.read(apiClientProvider));
});

class NotificationsRemoteDataSource implements INotificationsRemoteDataSource {
  final ApiClient _apiClient;

  const NotificationsRemoteDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<NotificationsResultApiModel> getNotifications({
    required int page,
    required int limit,
    required bool unreadOnly,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.notifications,
      queryParameters: {
        'page': page,
        'limit': limit,
        'unreadOnly': unreadOnly,
      },
    );

    if (response.data['success'] == true) {
      final payload = response.data as Map<String, dynamic>;
      return NotificationsResultApiModel.fromResponse(payload);
    }

    throw Exception(response.data['message'] ?? 'Failed to fetch notifications');
  }

  @override
  Future<NotificationApiModel> markRead(String id) async {
    final response = await _apiClient.patch(ApiEndpoints.notificationMarkRead(id));

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
      return NotificationApiModel.fromJson(data);
    }

    throw Exception(response.data['message'] ?? 'Failed to mark notification as read');
  }

  @override
  Future<Map<String, dynamic>> markAllRead() async {
    final response = await _apiClient.patch(ApiEndpoints.notificationMarkAllRead);

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
      return data;
    }

    throw Exception(response.data['message'] ?? 'Failed to mark all notifications as read');
  }
}
