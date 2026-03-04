import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/profile/data/repositories/admin_users_repository.dart';
import 'package:vaidya/features/profile/domain/entities/admin_user_entity.dart';
import 'package:vaidya/features/profile/domain/repositories/admin_users_repository.dart';

final createAdminUserUsecaseProvider = Provider<CreateAdminUserUsecase>((ref) {
  return CreateAdminUserUsecase(repository: ref.read(adminUsersRepositoryProvider));
});

class CreateAdminUserParams {
  final Map<String, dynamic> payload;
  final String? imagePath;

  const CreateAdminUserParams({required this.payload, this.imagePath});
}

class CreateAdminUserUsecase
    implements UsecaseWithParams<AdminUserEntity, CreateAdminUserParams> {
  final IAdminUsersRepository _repository;

  const CreateAdminUserUsecase({required IAdminUsersRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, AdminUserEntity>> call(CreateAdminUserParams params) {
    return _repository.createUser(params.payload, imagePath: params.imagePath);
  }
}
