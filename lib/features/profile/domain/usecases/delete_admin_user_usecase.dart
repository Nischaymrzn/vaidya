import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/profile/data/repositories/admin_users_repository.dart';
import 'package:vaidya/features/profile/domain/repositories/admin_users_repository.dart';

final deleteAdminUserUsecaseProvider = Provider<DeleteAdminUserUsecase>((ref) {
  return DeleteAdminUserUsecase(repository: ref.read(adminUsersRepositoryProvider));
});

class DeleteAdminUserParams {
  final String id;

  const DeleteAdminUserParams({required this.id});
}

class DeleteAdminUserUsecase implements UsecaseWithParams<bool, DeleteAdminUserParams> {
  final IAdminUsersRepository _repository;

  const DeleteAdminUserUsecase({required IAdminUsersRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(DeleteAdminUserParams params) {
    return _repository.deleteUser(params.id);
  }
}
