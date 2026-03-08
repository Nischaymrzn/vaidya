import 'package:vaidya/features/profile/domain/entities/profile_payment_status_entity.dart';

class ProfilePaymentStatusApiModel {
  final bool isPremium;
  final String plan;
  final String? role;
  final String? stripeCustomerId;

  const ProfilePaymentStatusApiModel({
    required this.isPremium,
    required this.plan,
    this.role,
    this.stripeCustomerId,
  });

  factory ProfilePaymentStatusApiModel.fromJson(Map<String, dynamic> json) {
    return ProfilePaymentStatusApiModel(
      isPremium: (json['isPremium'] as bool?) ?? false,
      plan: (json['plan'] ?? 'free').toString(),
      role: json['role']?.toString(),
      stripeCustomerId: json['stripeCustomerId']?.toString(),
    );
  }

  ProfilePaymentStatusEntity toEntity() => ProfilePaymentStatusEntity(
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
