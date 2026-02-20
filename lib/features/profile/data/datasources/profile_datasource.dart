import 'package:vaidya/features/profile/data/models/profile_user_api_model.dart';

abstract interface class IProfileRemoteDataSource {
  Future<ProfileUserApiModel> getUserById(String id);
  Future<ProfileUserApiModel> updateUser(String id, Map<String, dynamic> payload, {String? imagePath});
  Future<void> deleteUser(String id);
}

abstract interface class IProfileLocalDataSource {
  Future<void> cacheUser(ProfileUserApiModel user);
  Future<ProfileUserApiModel?> getCachedUser();
}
