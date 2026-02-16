import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/family_health/data/repositories/family_health_repository.dart';
import 'package:vaidya/features/family_health/domain/entities/family_group_entity.dart';
import 'package:vaidya/features/family_health/domain/repositories/family_health_repository.dart';

final createFamilyGroupUsecaseProvider = Provider<CreateFamilyGroupUsecase>((ref) {
  return CreateFamilyGroupUsecase(repository: ref.read(familyHealthRepositoryProvider));
});

class CreateFamilyGroupParams {
  final Map<String, dynamic> payload;

  const CreateFamilyGroupParams({required this.payload});
}

class CreateFamilyGroupUsecase
    implements UsecaseWithParams<FamilyGroupEntity, CreateFamilyGroupParams> {
  final IFamilyHealthRepository _repository;

  const CreateFamilyGroupUsecase({required IFamilyHealthRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, FamilyGroupEntity>> call(CreateFamilyGroupParams params) {
    return _repository.createGroup(params.payload);
  }
}
