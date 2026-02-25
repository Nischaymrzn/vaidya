import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/records/data/repositories/records_repository.dart';
import 'package:vaidya/features/records/domain/entities/record_support_entity.dart';
import 'package:vaidya/features/records/domain/repositories/records_repository.dart';

final updateImmunizationUsecaseProvider = Provider<UpdateImmunizationUsecase>((
  ref,
) {
  return UpdateImmunizationUsecase(
    recordsRepository: ref.read(recordsRepositoryProvider),
  );
});

class UpdateImmunizationUsecase
    implements UsecaseWithParams<ImmunizationEntity, UpdateImmunizationParams> {
  final IRecordsRepository _recordsRepository;

  const UpdateImmunizationUsecase({
    required IRecordsRepository recordsRepository,
  }) : _recordsRepository = recordsRepository;

  @override
  Future<Either<Failure, ImmunizationEntity>> call(
    UpdateImmunizationParams params,
  ) {
    return _recordsRepository.updateImmunization(params.id, params.payload);
  }
}

class UpdateImmunizationParams {
  final String id;
  final ImmunizationUpsertEntity payload;

  const UpdateImmunizationParams({required this.id, required this.payload});
}
