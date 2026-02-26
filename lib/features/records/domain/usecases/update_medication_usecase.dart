import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/records/data/repositories/records_repository.dart';
import 'package:vaidya/features/records/domain/entities/record_support_entity.dart';
import 'package:vaidya/features/records/domain/repositories/records_repository.dart';

final updateMedicationUsecaseProvider = Provider<UpdateMedicationUsecase>((
  ref,
) {
  return UpdateMedicationUsecase(
    recordsRepository: ref.read(recordsRepositoryProvider),
  );
});

class UpdateMedicationUsecase
    implements UsecaseWithParams<MedicationEntity, UpdateMedicationParams> {
  final IRecordsRepository _recordsRepository;

  const UpdateMedicationUsecase({required IRecordsRepository recordsRepository})
    : _recordsRepository = recordsRepository;

  @override
  Future<Either<Failure, MedicationEntity>> call(
    UpdateMedicationParams params,
  ) {
    return _recordsRepository.updateMedication(params.id, params.payload);
  }
}

class UpdateMedicationParams {
  final String id;
  final MedicationUpsertEntity payload;

  const UpdateMedicationParams({required this.id, required this.payload});
}
