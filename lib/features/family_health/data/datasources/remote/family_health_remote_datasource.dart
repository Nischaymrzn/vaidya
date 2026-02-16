import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/api/api_client.dart';
import 'package:vaidya/core/api/api_endpoints.dart';
import 'package:vaidya/features/family_health/data/datasources/family_health_datasource.dart';
import 'package:vaidya/features/family_health/data/models/family_group_api_model.dart';

final familyHealthRemoteDataSourceProvider = Provider<IFamilyHealthRemoteDataSource>((ref) {
  return FamilyHealthRemoteDataSource(apiClient: ref.read(apiClientProvider));
});

class FamilyHealthRemoteDataSource implements IFamilyHealthRemoteDataSource {
  final ApiClient _apiClient;

  const FamilyHealthRemoteDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<FamilyGroupApiModel> getMyGroup() async {
    final response = await _apiClient.get(ApiEndpoints.familyMyGroup);
    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
      return FamilyGroupApiModel.fromJson(data);
    }
    throw Exception(response.data['message'] ?? 'Failed to fetch family group');
  }

  @override
  Future<FamilyGroupSummaryApiModel> getMyGroupSummary() async {
    final response = await _apiClient.get(ApiEndpoints.familySummary);
    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
      return FamilyGroupSummaryApiModel.fromJson(data);
    }
    throw Exception(response.data['message'] ?? 'Failed to fetch family group summary');
  }

  @override
  Future<FamilyGroupApiModel> createGroup(Map<String, dynamic> payload) async {
    final response = await _apiClient.post(ApiEndpoints.familyGroups, data: payload);
    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
      return FamilyGroupApiModel.fromJson(data);
    }
    throw Exception(response.data['message'] ?? 'Failed to create family group');
  }

  @override
  Future<FamilyInviteApiModel> createInvite(String groupId, Map<String, dynamic> payload) async {
    final response = await _apiClient.post(ApiEndpoints.familyInvite(groupId), data: payload);
    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
      return FamilyInviteApiModel.fromJson(data);
    }
    throw Exception(response.data['message'] ?? 'Failed to create invite link');
  }

  @override
  Future<FamilyGroupApiModel> addMember(String groupId, Map<String, dynamic> payload) async {
    final response = await _apiClient.post(ApiEndpoints.familyAddMember(groupId), data: payload);
    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
      return FamilyGroupApiModel.fromJson(data);
    }
    throw Exception(response.data['message'] ?? 'Failed to add family member');
  }

  @override
  Future<FamilyGroupApiModel> updateMemberRelation(
    String groupId,
    String memberId,
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.patch(
      ApiEndpoints.familyUpdateMember(groupId, memberId),
      data: payload,
    );
    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
      return FamilyGroupApiModel.fromJson(data);
    }
    throw Exception(response.data['message'] ?? 'Failed to update relation');
  }

  @override
  Future<FamilyGroupApiModel> joinWithInvite(String token, Map<String, dynamic> payload) async {
    final response = await _apiClient.post(ApiEndpoints.familyJoin(token), data: payload);
    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
      return FamilyGroupApiModel.fromJson(data);
    }
    throw Exception(response.data['message'] ?? 'Failed to join family group');
  }
}
