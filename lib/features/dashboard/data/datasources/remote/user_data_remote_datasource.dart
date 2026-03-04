import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/api/api_client.dart';
import 'package:vaidya/core/api/api_endpoints.dart';
import 'package:vaidya/features/dashboard/data/datasources/user_data_datasource.dart';
import 'package:vaidya/features/dashboard/data/models/user_data_api_model.dart';

final userDataRemoteDataSourceProvider = Provider<IUserDataRemoteDataSource>((ref) {
  return UserDataRemoteDataSource(apiClient: ref.read(apiClientProvider));
});

class UserDataRemoteDataSource implements IUserDataRemoteDataSource {
  final ApiClient _apiClient;

  const UserDataRemoteDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<UserDataApiModel> getUserData() async {
    final response = await _apiClient.get(ApiEndpoints.userData);

    if (response.data['success'] == true) {
      final payload = response.data['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
      return UserDataApiModel.fromJson(payload);
    }

    throw Exception(response.data['message'] ?? 'Failed to fetch user data');
  }

  @override
  Future<UserDataApiModel> updateUserData(Map<String, dynamic> payload) async {
    final response = await _apiClient.patch(ApiEndpoints.userData, data: payload);

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
      return UserDataApiModel.fromJson(data);
    }

    throw Exception(response.data['message'] ?? 'Failed to update user data');
  }
}
