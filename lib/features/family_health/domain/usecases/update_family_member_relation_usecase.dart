import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/family_health/data/repositories/family_health_repository.dart';
import 'package:vaidya/features/family_health/domain/entities/family_group_entity.dart';
import 'package:vaidya/features/family_health/domain/repositories/family_health_repository.dart';

final updateFamilyMemberRelationUsecaseProvider =
    Provider<UpdateFamilyMemberRelationUsecase>((ref) {
      return UpdateFamilyMemberRelationUsecase(
        repository: ref.read(familyHealthRepositoryProvider),
      );
    });

class UpdateFamilyMemberRelationParams {
  final String groupId;
  final String memberId;
  final Map<String, dynamic> payload;

  const UpdateFamilyMemberRelationParams({
    required this.groupId,
    required this.memberId,
    required this.payload,
  });
}

class UpdateFamilyMemberRelationUsecase
    implements
        UsecaseWithParams<FamilyGroupEntity, UpdateFamilyMemberRelationParams> {
  final IFamilyHealthRepository _repository;

  const UpdateFamilyMemberRelationUsecase({required IFamilyHealthRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, FamilyGroupEntity>> call(
    UpdateFamilyMemberRelationParams params,
  ) {
    return _repository.updateMemberRelation(
      params.groupId,
      params.memberId,
      params.payload,
    );
  }
}
