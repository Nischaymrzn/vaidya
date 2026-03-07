import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/records/data/repositories/records_repository.dart';
import 'package:vaidya/features/records/domain/entities/record_support_entity.dart';
import 'package:vaidya/features/records/domain/repositories/records_repository.dart';

final getMedicationsUsecaseProvider = Provider<GetMedicationsUsecase>((ref) {
  return GetMedicationsUsecase(
    recordsRepository: ref.read(recordsRepositoryProvider),
  );
});

class GetMedicationsUsecase
    implements UsecaseWithParams<List<MedicationEntity>, GetMedicationsParams> {
  final IRecordsRepository _recordsRepository;

  const GetMedicationsUsecase({required IRecordsRepository recordsRepository})
    : _recordsRepository = recordsRepository;

  @override
  Future<Either<Failure, List<MedicationEntity>>> call(
    GetMedicationsParams params,
  ) {
    return _recordsRepository.getMedications(userId: params.userId);
  }
}

class GetMedicationsParams {
  final String? userId;

  const GetMedicationsParams({this.userId});
}
