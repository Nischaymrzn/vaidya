import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/records/data/repositories/records_repository.dart';
import 'package:vaidya/features/records/domain/repositories/records_repository.dart';

final deleteAllergyUsecaseProvider = Provider<DeleteAllergyUsecase>((ref) {
  return DeleteAllergyUsecase(
    recordsRepository: ref.read(recordsRepositoryProvider),
  );
});

class DeleteAllergyUsecase
    implements UsecaseWithParams<bool, DeleteAllergyParams> {
  final IRecordsRepository _recordsRepository;

  const DeleteAllergyUsecase({required IRecordsRepository recordsRepository})
    : _recordsRepository = recordsRepository;

  @override
  Future<Either<Failure, bool>> call(DeleteAllergyParams params) {
    return _recordsRepository.deleteAllergy(params.id);
  }
}

class DeleteAllergyParams {
  final String id;

  const DeleteAllergyParams({required this.id});
}
