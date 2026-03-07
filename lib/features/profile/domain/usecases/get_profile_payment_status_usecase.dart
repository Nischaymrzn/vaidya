import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/profile/data/repositories/profile_repository.dart';
import 'package:vaidya/features/profile/domain/entities/profile_payment_status_entity.dart';
import 'package:vaidya/features/profile/domain/repositories/profile_repository.dart';

final getProfilePaymentStatusUsecaseProvider =
    Provider<GetProfilePaymentStatusUsecase>((ref) {
      return GetProfilePaymentStatusUsecase(
        repository: ref.read(profileRepositoryProvider),
      );
    });

class GetProfilePaymentStatusUsecase
    implements UsecaseWithoutParams<ProfilePaymentStatusEntity> {
  final IProfileRepository _repository;

  const GetProfilePaymentStatusUsecase({required IProfileRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, ProfilePaymentStatusEntity>> call() {
    return _repository.getPaymentStatus();
  }
}
