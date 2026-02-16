import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/records/data/repositories/records_repository.dart';
import 'package:vaidya/features/records/domain/entities/medical_record_entity.dart';
import 'package:vaidya/features/records/domain/repositories/records_repository.dart';

final scanMedicalImageUsecaseProvider = Provider<ScanMedicalImageUsecase>((
  ref,
) {
  return ScanMedicalImageUsecase(
    recordsRepository: ref.read(recordsRepositoryProvider),
  );
});

class ScanMedicalImageUsecase
    implements UsecaseWithParams<AiScanResultEntity, ScanMedicalImageParams> {
  final IRecordsRepository _recordsRepository;

  ScanMedicalImageUsecase({required IRecordsRepository recordsRepository})
    : _recordsRepository = recordsRepository;

  @override
  Future<Either<Failure, AiScanResultEntity>> call(
    ScanMedicalImageParams params,
  ) {
    return _recordsRepository.scanMedicalImage(params.imagePath);
  }
}

class ScanMedicalImageParams {
  final String imagePath;

  const ScanMedicalImageParams({required this.imagePath});
}

