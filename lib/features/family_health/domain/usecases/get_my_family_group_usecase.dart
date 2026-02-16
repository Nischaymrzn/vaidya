import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/family_health/data/repositories/family_health_repository.dart';
import 'package:vaidya/features/family_health/domain/entities/family_group_entity.dart';
import 'package:vaidya/features/family_health/domain/repositories/family_health_repository.dart';

final getMyFamilyGroupUsecaseProvider = Provider<GetMyFamilyGroupUsecase>((ref) {
  return GetMyFamilyGroupUsecase(repository: ref.read(familyHealthRepositoryProvider));
});

class GetMyFamilyGroupUsecase implements UsecaseWithoutParams<FamilyGroupEntity> {
  final IFamilyHealthRepository _repository;

  const GetMyFamilyGroupUsecase({required IFamilyHealthRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, FamilyGroupEntity>> call() => _repository.getMyGroup();
}

final getMyFamilyGroupSummaryUsecaseProvider = Provider<GetMyFamilyGroupSummaryUsecase>((ref) {
  return GetMyFamilyGroupSummaryUsecase(repository: ref.read(familyHealthRepositoryProvider));
});

class GetMyFamilyGroupSummaryUsecase
    implements UsecaseWithoutParams<FamilyGroupSummaryEntity> {
  final IFamilyHealthRepository _repository;

  const GetMyFamilyGroupSummaryUsecase({required IFamilyHealthRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, FamilyGroupSummaryEntity>> call() =>
      _repository.getMyGroupSummary();
}
