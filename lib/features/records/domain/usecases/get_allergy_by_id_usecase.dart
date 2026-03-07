import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/records/data/repositories/records_repository.dart';
import 'package:vaidya/features/records/domain/entities/record_support_entity.dart';
import 'package:vaidya/features/records/domain/repositories/records_repository.dart';

final getAllergyByIdUsecaseProvider = Provider<GetAllergyByIdUsecase>((ref) {
  return GetAllergyByIdUsecase(
    recordsRepository: ref.read(recordsRepositoryProvider),
  );
});

class GetAllergyByIdUsecase
    implements UsecaseWithParams<AllergyEntity, GetAllergyByIdParams> {
  final IRecordsRepository _recordsRepository;

  const GetAllergyByIdUsecase({required IRecordsRepository recordsRepository})
    : _recordsRepository = recordsRepository;

  @override
  Future<Either<Failure, AllergyEntity>> call(GetAllergyByIdParams params) {
    return _recordsRepository.getAllergyById(params.id);
  }
}

class GetAllergyByIdParams {
  final String id;

  const GetAllergyByIdParams({required this.id});
}
