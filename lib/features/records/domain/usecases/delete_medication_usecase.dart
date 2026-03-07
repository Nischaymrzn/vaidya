import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/records/data/repositories/records_repository.dart';
import 'package:vaidya/features/records/domain/repositories/records_repository.dart';

final deleteMedicationUsecaseProvider = Provider<DeleteMedicationUsecase>((
  ref,
) {
  return DeleteMedicationUsecase(
    recordsRepository: ref.read(recordsRepositoryProvider),
  );
});

class DeleteMedicationUsecase
    implements UsecaseWithParams<bool, DeleteMedicationParams> {
  final IRecordsRepository _recordsRepository;

  const DeleteMedicationUsecase({required IRecordsRepository recordsRepository})
    : _recordsRepository = recordsRepository;

  @override
  Future<Either<Failure, bool>> call(DeleteMedicationParams params) {
    return _recordsRepository.deleteMedication(params.id);
  }
}

class DeleteMedicationParams {
  final String id;

  const DeleteMedicationParams({required this.id});
}
