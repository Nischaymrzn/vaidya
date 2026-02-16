import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/profile/data/repositories/admin_users_repository.dart';
import 'package:vaidya/features/profile/domain/entities/admin_user_entity.dart';
import 'package:vaidya/features/profile/domain/repositories/admin_users_repository.dart';

final getAdminUsersUsecaseProvider = Provider<GetAdminUsersUsecase>((ref) {
  return GetAdminUsersUsecase(repository: ref.read(adminUsersRepositoryProvider));
});

class GetAdminUsersParams {
  final int page;
  final int limit;

  const GetAdminUsersParams({this.page = 1, this.limit = 10});
}

class GetAdminUsersUsecase
    implements UsecaseWithParams<AdminUsersResultEntity, GetAdminUsersParams> {
  final IAdminUsersRepository _repository;

  const GetAdminUsersUsecase({required IAdminUsersRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, AdminUsersResultEntity>> call(GetAdminUsersParams params) {
    return _repository.getUsers(page: params.page, limit: params.limit);
  }
}

final getAdminUserByIdUsecaseProvider = Provider<GetAdminUserByIdUsecase>((ref) {
  return GetAdminUserByIdUsecase(repository: ref.read(adminUsersRepositoryProvider));
});

class GetAdminUserByIdParams {
  final String id;

  const GetAdminUserByIdParams({required this.id});
}

class GetAdminUserByIdUsecase
    implements UsecaseWithParams<AdminUserEntity, GetAdminUserByIdParams> {
  final IAdminUsersRepository _repository;

  const GetAdminUserByIdUsecase({required IAdminUsersRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, AdminUserEntity>> call(GetAdminUserByIdParams params) {
    return _repository.getUserById(params.id);
  }
}
