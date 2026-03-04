import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final Map<String, dynamic> data;

  const NotificationEntity({required this.id, required this.data});

  @override
  List<Object?> get props => [id, data];
}

class NotificationsPaginationEntity extends Equatable {
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  const NotificationsPaginationEntity({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  const NotificationsPaginationEntity.empty()
      : total = 0,
        page = 1,
        limit = 20,
        totalPages = 1,
        hasNext = false,
        hasPrev = false;

  @override
  List<Object?> get props => [total, page, limit, totalPages, hasNext, hasPrev];
}

class NotificationsResultEntity extends Equatable {
  final List<NotificationEntity> notifications;
  final NotificationsPaginationEntity pagination;

  const NotificationsResultEntity({required this.notifications, required this.pagination});

  const NotificationsResultEntity.empty()
      : notifications = const [],
        pagination = const NotificationsPaginationEntity.empty();

  @override
  List<Object?> get props => [notifications, pagination];
}
