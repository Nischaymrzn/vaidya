import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/profile/data/repositories/profile_repository.dart';
import 'package:vaidya/features/profile/domain/repositories/profile_repository.dart';

final deleteProfileUserUsecaseProvider = Provider<DeleteProfileUserUsecase>((ref) {
  return DeleteProfileUserUsecase(repository: ref.read(profileRepositoryProvider));
});

class DeleteProfileUserParams {
  final String id;

  const DeleteProfileUserParams({required this.id});
}

class DeleteProfileUserUsecase
    implements UsecaseWithParams<bool, DeleteProfileUserParams> {
  final IProfileRepository _repository;

  const DeleteProfileUserUsecase({required IProfileRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(DeleteProfileUserParams params) {
    return _repository.deleteUser(params.id);
  }
}
