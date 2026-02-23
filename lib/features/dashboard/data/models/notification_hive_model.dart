import 'package:vaidya/features/dashboard/data/models/notification_api_model.dart';

class NotificationHiveModel {
  final String id;
  final Map<String, dynamic> data;

  const NotificationHiveModel({required this.id, required this.data});

  factory NotificationHiveModel.fromApiModel(NotificationApiModel apiModel) {
    return NotificationHiveModel(
      id: apiModel.id,
      data: Map<String, dynamic>.from(apiModel.data),
    );
  }

  factory NotificationHiveModel.fromJson(Map<String, dynamic> json) {
    final mapped = Map<String, dynamic>.from(json);
    return NotificationHiveModel(
      id: (mapped['_id'] ?? mapped['id'] ?? '').toString(),
      data: mapped,
    );
  }

  NotificationApiModel toApiModel() {
    return NotificationApiModel.fromJson(data);
  }

  Map<String, dynamic> toJson() {
    return Map<String, dynamic>.from(data);
  }
}

class NotificationsPaginationHiveModel {
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  const NotificationsPaginationHiveModel({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory NotificationsPaginationHiveModel.fromApiModel(
    NotificationsPaginationApiModel apiModel,
  ) {
    return NotificationsPaginationHiveModel(
      total: apiModel.total,
      page: apiModel.page,
      limit: apiModel.limit,
      totalPages: apiModel.totalPages,
      hasNext: apiModel.hasNext,
      hasPrev: apiModel.hasPrev,
    );
  }

  factory NotificationsPaginationHiveModel.fromJson(Map<String, dynamic> json) {
    return NotificationsPaginationHiveModel(
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
      hasNext: json['hasNext'] == true,
      hasPrev: json['hasPrev'] == true,
    );
  }

  NotificationsPaginationApiModel toApiModel() {
    return NotificationsPaginationApiModel(
      total: total,
      page: page,
      limit: limit,
      totalPages: totalPages,
      hasNext: hasNext,
      hasPrev: hasPrev,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'total': total,
      'page': page,
      'limit': limit,
      'totalPages': totalPages,
      'hasNext': hasNext,
      'hasPrev': hasPrev,
    };
  }
}
