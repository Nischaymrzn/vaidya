import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/auth/data/repositories/auth_repository.dart';
import 'package:vaidya/features/auth/domain/entities/auth_entity.dart';
import 'package:vaidya/features/auth/domain/repositories/auth_repository.dart';

class LoginWithGoogleTokenUsecaseParams extends Equatable {
  final String token;

  const LoginWithGoogleTokenUsecaseParams({required this.token});

  @override
  List<Object?> get props => [token];
}

final loginWithGoogleTokenUsecaseProvider =
    Provider<LoginWithGoogleTokenUsecase>((ref) {
      final authRepository = ref.read(authRepositoryProvider);
      return LoginWithGoogleTokenUsecase(authRepository: authRepository);
    });

class LoginWithGoogleTokenUsecase
    implements
        UsecaseWithParams<AuthEntity, LoginWithGoogleTokenUsecaseParams> {
  final IAuthRepository _authRepository;

  LoginWithGoogleTokenUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, AuthEntity>> call(
    LoginWithGoogleTokenUsecaseParams params,
  ) {
    return _authRepository.loginWithGoogleToken(params.token);
  }
}
