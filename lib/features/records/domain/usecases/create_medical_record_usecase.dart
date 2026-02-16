import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/records/data/repositories/records_repository.dart';
import 'package:vaidya/features/records/domain/entities/medical_record_entity.dart';
import 'package:vaidya/features/records/domain/repositories/records_repository.dart';

final createMedicalRecordUsecaseProvider = Provider<CreateMedicalRecordUsecase>(
  (ref) {
    return CreateMedicalRecordUsecase(
      recordsRepository: ref.read(recordsRepositoryProvider),
    );
  },
);

class CreateMedicalRecordUsecase
    implements
        UsecaseWithParams<MedicalRecordEntity, MedicalRecordUpsertEntity> {
  final IRecordsRepository _recordsRepository;

  CreateMedicalRecordUsecase({required IRecordsRepository recordsRepository})
    : _recordsRepository = recordsRepository;

  @override
  Future<Either<Failure, MedicalRecordEntity>> call(
    MedicalRecordUpsertEntity params,
  ) {
    return _recordsRepository.createMedicalRecord(params);
  }
}

