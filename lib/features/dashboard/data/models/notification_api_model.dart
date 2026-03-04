import 'package:vaidya/features/dashboard/domain/entities/notification_entity.dart';

class NotificationApiModel {
  final String id;
  final Map<String, dynamic> data;

  const NotificationApiModel({required this.id, required this.data});

  factory NotificationApiModel.fromJson(Map<String, dynamic> json) {
    final mapped = Map<String, dynamic>.from(json);
    return NotificationApiModel(
      id: (mapped['_id'] ?? mapped['id'] ?? '').toString(),
      data: mapped,
    );
  }

  NotificationEntity toEntity() => NotificationEntity(id: id, data: data);

  static List<NotificationApiModel> fromJsonList(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((item) => NotificationApiModel.fromJson(item.map((k, v) => MapEntry(k.toString(), v))))
        .toList(growable: false);
  }
}

class NotificationsPaginationApiModel {
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  const NotificationsPaginationApiModel({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory NotificationsPaginationApiModel.fromJson(Map<String, dynamic> json) {
    return NotificationsPaginationApiModel(
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
      hasNext: json['hasNext'] == true,
      hasPrev: json['hasPrev'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'total': total,
        'page': page,
        'limit': limit,
        'totalPages': totalPages,
        'hasNext': hasNext,
        'hasPrev': hasPrev,
      };

  NotificationsPaginationEntity toEntity() => NotificationsPaginationEntity(
        total: total,
        page: page,
        limit: limit,
        totalPages: totalPages,
        hasNext: hasNext,
        hasPrev: hasPrev,
      );
}

class NotificationsResultApiModel {
  final List<NotificationApiModel> items;
  final NotificationsPaginationApiModel pagination;

  const NotificationsResultApiModel({required this.items, required this.pagination});

  factory NotificationsResultApiModel.fromResponse(Map<String, dynamic> json) {
    final data = NotificationApiModel.fromJsonList(json['data']);
    final paginationRaw = json['pagination'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final pagination = NotificationsPaginationApiModel.fromJson(paginationRaw);

    return NotificationsResultApiModel(items: data, pagination: pagination);
  }

  NotificationsResultEntity toEntity() => NotificationsResultEntity(
        notifications: items.map((e) => e.toEntity()).toList(growable: false),
        pagination: pagination.toEntity(),
      );
}
