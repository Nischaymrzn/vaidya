import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/records/data/repositories/records_repository.dart';
import 'package:vaidya/features/records/domain/entities/medical_record_entity.dart';
import 'package:vaidya/features/records/domain/repositories/records_repository.dart';

final getMedicalRecordByIdUsecaseProvider = Provider<GetMedicalRecordByIdUsecase>((ref) {
  return GetMedicalRecordByIdUsecase(repository: ref.read(recordsRepositoryProvider));
});

class GetMedicalRecordByIdParams {
  final String id;

  const GetMedicalRecordByIdParams({required this.id});
}

class GetMedicalRecordByIdUsecase
    implements UsecaseWithParams<MedicalRecordEntity, GetMedicalRecordByIdParams> {
  final IRecordsRepository _repository;

  const GetMedicalRecordByIdUsecase({required IRecordsRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, MedicalRecordEntity>> call(GetMedicalRecordByIdParams params) {
    return _repository.getMedicalRecordById(params.id);
  }
}
