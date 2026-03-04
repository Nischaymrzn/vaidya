import 'package:dartz/dartz.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/features/family_health/domain/entities/family_group_entity.dart';

abstract interface class IFamilyHealthRepository {
  Future<Either<Failure, FamilyGroupEntity>> getMyGroup();
  Future<Either<Failure, FamilyGroupSummaryEntity>> getMyGroupSummary();
  Future<Either<Failure, FamilyGroupEntity>> createGroup(Map<String, dynamic> payload);
  Future<Either<Failure, FamilyInviteEntity>> createInvite(
    String groupId,
    Map<String, dynamic> payload,
  );
  Future<Either<Failure, FamilyGroupEntity>> addMember(
    String groupId,
    Map<String, dynamic> payload,
  );
  Future<Either<Failure, FamilyGroupEntity>> updateMemberRelation(
    String groupId,
    String memberId,
    Map<String, dynamic> payload,
  );
  Future<Either<Failure, FamilyGroupEntity>> joinWithInvite(
    String token,
    Map<String, dynamic> payload,
  );
}
