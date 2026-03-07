import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/records/data/repositories/records_repository.dart';
import 'package:vaidya/features/records/domain/entities/record_support_entity.dart';
import 'package:vaidya/features/records/domain/repositories/records_repository.dart';

final updateAllergyUsecaseProvider = Provider<UpdateAllergyUsecase>((ref) {
  return UpdateAllergyUsecase(
    recordsRepository: ref.read(recordsRepositoryProvider),
  );
});

class UpdateAllergyUsecase
    implements UsecaseWithParams<AllergyEntity, UpdateAllergyParams> {
  final IRecordsRepository _recordsRepository;

  const UpdateAllergyUsecase({required IRecordsRepository recordsRepository})
    : _recordsRepository = recordsRepository;

  @override
  Future<Either<Failure, AllergyEntity>> call(UpdateAllergyParams params) {
    return _recordsRepository.updateAllergy(params.id, params.payload);
  }
}

class UpdateAllergyParams {
  final String id;
  final AllergyUpsertEntity payload;

  const UpdateAllergyParams({required this.id, required this.payload});
}
