import 'package:vaidya/features/profile/domain/entities/admin_user_entity.dart';

class AdminUserApiModel {
  final String id;
  final Map<String, dynamic> data;

  const AdminUserApiModel({required this.id, required this.data});

  factory AdminUserApiModel.fromJson(Map<String, dynamic> json) {
    final mapped = Map<String, dynamic>.from(json);
    return AdminUserApiModel(id: (mapped['_id'] ?? mapped['id'] ?? '').toString(), data: mapped);
  }

  AdminUserEntity toEntity() => AdminUserEntity(id: id, data: data);

  static List<AdminUserApiModel> fromJsonList(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((item) => AdminUserApiModel.fromJson(item.map((k, v) => MapEntry(k.toString(), v))))
        .toList(growable: false);
  }
}

class AdminUsersPaginationApiModel {
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  const AdminUsersPaginationApiModel({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory AdminUsersPaginationApiModel.fromJson(Map<String, dynamic> json) {
    return AdminUsersPaginationApiModel(
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 10,
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

  AdminUsersPaginationEntity toEntity() => AdminUsersPaginationEntity(
        total: total,
        page: page,
        limit: limit,
        totalPages: totalPages,
        hasNext: hasNext,
        hasPrev: hasPrev,
      );
}

class AdminUsersResultApiModel {
  final List<AdminUserApiModel> items;
  final AdminUsersPaginationApiModel pagination;

  const AdminUsersResultApiModel({required this.items, required this.pagination});

  factory AdminUsersResultApiModel.fromResponse(Map<String, dynamic> json) {
    final items = AdminUserApiModel.fromJsonList(json['data']);
    final paginationRaw = json['pagination'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final pagination = AdminUsersPaginationApiModel.fromJson(paginationRaw);

    return AdminUsersResultApiModel(items: items, pagination: pagination);
  }

  AdminUsersResultEntity toEntity() => AdminUsersResultEntity(
        users: items.map((e) => e.toEntity()).toList(growable: false),
        pagination: pagination.toEntity(),
      );
}
