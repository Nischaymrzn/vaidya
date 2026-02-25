import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/records/data/repositories/records_repository.dart';
import 'package:vaidya/features/records/domain/entities/record_support_entity.dart';
import 'package:vaidya/features/records/domain/repositories/records_repository.dart';

final createMedicationUsecaseProvider = Provider<CreateMedicationUsecase>((
  ref,
) {
  return CreateMedicationUsecase(
    recordsRepository: ref.read(recordsRepositoryProvider),
  );
});

class CreateMedicationUsecase
    implements UsecaseWithParams<MedicationEntity, MedicationUpsertEntity> {
  final IRecordsRepository _recordsRepository;

  const CreateMedicationUsecase({required IRecordsRepository recordsRepository})
    : _recordsRepository = recordsRepository;

  @override
  Future<Either<Failure, MedicationEntity>> call(
    MedicationUpsertEntity params,
  ) {
    return _recordsRepository.createMedication(params);
  }
}
