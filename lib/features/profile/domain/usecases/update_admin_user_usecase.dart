import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/profile/data/repositories/admin_users_repository.dart';
import 'package:vaidya/features/profile/domain/entities/admin_user_entity.dart';
import 'package:vaidya/features/profile/domain/repositories/admin_users_repository.dart';

final updateAdminUserUsecaseProvider = Provider<UpdateAdminUserUsecase>((ref) {
  return UpdateAdminUserUsecase(repository: ref.read(adminUsersRepositoryProvider));
});

class UpdateAdminUserParams {
  final String id;
  final Map<String, dynamic> payload;
  final String? imagePath;

  const UpdateAdminUserParams({required this.id, required this.payload, this.imagePath});
}

class UpdateAdminUserUsecase
    implements UsecaseWithParams<AdminUserEntity, UpdateAdminUserParams> {
  final IAdminUsersRepository _repository;

  const UpdateAdminUserUsecase({required IAdminUsersRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, AdminUserEntity>> call(UpdateAdminUserParams params) {
    return _repository.updateUser(
      params.id,
      params.payload,
      imagePath: params.imagePath,
    );
  }
}
