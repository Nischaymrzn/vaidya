import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/auth/data/repositories/auth_repository.dart';
import 'package:vaidya/features/auth/domain/entities/auth_entity.dart';
import 'package:vaidya/features/auth/domain/repositories/auth_repository.dart';

final loginWithGoogleUsecaseProvider = Provider<LoginWithGoogleUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return LoginWithGoogleUsecase(authRepository: authRepository);
});

class LoginWithGoogleUsecase implements UsecaseWithoutParams<AuthEntity> {
  final IAuthRepository _authRepository;

  LoginWithGoogleUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, AuthEntity>> call() {
    return _authRepository.loginWithGoogle();
  }
}
