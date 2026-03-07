import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/records/data/repositories/records_repository.dart';
import 'package:vaidya/features/records/domain/repositories/records_repository.dart';

final deleteImmunizationUsecaseProvider = Provider<DeleteImmunizationUsecase>((
  ref,
) {
  return DeleteImmunizationUsecase(
    recordsRepository: ref.read(recordsRepositoryProvider),
  );
});

class DeleteImmunizationUsecase
    implements UsecaseWithParams<bool, DeleteImmunizationParams> {
  final IRecordsRepository _recordsRepository;

  const DeleteImmunizationUsecase({
    required IRecordsRepository recordsRepository,
  }) : _recordsRepository = recordsRepository;

  @override
  Future<Either<Failure, bool>> call(DeleteImmunizationParams params) {
    return _recordsRepository.deleteImmunization(params.id);
  }
}

class DeleteImmunizationParams {
  final String id;

  const DeleteImmunizationParams({required this.id});
}
