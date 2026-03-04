import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/api/api_client.dart';
import 'package:vaidya/core/api/api_endpoints.dart';
import 'package:vaidya/features/profile/data/datasources/admin_users_datasource.dart';
import 'package:vaidya/features/profile/data/models/admin_user_api_model.dart';

final adminUsersRemoteDataSourceProvider = Provider<IAdminUsersRemoteDataSource>((ref) {
  return AdminUsersRemoteDataSource(apiClient: ref.read(apiClientProvider));
});

class AdminUsersRemoteDataSource implements IAdminUsersRemoteDataSource {
  final ApiClient _apiClient;

  const AdminUsersRemoteDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<AdminUsersResultApiModel> getUsers({required int page, required int limit}) async {
    final response = await _apiClient.get(
      ApiEndpoints.adminUsers(page: page, limit: limit),
    );

    if (response.data['success'] == true) {
      final payload = response.data as Map<String, dynamic>;
      return AdminUsersResultApiModel.fromResponse(payload);
    }

    throw Exception(response.data['message'] ?? 'Failed to fetch admin users');
  }

  @override
  Future<AdminUserApiModel> getUserById(String id) async {
    final response = await _apiClient.get(ApiEndpoints.adminUserById(id));

    if (response.data['success'] == true) {
      final payload = response.data['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
      return AdminUserApiModel.fromJson(payload);
    }

    throw Exception(response.data['message'] ?? 'Failed to fetch admin user');
  }

  @override
  Future<AdminUserApiModel> createUser(Map<String, dynamic> payload, {String? imagePath}) async {
    final response = await _apiClient.post(
      ApiEndpoints.adminUsersBase,
      data: await _toFormData(payload, imagePath: imagePath),
      options: Options(contentType: 'multipart/form-data'),
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
      return AdminUserApiModel.fromJson(data);
    }

    throw Exception(response.data['message'] ?? 'Failed to create admin user');
  }

  @override
  Future<AdminUserApiModel> updateUser(
    String id,
    Map<String, dynamic> payload, {
    String? imagePath,
  }) async {
    final response = await _apiClient.patch(
      ApiEndpoints.adminUserById(id),
      data: await _toFormData(payload, imagePath: imagePath),
      options: Options(contentType: 'multipart/form-data'),
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
      return AdminUserApiModel.fromJson(data);
    }

    throw Exception(response.data['message'] ?? 'Failed to update admin user');
  }

  @override
  Future<void> deleteUser(String id) async {
    final response = await _apiClient.delete(ApiEndpoints.adminUserById(id));
    if (response.data['success'] == true) return;
    throw Exception(response.data['message'] ?? 'Failed to delete admin user');
  }

  Future<FormData> _toFormData(Map<String, dynamic> payload, {String? imagePath}) async {
    final map = Map<String, dynamic>.from(payload);
    if (imagePath != null && imagePath.trim().isNotEmpty) {
      final filename = imagePath.split(RegExp(r'[/\\]')).last;
      map['profilePicture'] = await MultipartFile.fromFile(imagePath, filename: filename);
    }
    return FormData.fromMap(map);
  }
}
