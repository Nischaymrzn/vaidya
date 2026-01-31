import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/auth/data/repositories/auth_repository.dart';
import 'package:vaidya/features/auth/domain/entities/auth_entity.dart';
import 'package:vaidya/features/auth/domain/repositories/auth_repository.dart';

class UpdateProfileUsecaseParams extends Equatable {
  final String userId;
  final String? name;
  final String? email;
  final int? number;
  final String? imagePath;

  const UpdateProfileUsecaseParams({
    required this.userId,
    this.name,
    this.email,
    this.number,
    this.imagePath,
  });

  @override
  List<Object?> get props => [userId, name, email, number, imagePath];
}

final updateProfileUsecaseProvider = Provider<UpdateProfileUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return UpdateProfileUsecase(authRepository: authRepository);
});

class UpdateProfileUsecase
    implements UsecaseWithParams<AuthEntity, UpdateProfileUsecaseParams> {
  final IAuthRepository _authRepository;

  UpdateProfileUsecase({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  @override
  Future<Either<Failure, AuthEntity>> call(UpdateProfileUsecaseParams params) {
    return _authRepository.updateProfile(
      params.userId,
      name: params.name,
      email: params.email,
      number: params.number,
      imagePath: params.imagePath,
    );
  }
}
