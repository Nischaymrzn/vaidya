import 'package:vaidya/features/profile/data/models/profile_payment_status_api_model.dart';

class ProfilePaymentStatusHiveModel {
  final bool isPremium;
  final String plan;
  final String? role;
  final String? stripeCustomerId;

  const ProfilePaymentStatusHiveModel({
    required this.isPremium,
    required this.plan,
    this.role,
    this.stripeCustomerId,
  });

  factory ProfilePaymentStatusHiveModel.fromApiModel(
    ProfilePaymentStatusApiModel apiModel,
  ) {
    return ProfilePaymentStatusHiveModel(
      isPremium: apiModel.isPremium,
      plan: apiModel.plan,
      role: apiModel.role,
      stripeCustomerId: apiModel.stripeCustomerId,
    );
  }

  factory ProfilePaymentStatusHiveModel.fromJson(Map<String, dynamic> json) {
    return ProfilePaymentStatusHiveModel(
      isPremium: (json['isPremium'] as bool?) ?? false,
      plan: (json['plan'] ?? 'free').toString(),
      role: json['role']?.toString(),
      stripeCustomerId: json['stripeCustomerId']?.toString(),
    );
  }

  ProfilePaymentStatusApiModel toApiModel() => ProfilePaymentStatusApiModel(
    isPremium: isPremium,
    plan: plan,
    role: role,
    stripeCustomerId: stripeCustomerId,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'isPremium': isPremium,
    'plan': plan,
    'role': role,
    'stripeCustomerId': stripeCustomerId,
  };
}
