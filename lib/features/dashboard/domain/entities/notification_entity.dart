import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final Map<String, dynamic> data;

  const NotificationEntity({required this.id, required this.data});

  String get title => (data['title'] ?? '').toString();
  String get message => (data['message'] ?? '').toString();

  bool get isRead {
    final raw = data['read'];
    if (raw is bool) return raw;
    if (raw is num) return raw != 0;
    if (raw is String) {
      final normalized = raw.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
    return false;
  }

  DateTime? get createdAt {
    final raw = data['createdAt'];
    if (raw == null) return null;
    final parsed = DateTime.tryParse(raw.toString());
    return parsed;
  }

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

  const NotificationsResultEntity({
    required this.notifications,
    required this.pagination,
  });

  const NotificationsResultEntity.empty()
    : notifications = const [],
      pagination = const NotificationsPaginationEntity.empty();

  @override
  List<Object?> get props => [notifications, pagination];
}
