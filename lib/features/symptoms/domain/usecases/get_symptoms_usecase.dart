import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/symptoms/data/repositories/symptoms_repository.dart';
import 'package:vaidya/features/symptoms/domain/entities/symptom_entity.dart';
import 'package:vaidya/features/symptoms/domain/repositories/symptoms_repository.dart';

final getSymptomsUsecaseProvider = Provider<GetSymptomsUsecase>((ref) {
  return GetSymptomsUsecase(repository: ref.read(symptomsRepositoryProvider));
});

class GetSymptomsUsecase implements UsecaseWithoutParams<List<SymptomEntity>> {
  final ISymptomsRepository _repository;

  const GetSymptomsUsecase({required ISymptomsRepository repository}) : _repository = repository;

  @override
  Future<Either<Failure, List<SymptomEntity>>> call() => _repository.getSymptoms();
}

final getSymptomsSummaryUsecaseProvider = Provider<GetSymptomsSummaryUsecase>((ref) {
  return GetSymptomsSummaryUsecase(repository: ref.read(symptomsRepositoryProvider));
});

class GetSymptomsSummaryUsecase implements UsecaseWithoutParams<SymptomsSummaryEntity> {
  final ISymptomsRepository _repository;

  const GetSymptomsSummaryUsecase({required ISymptomsRepository repository}) : _repository = repository;

  @override
  Future<Either<Failure, SymptomsSummaryEntity>> call() => _repository.getSymptomsSummary();
}
