import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/profile/data/repositories/profile_repository.dart';
import 'package:vaidya/features/profile/domain/entities/profile_user_entity.dart';
import 'package:vaidya/features/profile/domain/repositories/profile_repository.dart';

final updateProfileUserUsecaseProvider = Provider<UpdateProfileUserUsecase>((ref) {
  return UpdateProfileUserUsecase(repository: ref.read(profileRepositoryProvider));
});

class UpdateProfileUserParams {
  final String id;
  final Map<String, dynamic> payload;
  final String? imagePath;

  const UpdateProfileUserParams({required this.id, required this.payload, this.imagePath});
}

class UpdateProfileUserUsecase
    implements UsecaseWithParams<ProfileUserEntity, UpdateProfileUserParams> {
  final IProfileRepository _repository;

  const UpdateProfileUserUsecase({required IProfileRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, ProfileUserEntity>> call(UpdateProfileUserParams params) {
    return _repository.updateUser(params.id, params.payload, imagePath: params.imagePath);
  }
}
