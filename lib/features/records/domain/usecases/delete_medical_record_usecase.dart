import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/records/data/repositories/records_repository.dart';
import 'package:vaidya/features/records/domain/repositories/records_repository.dart';

final deleteMedicalRecordUsecaseProvider = Provider<DeleteMedicalRecordUsecase>(
  (ref) {
    return DeleteMedicalRecordUsecase(
      recordsRepository: ref.read(recordsRepositoryProvider),
    );
  },
);

class DeleteMedicalRecordUsecase
    implements UsecaseWithParams<bool, DeleteMedicalRecordParams> {
  final IRecordsRepository _recordsRepository;

  DeleteMedicalRecordUsecase({required IRecordsRepository recordsRepository})
    : _recordsRepository = recordsRepository;

  @override
  Future<Either<Failure, bool>> call(DeleteMedicalRecordParams params) {
    return _recordsRepository.deleteMedicalRecord(params.id);
  }
}

class DeleteMedicalRecordParams {
  final String id;

  const DeleteMedicalRecordParams({required this.id});
}

