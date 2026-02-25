import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/records/data/repositories/records_repository.dart';
import 'package:vaidya/features/records/domain/entities/record_support_entity.dart';
import 'package:vaidya/features/records/domain/repositories/records_repository.dart';

final createAllergyUsecaseProvider = Provider<CreateAllergyUsecase>((ref) {
  return CreateAllergyUsecase(
    recordsRepository: ref.read(recordsRepositoryProvider),
  );
});

class CreateAllergyUsecase
    implements UsecaseWithParams<AllergyEntity, AllergyUpsertEntity> {
  final IRecordsRepository _recordsRepository;

  const CreateAllergyUsecase({required IRecordsRepository recordsRepository})
    : _recordsRepository = recordsRepository;

  @override
  Future<Either<Failure, AllergyEntity>> call(AllergyUpsertEntity params) {
    return _recordsRepository.createAllergy(params);
  }
}
