import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/profile/data/repositories/profile_repository.dart';
import 'package:vaidya/features/profile/domain/entities/profile_user_entity.dart';
import 'package:vaidya/features/profile/domain/repositories/profile_repository.dart';

final getProfileUserUsecaseProvider = Provider<GetProfileUserUsecase>((ref) {
  return GetProfileUserUsecase(repository: ref.read(profileRepositoryProvider));
});

class GetProfileUserParams {
  final String id;

  const GetProfileUserParams({required this.id});
}

class GetProfileUserUsecase
    implements UsecaseWithParams<ProfileUserEntity, GetProfileUserParams> {
  final IProfileRepository _repository;

  const GetProfileUserUsecase({required IProfileRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, ProfileUserEntity>> call(GetProfileUserParams params) {
    return _repository.getUserById(params.id);
  }
}
