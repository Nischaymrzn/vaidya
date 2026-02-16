import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/dashboard/data/repositories/user_data_repository.dart';
import 'package:vaidya/features/dashboard/domain/entities/user_data_entity.dart';
import 'package:vaidya/features/dashboard/domain/repositories/user_data_repository.dart';

final updateUserDataUsecaseProvider = Provider<UpdateUserDataUsecase>((ref) {
  return UpdateUserDataUsecase(repository: ref.read(userDataRepositoryProvider));
});

class UpdateUserDataParams {
  final Map<String, dynamic> payload;

  const UpdateUserDataParams({required this.payload});
}

class UpdateUserDataUsecase
    implements UsecaseWithParams<UserDataEntity, UpdateUserDataParams> {
  final IUserDataRepository _repository;

  const UpdateUserDataUsecase({required IUserDataRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, UserDataEntity>> call(UpdateUserDataParams params) {
    return _repository.updateUserData(params.payload);
  }
}
