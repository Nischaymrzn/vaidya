import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/records/data/repositories/records_repository.dart';
import 'package:vaidya/features/records/domain/entities/record_support_entity.dart';
import 'package:vaidya/features/records/domain/repositories/records_repository.dart';

final createImmunizationUsecaseProvider = Provider<CreateImmunizationUsecase>((
  ref,
) {
  return CreateImmunizationUsecase(
    recordsRepository: ref.read(recordsRepositoryProvider),
  );
});

class CreateImmunizationUsecase
    implements UsecaseWithParams<ImmunizationEntity, ImmunizationUpsertEntity> {
  final IRecordsRepository _recordsRepository;

  const CreateImmunizationUsecase({
    required IRecordsRepository recordsRepository,
  }) : _recordsRepository = recordsRepository;

  @override
  Future<Either<Failure, ImmunizationEntity>> call(
    ImmunizationUpsertEntity params,
  ) {
    return _recordsRepository.createImmunization(params);
  }
}
