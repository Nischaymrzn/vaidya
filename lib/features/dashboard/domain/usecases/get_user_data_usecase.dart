import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/dashboard/data/repositories/user_data_repository.dart';
import 'package:vaidya/features/dashboard/domain/entities/user_data_entity.dart';
import 'package:vaidya/features/dashboard/domain/repositories/user_data_repository.dart';

final getUserDataUsecaseProvider = Provider<GetUserDataUsecase>((ref) {
  return GetUserDataUsecase(repository: ref.read(userDataRepositoryProvider));
});

class GetUserDataUsecase implements UsecaseWithoutParams<UserDataEntity> {
  final IUserDataRepository _repository;

  const GetUserDataUsecase({required IUserDataRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, UserDataEntity>> call() {
    return _repository.getUserData();
  }
}
