import 'package:vaidya/features/profile/data/models/profile_user_api_model.dart';
import 'package:vaidya/features/profile/data/models/profile_payment_status_api_model.dart';
import 'package:vaidya/features/profile/data/models/profile_checkout_session_api_model.dart';

abstract interface class IProfileRemoteDataSource {
  Future<ProfileUserApiModel> getUserById(String id);
  Future<ProfileUserApiModel> updateUser(
    String id,
    Map<String, dynamic> payload, {
    String? imagePath,
  });
  Future<void> deleteUser(String id);
  Future<ProfilePaymentStatusApiModel> getPaymentStatus();
  Future<ProfileCheckoutSessionApiModel> createCheckoutSession();
}

abstract interface class IProfileLocalDataSource {
  Future<void> saveUser(ProfileUserApiModel user);
  Future<ProfileUserApiModel?> getUser();
  Future<void> savePaymentStatus(ProfilePaymentStatusApiModel status);
  Future<ProfilePaymentStatusApiModel?> getPaymentStatus();
}
