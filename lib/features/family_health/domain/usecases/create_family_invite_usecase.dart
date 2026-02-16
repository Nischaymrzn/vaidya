import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/family_health/data/repositories/family_health_repository.dart';
import 'package:vaidya/features/family_health/domain/entities/family_group_entity.dart';
import 'package:vaidya/features/family_health/domain/repositories/family_health_repository.dart';

final createFamilyInviteUsecaseProvider = Provider<CreateFamilyInviteUsecase>((ref) {
  return CreateFamilyInviteUsecase(repository: ref.read(familyHealthRepositoryProvider));
});

class CreateFamilyInviteParams {
  final String groupId;
  final Map<String, dynamic> payload;

  const CreateFamilyInviteParams({required this.groupId, this.payload = const {}});
}

class CreateFamilyInviteUsecase
    implements UsecaseWithParams<FamilyInviteEntity, CreateFamilyInviteParams> {
  final IFamilyHealthRepository _repository;

  const CreateFamilyInviteUsecase({required IFamilyHealthRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, FamilyInviteEntity>> call(CreateFamilyInviteParams params) {
    return _repository.createInvite(params.groupId, params.payload);
  }
}
