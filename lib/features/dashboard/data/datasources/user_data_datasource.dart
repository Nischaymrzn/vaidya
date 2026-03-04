import 'package:vaidya/features/dashboard/data/models/user_data_api_model.dart';

abstract interface class IUserDataRemoteDataSource {
  Future<UserDataApiModel> getUserData();
  Future<UserDataApiModel> updateUserData(Map<String, dynamic> payload);
}

abstract interface class IUserDataLocalDataSource {
  Future<void> cacheUserData(Map<String, dynamic> payload);
  Future<Map<String, dynamic>?> getCachedUserData();
}
