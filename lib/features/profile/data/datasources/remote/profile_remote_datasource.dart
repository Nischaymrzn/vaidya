import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/api/api_client.dart';
import 'package:vaidya/core/api/api_endpoints.dart';
import 'package:vaidya/features/profile/data/datasources/profile_datasource.dart';
import 'package:vaidya/features/profile/data/models/profile_user_api_model.dart';

final profileRemoteDataSourceProvider = Provider<IProfileRemoteDataSource>((ref) {
  return ProfileRemoteDataSource(apiClient: ref.read(apiClientProvider));
});

class ProfileRemoteDataSource implements IProfileRemoteDataSource {
  final ApiClient _apiClient;

  const ProfileRemoteDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<ProfileUserApiModel> getUserById(String id) async {
    final response = await _apiClient.get(ApiEndpoints.userById(id));

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
      return ProfileUserApiModel.fromJson(data);
    }

    throw Exception(response.data['message'] ?? 'Failed to fetch user profile');
  }

  @override
  Future<ProfileUserApiModel> updateUser(
    String id,
    Map<String, dynamic> payload, {
    String? imagePath,
  }) async {
    final response = await _apiClient.put(
      ApiEndpoints.userById(id),
      data: await _toFormData(payload, imagePath: imagePath),
      options: Options(contentType: 'multipart/form-data'),
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
      return ProfileUserApiModel.fromJson(data);
    }

    throw Exception(response.data['message'] ?? 'Failed to update profile');
  }

  @override
  Future<void> deleteUser(String id) async {
    final response = await _apiClient.delete(ApiEndpoints.userById(id));
    if (response.data['success'] == true) return;
    throw Exception(response.data['message'] ?? 'Failed to delete profile');
  }

  Future<FormData> _toFormData(Map<String, dynamic> payload, {String? imagePath}) async {
    final map = Map<String, dynamic>.from(payload);
    if (imagePath != null && imagePath.trim().isNotEmpty) {
      final filename = imagePath.split(RegExp(r'[/\\]')).last;
      map['image'] = await MultipartFile.fromFile(imagePath, filename: filename);
    }
    return FormData.fromMap(map);
  }
}
