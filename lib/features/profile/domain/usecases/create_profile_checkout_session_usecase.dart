import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/profile/data/repositories/profile_repository.dart';
import 'package:vaidya/features/profile/domain/repositories/profile_repository.dart';

final createProfileCheckoutSessionUsecaseProvider =
    Provider<CreateProfileCheckoutSessionUsecase>((ref) {
      return CreateProfileCheckoutSessionUsecase(
        repository: ref.read(profileRepositoryProvider),
      );
    });

class CreateProfileCheckoutSessionUsecase
    implements UsecaseWithoutParams<String> {
  final IProfileRepository _repository;

  const CreateProfileCheckoutSessionUsecase({
    required IProfileRepository repository,
  }) : _repository = repository;

  @override
  Future<Either<Failure, String>> call() {
    return _repository.createCheckoutSession();
  }
}
