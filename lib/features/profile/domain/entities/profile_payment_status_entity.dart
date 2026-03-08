import 'package:equatable/equatable.dart';

class ProfilePaymentStatusEntity extends Equatable {
  final bool isPremium;
  final String plan;
  final String? role;
  final String? stripeCustomerId;

  const ProfilePaymentStatusEntity({
    required this.isPremium,
    required this.plan,
    this.role,
    this.stripeCustomerId,
  });

  @override
  List<Object?> get props => [isPremium, plan, role, stripeCustomerId];
}
