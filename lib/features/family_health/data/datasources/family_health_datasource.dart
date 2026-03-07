import 'package:vaidya/features/family_health/data/models/family_group_api_model.dart';

abstract interface class IFamilyHealthRemoteDataSource {
  Future<FamilyGroupApiModel> getMyGroup();
  Future<FamilyGroupSummaryApiModel> getMyGroupSummary();
  Future<FamilyGroupApiModel> createGroup(Map<String, dynamic> payload);
  Future<FamilyInviteApiModel> createInvite(String groupId, Map<String, dynamic> payload);
  Future<FamilyGroupApiModel> addMember(String groupId, Map<String, dynamic> payload);
  Future<FamilyGroupApiModel> updateMemberRelation(
    String groupId,
    String memberId,
    Map<String, dynamic> payload,
  );
  Future<FamilyGroupApiModel> joinWithInvite(String token, Map<String, dynamic> payload);
}

abstract interface class IFamilyHealthLocalDataSource {
  Future<void> cacheGroup(FamilyGroupApiModel payload);
  Future<FamilyGroupApiModel?> getCachedGroup();
  Future<void> cacheSummary(FamilyGroupSummaryApiModel payload);
  Future<FamilyGroupSummaryApiModel?> getCachedSummary();
}
