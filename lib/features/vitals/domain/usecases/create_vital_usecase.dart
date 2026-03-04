import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/vitals/data/repositories/vitals_repository.dart';
import 'package:vaidya/features/vitals/domain/entities/vital_entity.dart';
import 'package:vaidya/features/vitals/domain/repositories/vitals_repository.dart';

final createVitalUsecaseProvider = Provider<CreateVitalUsecase>((ref) {
  return CreateVitalUsecase(repository: ref.read(vitalsRepositoryProvider));
});

class CreateVitalUsecase implements UsecaseWithParams<VitalEntity, Map<String, dynamic>> {
  final IVitalsRepository _repository;

  const CreateVitalUsecase({required IVitalsRepository repository}) : _repository = repository;

  @override
  Future<Either<Failure, VitalEntity>> call(Map<String, dynamic> params) {
    return _repository.createVital(params);
  }
}
