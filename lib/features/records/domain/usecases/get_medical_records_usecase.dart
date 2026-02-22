import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/records/data/repositories/records_repository.dart';
import 'package:vaidya/features/records/domain/entities/medical_record_entity.dart';
import 'package:vaidya/features/records/domain/repositories/records_repository.dart';

final getMedicalRecordsUsecaseProvider = Provider<GetMedicalRecordsUsecase>((
  ref,
) {
  return GetMedicalRecordsUsecase(
    recordsRepository: ref.read(recordsRepositoryProvider),
  );
});

class GetMedicalRecordsUsecase
    implements
        UsecaseWithParams<MedicalRecordsResultEntity, GetMedicalRecordsParams> {
  final IRecordsRepository _recordsRepository;

  GetMedicalRecordsUsecase({required IRecordsRepository recordsRepository})
    : _recordsRepository = recordsRepository;

  @override
  Future<Either<Failure, MedicalRecordsResultEntity>> call(
    GetMedicalRecordsParams params,
  ) {
    return _recordsRepository.getMedicalRecords(
      page: params.page,
      limit: params.limit,
      userId: params.userId,
    );
  }
}

class GetMedicalRecordsParams {
  final int page;
  final int limit;
  final String? userId;

  const GetMedicalRecordsParams({
    required this.page,
    required this.limit,
    this.userId,
  });
}
