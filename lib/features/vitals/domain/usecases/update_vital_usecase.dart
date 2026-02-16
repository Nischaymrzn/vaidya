import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/vitals/data/repositories/vitals_repository.dart';
import 'package:vaidya/features/vitals/domain/entities/vital_entity.dart';
import 'package:vaidya/features/vitals/domain/repositories/vitals_repository.dart';

final updateVitalUsecaseProvider = Provider<UpdateVitalUsecase>((ref) {
  return UpdateVitalUsecase(repository: ref.read(vitalsRepositoryProvider));
});

class UpdateVitalParams extends Equatable {
  final String id;
  final Map<String, dynamic> payload;

  const UpdateVitalParams({required this.id, required this.payload});

  @override
  List<Object?> get props => [id, payload];
}

class UpdateVitalUsecase implements UsecaseWithParams<VitalEntity, UpdateVitalParams> {
  final IVitalsRepository _repository;

  const UpdateVitalUsecase({required IVitalsRepository repository}) : _repository = repository;

  @override
  Future<Either<Failure, VitalEntity>> call(UpdateVitalParams params) {
    return _repository.updateVital(params.id, params.payload);
  }
}
