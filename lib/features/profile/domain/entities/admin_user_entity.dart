import 'package:equatable/equatable.dart';

class AdminUserEntity extends Equatable {
  final String id;
  final Map<String, dynamic> data;

  const AdminUserEntity({required this.id, required this.data});

  @override
  List<Object?> get props => [id, data];
}

class AdminUsersPaginationEntity extends Equatable {
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  const AdminUsersPaginationEntity({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  const AdminUsersPaginationEntity.empty()
      : total = 0,
        page = 1,
        limit = 10,
        totalPages = 1,
        hasNext = false,
        hasPrev = false;

  @override
  List<Object?> get props => [total, page, limit, totalPages, hasNext, hasPrev];
}

class AdminUsersResultEntity extends Equatable {
  final List<AdminUserEntity> users;
  final AdminUsersPaginationEntity pagination;

  const AdminUsersResultEntity({required this.users, required this.pagination});

  const AdminUsersResultEntity.empty()
      : users = const [],
        pagination = const AdminUsersPaginationEntity.empty();

  @override
  List<Object?> get props => [users, pagination];
}
