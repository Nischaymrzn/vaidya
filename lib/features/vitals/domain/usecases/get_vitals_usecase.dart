import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/vitals/data/repositories/vitals_repository.dart';
import 'package:vaidya/features/vitals/domain/entities/vital_entity.dart';
import 'package:vaidya/features/vitals/domain/repositories/vitals_repository.dart';

final getVitalsUsecaseProvider = Provider<GetVitalsUsecase>((ref) {
  return GetVitalsUsecase(repository: ref.read(vitalsRepositoryProvider));
});

class GetVitalsUsecase implements UsecaseWithoutParams<List<VitalEntity>> {
  final IVitalsRepository _repository;

  const GetVitalsUsecase({required IVitalsRepository repository}) : _repository = repository;

  @override
  Future<Either<Failure, List<VitalEntity>>> call() => _repository.getVitals();
}

final getVitalsSummaryUsecaseProvider = Provider<GetVitalsSummaryUsecase>((ref) {
  return GetVitalsSummaryUsecase(repository: ref.read(vitalsRepositoryProvider));
});

class GetVitalsSummaryUsecase implements UsecaseWithoutParams<VitalsSummaryEntity> {
  final IVitalsRepository _repository;

  const GetVitalsSummaryUsecase({required IVitalsRepository repository}) : _repository = repository;

  @override
  Future<Either<Failure, VitalsSummaryEntity>> call() => _repository.getVitalsSummary();
}
