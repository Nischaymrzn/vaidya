import 'package:equatable/equatable.dart';
import 'package:vaidya/features/dashboard/domain/entities/notification_entity.dart';

enum NotificationsStatus { initial, loading, loaded, error }

class NotificationsState extends Equatable {
  final NotificationsStatus status;
  final List<NotificationEntity> items;
  final NotificationsPaginationEntity pagination;
  final int page;
  final int limit;
  final bool unreadOnly;
  final bool isSubmitting;
  final String? errorMessage;
  final String? actionMessage;

  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.items = const [],
    this.pagination = const NotificationsPaginationEntity.empty(),
    this.page = 1,
    this.limit = 20,
    this.unreadOnly = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.actionMessage,
  });

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<NotificationEntity>? items,
    NotificationsPaginationEntity? pagination,
    int? page,
    int? limit,
    bool? unreadOnly,
    bool? isSubmitting,
    String? errorMessage,
    String? actionMessage,
    bool clearError = false,
    bool clearActionMessage = false,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      items: items ?? this.items,
      pagination: pagination ?? this.pagination,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      unreadOnly: unreadOnly ?? this.unreadOnly,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      actionMessage:
          clearActionMessage ? null : actionMessage ?? this.actionMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        items,
        pagination,
        page,
        limit,
        unreadOnly,
        isSubmitting,
        errorMessage,
        actionMessage,
      ];
}
