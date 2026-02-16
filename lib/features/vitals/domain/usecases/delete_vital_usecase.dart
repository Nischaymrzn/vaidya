import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/vitals/data/repositories/vitals_repository.dart';
import 'package:vaidya/features/vitals/domain/repositories/vitals_repository.dart';

final deleteVitalUsecaseProvider = Provider<DeleteVitalUsecase>((ref) {
  return DeleteVitalUsecase(repository: ref.read(vitalsRepositoryProvider));
});

class DeleteVitalParams extends Equatable {
  final String id;

  const DeleteVitalParams({required this.id});

  @override
  List<Object?> get props => [id];
}

class DeleteVitalUsecase implements UsecaseWithParams<bool, DeleteVitalParams> {
  final IVitalsRepository _repository;

  const DeleteVitalUsecase({required IVitalsRepository repository}) : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(DeleteVitalParams params) {
    return _repository.deleteVital(params.id);
  }
}
