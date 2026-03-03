import 'package:equatable/equatable.dart';
import 'package:vaidya/features/profile/domain/entities/profile_user_entity.dart';

enum ProfileStatus { initial, loading, loaded, error }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final ProfileUserEntity? user;
  final bool isSubmitting;
  final bool isCheckingPremium;
  final bool isUpgradingPremium;
  final bool isPremium;
  final String plan;
  final String? errorMessage;
  final String? actionMessage;
  final String? paymentMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.user,
    this.isSubmitting = false,
    this.isCheckingPremium = false,
    this.isUpgradingPremium = false,
    this.isPremium = false,
    this.plan = 'free',
    this.errorMessage,
    this.actionMessage,
    this.paymentMessage,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    ProfileUserEntity? user,
    bool? isSubmitting,
    bool? isCheckingPremium,
    bool? isUpgradingPremium,
    bool? isPremium,
    String? plan,
    String? errorMessage,
    String? actionMessage,
    String? paymentMessage,
    bool clearError = false,
    bool clearActionMessage = false,
    bool clearPaymentMessage = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isCheckingPremium: isCheckingPremium ?? this.isCheckingPremium,
      isUpgradingPremium: isUpgradingPremium ?? this.isUpgradingPremium,
      isPremium: isPremium ?? this.isPremium,
      plan: plan ?? this.plan,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      actionMessage: clearActionMessage
          ? null
          : actionMessage ?? this.actionMessage,
      paymentMessage: clearPaymentMessage
          ? null
          : paymentMessage ?? this.paymentMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    user,
    isSubmitting,
    isCheckingPremium,
    isUpgradingPremium,
    isPremium,
    plan,
    errorMessage,
    actionMessage,
    paymentMessage,
  ];
}
