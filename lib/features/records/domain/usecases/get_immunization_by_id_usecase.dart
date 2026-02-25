import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/records/data/repositories/records_repository.dart';
import 'package:vaidya/features/records/domain/entities/record_support_entity.dart';
import 'package:vaidya/features/records/domain/repositories/records_repository.dart';

final getImmunizationByIdUsecaseProvider = Provider<GetImmunizationByIdUsecase>(
  (ref) {
    return GetImmunizationByIdUsecase(
      recordsRepository: ref.read(recordsRepositoryProvider),
    );
  },
);

class GetImmunizationByIdUsecase
    implements
        UsecaseWithParams<ImmunizationEntity, GetImmunizationByIdParams> {
  final IRecordsRepository _recordsRepository;

  const GetImmunizationByIdUsecase({
    required IRecordsRepository recordsRepository,
  }) : _recordsRepository = recordsRepository;

  @override
  Future<Either<Failure, ImmunizationEntity>> call(
    GetImmunizationByIdParams params,
  ) {
    return _recordsRepository.getImmunizationById(params.id);
  }
}

class GetImmunizationByIdParams {
  final String id;

  const GetImmunizationByIdParams({required this.id});
}
