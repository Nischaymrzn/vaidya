import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/auth/data/repositories/auth_repository.dart';
import 'package:vaidya/features/auth/domain/repositories/auth_repository.dart';

final isGoogleLoginConfiguredUsecaseProvider =
    Provider<IsGoogleLoginConfiguredUsecase>((ref) {
      final authRepository = ref.read(authRepositoryProvider);
      return IsGoogleLoginConfiguredUsecase(authRepository: authRepository);
    });

class IsGoogleLoginConfiguredUsecase implements UsecaseWithoutParams<bool> {
  final IAuthRepository _authRepository;

  IsGoogleLoginConfiguredUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call() {
    return _authRepository.isGoogleLoginConfigured();
  }
}
