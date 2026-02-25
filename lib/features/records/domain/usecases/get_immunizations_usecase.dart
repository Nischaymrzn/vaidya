import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/records/data/repositories/records_repository.dart';
import 'package:vaidya/features/records/domain/entities/record_support_entity.dart';
import 'package:vaidya/features/records/domain/repositories/records_repository.dart';

final getImmunizationsUsecaseProvider = Provider<GetImmunizationsUsecase>((
  ref,
) {
  return GetImmunizationsUsecase(
    recordsRepository: ref.read(recordsRepositoryProvider),
  );
});

class GetImmunizationsUsecase
    implements
        UsecaseWithParams<List<ImmunizationEntity>, GetImmunizationsParams> {
  final IRecordsRepository _recordsRepository;

  const GetImmunizationsUsecase({required IRecordsRepository recordsRepository})
    : _recordsRepository = recordsRepository;

  @override
  Future<Either<Failure, List<ImmunizationEntity>>> call(
    GetImmunizationsParams params,
  ) {
    return _recordsRepository.getImmunizations(userId: params.userId);
  }
}

class GetImmunizationsParams {
  final String? userId;

  const GetImmunizationsParams({this.userId});
}
