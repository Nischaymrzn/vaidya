import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/family_health/data/repositories/family_health_repository.dart';
import 'package:vaidya/features/family_health/domain/entities/family_group_entity.dart';
import 'package:vaidya/features/family_health/domain/repositories/family_health_repository.dart';

final addFamilyMemberUsecaseProvider = Provider<AddFamilyMemberUsecase>((ref) {
  return AddFamilyMemberUsecase(repository: ref.read(familyHealthRepositoryProvider));
});

class AddFamilyMemberParams {
  final String groupId;
  final Map<String, dynamic> payload;

  const AddFamilyMemberParams({required this.groupId, required this.payload});
}

class AddFamilyMemberUsecase
    implements UsecaseWithParams<FamilyGroupEntity, AddFamilyMemberParams> {
  final IFamilyHealthRepository _repository;

  const AddFamilyMemberUsecase({required IFamilyHealthRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, FamilyGroupEntity>> call(AddFamilyMemberParams params) {
    return _repository.addMember(params.groupId, params.payload);
  }
}
