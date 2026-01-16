import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/auth/data/repositories/auth_repository.dart';
import 'package:vaidya/features/auth/domain/entities/auth_entity.dart';
import 'package:vaidya/features/auth/domain/repositories/auth_repository.dart';

class RegisterUsecaseParams extends Equatable {
  final String fullName;
  final String email;
  final String? role;
  final String password;
  final int? number;

  const RegisterUsecaseParams({
    required this.fullName,
    required this.email,
    this.role,
    required this.password,
    this.number,
  });

  @override
  List<Object?> get props => [fullName, email, role, password, number];
}

final registerUsecaseProvider = Provider<RegisterUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return RegisterUsecase(authRepository: authRepository);
});

class RegisterUsecase
    implements UsecaseWithParams<bool, RegisterUsecaseParams> {
  final IAuthRepository _authRepository;

  RegisterUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(RegisterUsecaseParams params) {
    final authEntity = AuthEntity(
      name: params.fullName,
      email: params.email,
      role: params.role,
      password: params.password,
      number: params.number,
    );

    return _authRepository.register(authEntity);
  }
}
