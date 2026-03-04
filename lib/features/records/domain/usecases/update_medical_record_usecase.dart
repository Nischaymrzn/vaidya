import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/records/data/repositories/records_repository.dart';
import 'package:vaidya/features/records/domain/entities/medical_record_entity.dart';
import 'package:vaidya/features/records/domain/repositories/records_repository.dart';

final updateMedicalRecordUsecaseProvider = Provider<UpdateMedicalRecordUsecase>(
  (ref) {
    return UpdateMedicalRecordUsecase(
      recordsRepository: ref.read(recordsRepositoryProvider),
    );
  },
);

class UpdateMedicalRecordUsecase
    implements
        UsecaseWithParams<MedicalRecordEntity, UpdateMedicalRecordParams> {
  final IRecordsRepository _recordsRepository;

  UpdateMedicalRecordUsecase({required IRecordsRepository recordsRepository})
    : _recordsRepository = recordsRepository;

  @override
  Future<Either<Failure, MedicalRecordEntity>> call(
    UpdateMedicalRecordParams params,
  ) {
    return _recordsRepository.updateMedicalRecord(params.id, params.payload);
  }
}

class UpdateMedicalRecordParams {
  final String id;
  final MedicalRecordUpsertEntity payload;

  const UpdateMedicalRecordParams({required this.id, required this.payload});
}

