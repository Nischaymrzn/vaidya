import 'package:vaidya/features/profile/data/models/admin_user_api_model.dart';

abstract interface class IAdminUsersRemoteDataSource {
  Future<AdminUsersResultApiModel> getUsers({required int page, required int limit});
  Future<AdminUserApiModel> getUserById(String id);
  Future<AdminUserApiModel> createUser(Map<String, dynamic> payload, {String? imagePath});
  Future<AdminUserApiModel> updateUser(String id, Map<String, dynamic> payload, {String? imagePath});
  Future<void> deleteUser(String id);
}

abstract interface class IAdminUsersLocalDataSource {
  Future<void> cacheUsers(List<Map<String, dynamic>> users);
  Future<List<Map<String, dynamic>>> getCachedUsers();
  Future<void> cachePagination(Map<String, dynamic> pagination);
  Future<Map<String, dynamic>?> getCachedPagination();
}
