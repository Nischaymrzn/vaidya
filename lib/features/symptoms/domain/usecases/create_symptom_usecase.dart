import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/symptoms/data/repositories/symptoms_repository.dart';
import 'package:vaidya/features/symptoms/domain/entities/symptom_entity.dart';
import 'package:vaidya/features/symptoms/domain/repositories/symptoms_repository.dart';

final createSymptomUsecaseProvider = Provider<CreateSymptomUsecase>((ref) {
  return CreateSymptomUsecase(repository: ref.read(symptomsRepositoryProvider));
});

class CreateSymptomUsecase implements UsecaseWithParams<SymptomEntity, Map<String, dynamic>> {
  final ISymptomsRepository _repository;

  const CreateSymptomUsecase({required ISymptomsRepository repository}) : _repository = repository;

  @override
  Future<Either<Failure, SymptomEntity>> call(Map<String, dynamic> params) {
    return _repository.createSymptom(params);
  }
}
