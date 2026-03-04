import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/symptoms/data/repositories/symptoms_repository.dart';
import 'package:vaidya/features/symptoms/domain/entities/symptom_entity.dart';
import 'package:vaidya/features/symptoms/domain/repositories/symptoms_repository.dart';

final updateSymptomUsecaseProvider = Provider<UpdateSymptomUsecase>((ref) {
  return UpdateSymptomUsecase(repository: ref.read(symptomsRepositoryProvider));
});

class UpdateSymptomParams extends Equatable {
  final String id;
  final Map<String, dynamic> payload;

  const UpdateSymptomParams({required this.id, required this.payload});

  @override
  List<Object?> get props => [id, payload];
}

class UpdateSymptomUsecase implements UsecaseWithParams<SymptomEntity, UpdateSymptomParams> {
  final ISymptomsRepository _repository;

  const UpdateSymptomUsecase({required ISymptomsRepository repository}) : _repository = repository;

  @override
  Future<Either<Failure, SymptomEntity>> call(UpdateSymptomParams params) {
    return _repository.updateSymptom(params.id, params.payload);
  }
}
