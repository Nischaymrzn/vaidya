import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/records/data/repositories/records_repository.dart';
import 'package:vaidya/features/records/domain/entities/record_support_entity.dart';
import 'package:vaidya/features/records/domain/repositories/records_repository.dart';

final getAllergiesUsecaseProvider = Provider<GetAllergiesUsecase>((ref) {
  return GetAllergiesUsecase(
    recordsRepository: ref.read(recordsRepositoryProvider),
  );
});

class GetAllergiesUsecase
    implements UsecaseWithParams<List<AllergyEntity>, GetAllergiesParams> {
  final IRecordsRepository _recordsRepository;

  const GetAllergiesUsecase({required IRecordsRepository recordsRepository})
    : _recordsRepository = recordsRepository;

  @override
  Future<Either<Failure, List<AllergyEntity>>> call(GetAllergiesParams params) {
    return _recordsRepository.getAllergies(userId: params.userId);
  }
}

class GetAllergiesParams {
  final String? userId;

  const GetAllergiesParams({this.userId});
}
