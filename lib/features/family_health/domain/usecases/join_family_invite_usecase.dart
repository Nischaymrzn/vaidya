import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/family_health/data/repositories/family_health_repository.dart';
import 'package:vaidya/features/family_health/domain/entities/family_group_entity.dart';
import 'package:vaidya/features/family_health/domain/repositories/family_health_repository.dart';

final joinFamilyInviteUsecaseProvider = Provider<JoinFamilyInviteUsecase>((ref) {
  return JoinFamilyInviteUsecase(repository: ref.read(familyHealthRepositoryProvider));
});

class JoinFamilyInviteParams {
  final String token;
  final Map<String, dynamic> payload;

  const JoinFamilyInviteParams({required this.token, this.payload = const {}});
}

class JoinFamilyInviteUsecase
    implements UsecaseWithParams<FamilyGroupEntity, JoinFamilyInviteParams> {
  final IFamilyHealthRepository _repository;

  const JoinFamilyInviteUsecase({required IFamilyHealthRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, FamilyGroupEntity>> call(JoinFamilyInviteParams params) {
    return _repository.joinWithInvite(params.token, params.payload);
  }
}
