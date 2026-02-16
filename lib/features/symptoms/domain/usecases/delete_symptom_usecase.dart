import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/symptoms/data/repositories/symptoms_repository.dart';
import 'package:vaidya/features/symptoms/domain/repositories/symptoms_repository.dart';

final deleteSymptomUsecaseProvider = Provider<DeleteSymptomUsecase>((ref) {
  return DeleteSymptomUsecase(repository: ref.read(symptomsRepositoryProvider));
});

class DeleteSymptomParams extends Equatable {
  final String id;

  const DeleteSymptomParams({required this.id});

  @override
  List<Object?> get props => [id];
}

class DeleteSymptomUsecase implements UsecaseWithParams<bool, DeleteSymptomParams> {
  final ISymptomsRepository _repository;

  const DeleteSymptomUsecase({required ISymptomsRepository repository}) : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(DeleteSymptomParams params) {
    return _repository.deleteSymptom(params.id);
  }
}
